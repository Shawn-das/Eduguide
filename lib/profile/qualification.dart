import 'package:eduguide/profile/custom_navigation.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QualificationPage extends StatefulWidget {
  const QualificationPage({super.key});

  @override
  State<QualificationPage> createState() => _QualificationPageState();
}

class _QualificationPageState extends State<QualificationPage> {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();

  String? recordId;
  String? selectedQualification;

  final year = TextEditingController();
  final cgpa = TextEditingController();
  final stream = TextEditingController();
  final backlog = TextEditingController();

  List qualificationList = [];

  final qualifications = ['SSC', 'HSC', 'Diploma', 'Bachelor', 'Master'];

  @override
  void initState() {
    super.initState();
    fetchQualifications();
  }

  // FETCH 
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

  //  CLEAR FORM 
  void clearForm() {
    recordId = null;
    selectedQualification = null;
    year.clear();
    cgpa.clear();
    stream.clear();
    backlog.clear();
    setState(() {});
  }

  //  VALIDATE CGPA 
  String? validateCgpa(String? value) {
    if (value == null || value.isEmpty) {
      return "CGPA is required";
    }

    final parsed = double.tryParse(value);
    if (parsed == null) {
      return "Enter valid CGPA";
    }

 
    if (parsed < 0 || parsed > 5) {
      return "CGPA must be between 0 - 5.0";
    }

    return null;
  }

  // ADD 
  Future<void> addQualification() async {
    if (!_formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;
    if (user == null || selectedQualification == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select qualification")),
      );
      return;
    }

    await supabase.from('qualifications').insert({
      'user_id': user.id,
      'qualification': selectedQualification,
      'year': int.tryParse(year.text),
      'cgpa': double.tryParse(cgpa.text),
      'stream': stream.text,
      'backlog': int.tryParse(backlog.text),
    });

    clearForm();
    fetchQualifications();
  }

  // UPDATE
  Future<void> updateQualification() async {
    if (!_formKey.currentState!.validate()) return;
    if (recordId == null) return;

    await supabase.from('qualifications').update({
      'year': int.tryParse(year.text),
      'cgpa': double.tryParse(cgpa.text),
      'stream': stream.text,
      'backlog': int.tryParse(backlog.text),
    }).eq('id', recordId!);

    clearForm();
    fetchQualifications();
  }

  // DELETE 
  Future<void> deleteQualification(String id) async {
    await supabase.from('qualifications').delete().eq('id', id);
    fetchQualifications();
  }

  // INPUT FIELD 
  Widget inputBox(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validator,
      inputFormatters: inputFormatters,
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
        backgroundColor: Colors.blue[300],
        title: const Text('Eduguide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FORM 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
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
                      validator: (value) =>
                          value == null ? "Select qualification" : null,
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
                            "CGPA",
                            cgpa,
                            type: const TextInputType.numberWithOptions(decimal: true),
                            validator: validateCgpa,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
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
                        onPressed: recordId == null
                            ? addQualification
                            : updateQualification,
                        child: Text(recordId == null
                            ? "Add Qualification"
                            : "Update Qualification"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              //  LIST 
              Expanded(
                child: ListView.builder(
                  itemCount: qualificationList.length,
                  itemBuilder: (context, index) {
                    final q = qualificationList[index];

                    return Card(
                      child: ListTile(
                        title: Text(q['qualification']),
                        subtitle: Text(
                          "Year: ${q['year']} | CGPA: ${q['cgpa']} | Stream: ${q['stream']} | Backlog: ${q['backlog']}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  recordId = q['id'];
                                  selectedQualification =
                                      q['qualification'];
                                  year.text =
                                      q['year']?.toString() ?? '';
                                  cgpa.text =
                                      q['cgpa']?.toString() ?? '';
                                  stream.text = q['stream'] ?? '';
                                  backlog.text =
                                      q['backlog']?.toString() ?? '';
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  deleteQualification(q['id']),
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
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}