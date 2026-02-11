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

  String fullName = '';
  String email = '';

  // 🔹 DUMMY VALUES (replace later with another table)
  final String studentCode = "A1654";
  final String phoneNumber = "+88001708942877";
  final String gender = "Male";
  final String dob = "Not set";
  final String address = "Not set";
  final String country = "Bangladesh";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();

      setState(() {
        fullName = data['full_name'] ?? "No Name";
        email = user.email ?? "";
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
    bool editable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xffEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
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
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (editable) const Icon(Icons.edit, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// PROFILE IMAGE
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade300,
                        child: const Text(
                          "Eduguide",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// NAME
                  Text(
                    fullName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// STUDENT CODE
                  Text(
                    "Student Code : $studentCode",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  /// INFO SECTION
                  infoTile(
                    icon: Icons.email_outlined,
                    label: "Email",
                    value: email,
                  ),

                  infoTile(
                    icon: Icons.phone_outlined,
                    label: "Phone Number",
                    value: phoneNumber,
                  ),

                  const Divider(),

                  infoTile(
                    icon: Icons.male,
                    label: "Gender",
                    value: gender,
                    editable: true,
                  ),

                  infoTile(
                    icon: Icons.calendar_month,
                    label: "Date of birth",
                    value: dob,
                    editable: true,
                  ),

                  infoTile(
                    icon: Icons.location_on_outlined,
                    label: "Address",
                    value: address,
                    editable: true,
                  ),

                  infoTile(
                    icon: Icons.public,
                    label: "Country",
                    value: country,
                    editable: true,
                  ),

                  const SizedBox(height: 30),

                  /// DELETE ACCOUNT
                  ListTile(
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    title: const Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      // future delete logic
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

    
            bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
