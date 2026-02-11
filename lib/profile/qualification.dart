import 'package:eduguide/profile/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QualificationPage extends StatefulWidget {
  const QualificationPage({super.key});

  @override
  State<QualificationPage> createState() => _QualificationPageState();
}

class _QualificationPageState extends State<QualificationPage> {
  final supabase = Supabase.instance.client;

  String? recordId;
  String? selectedQualification;

  final year = TextEditingController();
  final percentage = TextEditingController();
  final stream = TextEditingController();
  final backlog = TextEditingController();

  List qualificationList = [];

  final qualifications = ['SSC', 'HSC', 'Diploma', 'Bachelor', 'Master'];

  @override
  void initState() {
    super.initState();
    fetchQualifications();
  }

  // ---------------- FETCH ----------------
  Future<void> fetchQualifications() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('qualifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      qualificationList = data;
    });
  }

  // ---------------- CLEAR FORM ----------------
  void clearForm() {
    recordId = null;
    selectedQualification = null;
    year.clear();
    percentage.clear();
    stream.clear();
    backlog.clear();
  }

  // ---------------- ADD ----------------
  Future<void> addQualification() async {
    final user = supabase.auth.currentUser;
    if (user == null || selectedQualification == null) return;

    await supabase.from('qualifications').insert({
      'user_id': user.id,
      'qualification': selectedQualification,
      'year': int.tryParse(year.text),
      'percentage': double.tryParse(percentage.text),
      'stream': stream.text,
      'backlog': int.tryParse(backlog.text),
    });

    clearForm();
    fetchQualifications();
  }

  // ---------------- UPDATE ----------------
  Future<void> updateQualification() async {
    if (recordId == null) return;

    await supabase.from('qualifications').update({
      'year': int.tryParse(year.text),
      'percentage': double.tryParse(percentage.text),
      'stream': stream.text,
      'backlog': int.tryParse(backlog.text),
    }).eq('id', recordId!);

    clearForm();
    fetchQualifications();
  }

  // ---------------- DELETE ----------------
  Future<void> deleteQualification(String id) async {
    await supabase.from('qualifications').delete().eq('id', id);
    fetchQualifications();
  }

  // ---------------- INPUT FIELD ----------------
  Widget inputBox(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: "Enter $label",
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Qualifications"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- FORM ----------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Qualification Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedQualification,
                    hint: const Text("Select Qualification"),
                    items: qualifications
                        .map((q) =>
                            DropdownMenuItem(value: q, child: Text(q)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => selectedQualification = v);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: inputBox(
                          "Year",
                          year,
                          type: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: inputBox(
                          "Percentage",
                          percentage,
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: inputBox("Stream", stream)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: inputBox(
                          "Backlog",
                          backlog,
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          recordId == null ? addQualification : updateQualification,
                      child: Text(recordId == null ? "Add Qualification" : "Update Qualification"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ---------------- LIST ----------------
            Expanded(
              child: ListView.builder(
                itemCount: qualificationList.length,
                itemBuilder: (context, index) {
                  final q = qualificationList[index];

                  return Card(
                    child: ListTile(
                      title: Text(q['qualification']),
                      subtitle: Text(
                        "Year: ${q['year']} | %: ${q['percentage']} | Stream: ${q['stream']} | Backlog: ${q['backlog']}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                recordId = q['id'];
                                selectedQualification = q['qualification'];
                                year.text = q['year']?.toString() ?? '';
                                percentage.text =
                                    q['percentage']?.toString() ?? '';
                                stream.text = q['stream'] ?? '';
                                backlog.text = q['backlog']?.toString() ?? '';
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteQualification(q['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

     bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
