import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amrita_retriever/services/postsdb.dart';
import 'package:amrita_retriever/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class AddLostItemPage extends StatefulWidget {
  final String userId;
  const AddLostItemPage({super.key, required this.userId});

  @override
  State<AddLostItemPage> createState() => _AddLostItemPageState();
}

class _AddLostItemPageState extends State<AddLostItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _rewardController = TextEditingController(); // Controller for reward
  
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final position = await LocationService().getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        // Optionally update the text field with coordinates or address if we had reverse geocoding
        // _locationController.text = "${position.latitude}, ${position.longitude}"; 
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Location captured!")),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  } 
  // The prompt says: "if the user clicks on a 'found item' post, he should answer a security qn... to reveal... person who found it"
  // So Lost items don't necessarily need a security question to contact the owner? Usually contact info is public for lost items? 
  // But the schema has security_question locally in `posts` table.
  // I will leave security question Optional or Empty for Lost items if not required. 
  // However, `posts` table has `security_question` column.
  // For LOST items, usually you want people to contact YOU freely.
  // The requirement specifically mentions "found item" post logic.
  // I'll skip security question for LOST items for now, or start with null.

  bool _isLoading = false;
  XFile? _selectedImage;
  final _postsDb = PostsDbClient();

  // Image Picker
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Upload Image to Supabase Storage
  Future<String?> _uploadImage(String userIdStr) async {
    if (_selectedImage == null) return null;

    final fileExt = _selectedImage!.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userIdStr.$fileExt';
    final filePath = 'images/$fileName'; 

    try {
      final bytes = await _selectedImage!.readAsBytes();
      
      await Supabase.instance.client.storage
          .from('lost-images') 
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt', 
              upsert: true, 
            ), 
          );
      
      // Get the URL to save in your database
      final imageUrl = Supabase.instance.client.storage
          .from('lost-images')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      // It's helpful to throw the actual error message for debugging
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload Image first
      String? uploadedImageUrl;
      if (_selectedImage != null) {
         uploadedImageUrl = await _uploadImage(widget.userId.toString());
      }
      
      // Combine location and date into description since schema doesn't have specific columns for them
      // Schema: post_id, user_id, post_type, item_name, description, image_url, status, created_at, security_question, security_answer
      final fullDescription = "${_descriptionController.text}\n\nLocation: ${_locationController.text}\nDate: ${_dateController.text}";

      await _postsDb.createPost({
        'post_type': 'LOST',
        'item_name': _nameController.text,
        'description': fullDescription,
        'image_url': uploadedImageUrl,
        'security_question': null, // No security question for Lost items (or optional)
        'security_answer': null,
        'image_url': uploadedImageUrl,
        'security_question': null, // No security question for Lost items (or optional)
        'security_answer': null,
        'latitude': _latitude,
        'longitude': _longitude,
        'reward': _rewardController.text.isNotEmpty ? _rewardController.text : null, // Add reward to payload
      }, widget.userId);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lost item reported successfully!")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFD5316B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Lost Item"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Item Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: "Location Lost"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _gettingLocation ? null : _getCurrentLocation,
                    icon: _gettingLocation 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.my_location, color: _latitude != null ? Colors.green : Colors.grey),
                    tooltip: "Get Current Location",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date Lost (YYYY-MM-DD)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateController.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rewardController,
                decoration: const InputDecoration(
                  labelText: "Reward (Optional)",
                  hintText: "e.g. ₹500 or 'Chocolates'",
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 12),
              // Image Picker UI
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedImage != null)
                Text("Selected: ${_selectedImage!.name}", style: const TextStyle(color: Colors.green)),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
