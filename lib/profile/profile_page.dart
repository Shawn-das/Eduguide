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

  // Just signOut, AuthGate handles navigation automatically
  Future<void> logout() async {
    await supabase.auth.signOut();
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

      //Just signOut, AuthGate handles navigation automatically
      await supabase.auth.signOut();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
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

  void showEditDialog(String field, String currentValue) async {
    final controller = TextEditingController(text: currentValue);

    Widget inputWidget;

    if (field == "phone") {
      inputWidget = TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          hintText: "Enter your phone number",
          border: OutlineInputBorder(),
        ),
      );
    } else if (field == "gender") {
      String selectedGender = currentValue.isNotEmpty ? currentValue : "Male";

      inputWidget = StatefulBuilder(
        builder: (context, setStateDialog) {
          return DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: ["Male", "Female", "Other"]
                .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                .toList(),
            onChanged: (value) {
              setStateDialog(() {
                selectedGender = value!;
                controller.text = selectedGender;
              });
            },
          );
        },
      );

      controller.text = selectedGender;
    } else if (field == "dob") {
      inputWidget = TextField(
        controller: controller,
        readOnly: true,
        decoration: const InputDecoration(
          hintText: "Select Date of Birth",
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            controller.text = pickedDate.toIso8601String().split("T").first;
          }
        },
      );
    } else if (field == "country") {
      List<String> countries = [
        "United States",
        "United Kingdom",
        "Canada",
        "Australia",
        "India",
        "Nigeria",
        "Germany",
        "France",
        "China",
        "Japan",
        "Bangladesh",
        "Nepal",
        "Pakistan",
      ];

      String selectedCountry =
          currentValue.isNotEmpty ? currentValue : countries.first;
      controller.text = selectedCountry;

      inputWidget = StatefulBuilder(
        builder: (context, setState) {
          return DropdownButtonFormField<String>(
            value: selectedCountry,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: countries
                .map((country) =>
                    DropdownMenuItem(value: country, child: Text(country)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCountry = value!;
                controller.text = selectedCountry;
              });
            },
          );
        },
      );
    } else {
      inputWidget = TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Enter your address",
          border: OutlineInputBorder(),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit ${field[0].toUpperCase()}${field.substring(1)}"),
        content: inputWidget,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateField(field, controller.text);
              if (!mounted) return;
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            infoTile(
              icon: Icons.email_outlined,
              label: "Email",
              value: profileData?['email'] ?? '',
            ),

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

            Row(
              children: [
                // LOGOUT BUTTON
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

                // DELETE BUTTON
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
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}