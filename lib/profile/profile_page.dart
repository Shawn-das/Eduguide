import 'package:eduguide/authentication/login_page.dart';
import 'package:eduguide/profile/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LogIn()),
      (route) => false,
    );
  }

  Future<void> deleteAccount() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to permanently delete your account?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete profile data
      await supabase.from('profiles').delete().eq('id', user.id);

      // Delete qualifications
      await supabase.from('qualifications').delete().eq('user_id', user.id);

      // Delete exam scores
      await supabase.from('exam_scores').delete().eq('user_id', user.id);

      // Logout
      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LogIn()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting account: $e")));
    }
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      profileData = data;
      isLoading = false;
    });
  }

  Future<void> updateField(String field, String value) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').update({field: value}).eq('id', user.id);

    fetchProfile();
  }

  void showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateField(field, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
    bool editable = false,
    String? fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffEEF2FF),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Not set" : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (editable)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => showEditDialog(fieldName!, value),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                profileData?['full_name'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profileData?['full_name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            /// EMAIL (NOT EDITABLE)
            infoTile(
              icon: Icons.email_outlined,
              label: "Email",
              value: profileData?['email'] ?? '',
            ),

            /// PHONE
            infoTile(
              icon: Icons.phone,
              label: "Phone",
              value: profileData?['phone'] ?? '',
              editable: true,
              fieldName: 'phone',
            ),

            const Divider(),

            infoTile(
              icon: Icons.male,
              label: "Gender",
              value: profileData?['gender'] ?? '',
              editable: true,
              fieldName: 'gender',
            ),

            infoTile(
              icon: Icons.calendar_month,
              label: "Date of Birth",
              value: profileData?['dob']?.toString() ?? '',
              editable: true,
              fieldName: 'dob',
            ),

            infoTile(
              icon: Icons.location_on,
              label: "Address",
              value: profileData?['address'] ?? '',
              editable: true,
              fieldName: 'address',
            ),

            infoTile(
              icon: Icons.public,
              label: "Country",
              value: profileData?['country'] ?? '',
              editable: true,
              fieldName: 'country',
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),

            Row(
              children: [
                /// LOGOUT BUTTON
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: logout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// DELETE BUTTON
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: deleteAccount,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text(
                      "Delete",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
