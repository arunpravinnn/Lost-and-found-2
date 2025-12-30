import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}
const String authSupabaseUrl = "https://etdewmgrpvoavevlpibg.supabase.co";
class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _claimed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyClaimed();
  }

  Future<void> _checkIfAlreadyClaimed() async {
    try {
      final supabase = SupabaseClient(
        authSupabaseUrl,
        dotenv.env['SUPABASE_ANON_KEY']!
      );

      final response = await supabase
          .from("Lost_items")
          .select("claimed")
          .eq("item_id", widget.item["item_id"])
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _claimed = response != null && response["claimed"] == true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _claimItem(String answer) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("You must be logged in to claim the item");
    }

    // 🔐 Store answer temporarily in JWT metadata (used by RLS)
    await supabase.auth.updateUser(
      UserAttributes(data: {"answer": answer}),
    );

    final result = await supabase
        .from("Lost_items")
        .update({
          "claimed": true,
          "claimed_by": user.email,
          "claimed_at": DateTime.now().toIso8601String(),
        })
        .eq("item_id", widget.item["item_id"]);

    if (result.isEmpty) {
      throw Exception("Incorrect answer or item already claimed");
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: Image.asset(
            "assets/logo.png"
          ),
        ),
        backgroundColor: const Color(0xFFD5316B),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Container(
                    width: double.infinity,
                    height: 320,
                    color: Colors.white,
                    child: widget.item["image_url"] != null
                        ? Image.network(
                            widget.item["image_url"],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Item Name & Status Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item["item_name"] ?? "Unnamed Item",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (_claimed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Claimed',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          "Date Found",
                          widget.item["date_lost"],
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          Icons.person_outline,
                          "Reported By",
                          widget.item["reported_by_name"],
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          Icons.badge_outlined,
                          "Roll Number",
                          widget.item["reported_by_roll"],
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          "Location Found",
                          widget.item["location_lost"],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Claim Section
                  if (!_claimed)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue[100]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Is this your item?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'If this item belongs to you, click the button below and answer the security question to claim it.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[800],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showClaimDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD5316B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified_user, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Claim This Item',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.toString() ?? "Not available",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.grey[200],
        height: 1,
      ),
    );
  }

  void _showClaimDialog(BuildContext context) {
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            SizedBox(width: 12),
            Text(
              'Security Verification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.pink,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Question',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item["security_question"] ?? "No question set",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.brown,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: "Your Answer",
                hintText: "Enter your answer here",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final answer = answerController.text.trim();

              if (answer.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Please enter an answer"),
                    backgroundColor: Colors.red[700],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                return;
              }

              final supabase = Supabase.instance.client;

              try {
                final response = await supabase
                    .from("Lost_items")
                    .select("answer")
                    .eq("item_id", widget.item["item_id"])
                    .maybeSingle();

                if (response == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Error: Item not found"),
                        backgroundColor: Colors.red[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                  return;
                }

                final correctAnswer = response["answer"];

                if (answer.toLowerCase() == correctAnswer.toLowerCase()) {
                  final user = supabase.auth.currentUser;

                  if (user == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("You must be logged in to claim"),
                          backgroundColor: Colors.red[700],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  final claimedByText =
                      user.email ?? user.userMetadata?["name"] ?? user.id;

                  await supabase.from("Lost_items").update({
                    "claimed": true,
                    "claimed_by": claimedByText,
                  }).eq("item_id", widget.item["item_id"]);

                  setState(() {
                    _claimed = true;
                  });

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text("Item successfully claimed!"),
                          ],
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Incorrect answer. Please try again."),
                        backgroundColor: Colors.red[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD5316B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}