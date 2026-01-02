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

final SupabaseClient supabase = SupabaseClient(
  authSupabaseUrl,
  dotenv.env['SUPABASE_ANON_KEY']!,
);

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _claimed = false;
  bool _isLoading = true;
  bool _alreadyRequested = false;

  @override
  void initState() {
    super.initState();
    _checkClaimStatus();
  }

  /// 🔍 Check if item already claimed OR user already requested
  Future<void> _checkClaimStatus() async {
    try {
      // Check if item already claimed
      final itemRes = await supabase
          .from("Lost_items")
          .select("claimed")
          .eq("item_id", widget.item["item_id"])
          .maybeSingle();

      final user = supabase.auth.currentUser;

      // Check if this user already submitted a claim
      if (user != null) {
        final claimRes = await supabase
            .from("claim_requests")
            .select("id")
            .eq("item_id", widget.item["item_id"])
            .eq("user_id", user.id)
            .maybeSingle();

        _alreadyRequested = claimRes != null;
      }

      if (!mounted) return;

      setState(() {
        _claimed = itemRes != null && itemRes["claimed"] == true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// 📤 Submit claim request (NO ANSWER VALIDATION)
  Future<void> _submitClaim(String answer) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("You must be logged in to claim the item");
    }

    await supabase.from("claim_requests").insert({
      "item_id": widget.item["item_id"],
      "user_id": user.id,
      "user_email": user.email,
      "answer": answer,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: Image.asset("assets/logo.png"),
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
                  // 🔹 Image Section (UNCHANGED)
                  Container(
                    width: double.infinity,
                    height: 320,
                    color: Colors.white,
                    child: widget.item["image_url"] != null
                        ? Image.network(
                            widget.item["image_url"],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported_outlined, size: 64),
                          )
                        : const Icon(Icons.image_outlined, size: 64),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Item Name & Status Badge (UNCHANGED)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item["item_name"] ?? "Unnamed Item",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_claimed)
                          const Chip(
                            label: Text("Claimed"),
                            backgroundColor: Color.fromARGB(255, 3, 153, 83),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Details Card (UNCHANGED)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.calendar_today, "Date Found", widget.item["date_lost"]),
                        _buildDivider(),
                        _buildInfoRow(Icons.person, "Reported By", widget.item["reported_by_name"]),
                        _buildDivider(),
                        _buildInfoRow(Icons.badge, "Roll Number", widget.item["reported_by_roll"]),
                        _buildDivider(),
                        _buildInfoRow(Icons.location_on, "Location Found", widget.item["location_lost"]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Claim Section (UI SAME, logic updated)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: _alreadyRequested
                        ? const Text(
                            "Claim request already submitted.\nAwaiting admin approval.",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Is this your item?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "If this item belongs to you, click the button below and answer the security question to request a claim.",
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _showClaimDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD5316B),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text(
                                    "Claim This Item",
                                    style: TextStyle(fontSize: 16),
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

  // ---------------- HELPERS (UNCHANGED UI) ----------------

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text("$label: ${value ?? '-'}")),
      ],
    );
  }

  Widget _buildDivider() =>
      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider());

  // ---------------- CLAIM DIALOG (LOGIC UPDATED) ----------------

  void _showClaimDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Security Question"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.item["security_question"] ?? "No question"),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Your Answer"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final answer = controller.text.trim();
              if (answer.isEmpty) return;

              try {
                await _submitClaim(answer);

                if (!mounted) return;

                setState(() => _alreadyRequested = true);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Claim request submitted. Await admin approval."),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You have already submitted a claim request."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
