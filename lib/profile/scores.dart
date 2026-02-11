import 'package:eduguide/profile/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExamScorePage extends StatefulWidget {
  const ExamScorePage({super.key});

  @override
  State<ExamScorePage> createState() => _ExamScorePageState();
}

class _ExamScorePageState extends State<ExamScorePage> {
  final supabase = Supabase.instance.client;

  bool showIelts = true;
  String? recordId;

  final overall = TextEditingController();
  final listening = TextEditingController();
  final reading = TextEditingController();
  final writing = TextEditingController();
  final speaking = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchIELTS();
  }

  Future<void> fetchIELTS() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('exam_scores')
        .select()
        .eq('user_id', user.id)
        .eq('exam', 'IELTS')
        .maybeSingle();

    if (data != null) {
      recordId = data['id'];
      overall.text = data['overall']?.toString() ?? '';
      listening.text = data['listening']?.toString() ?? '';
      reading.text = data['reading']?.toString() ?? '';
      writing.text = data['writing']?.toString() ?? '';
      speaking.text = data['speaking']?.toString() ?? '';
    }
  }

  Future<void> saveIELTS() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('exam_scores').upsert({
      'id': recordId,
      'user_id': user.id,
      'exam': 'IELTS',
      'overall': double.tryParse(overall.text),
      'listening': double.tryParse(listening.text),
      'reading': double.tryParse(reading.text),
      'writing': double.tryParse(writing.text),
      'speaking': double.tryParse(speaking.text),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("IELTS score saved")));
  }

  Future<void> deleteIELTS() async {
    if (recordId == null) return;

    await supabase.from('exam_scores').delete().eq('id', recordId!);

    setState(() {
      recordId = null;
      overall.clear();
      listening.clear();
      reading.clear();
      writing.clear();
      speaking.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("IELTS score deleted")));
  }

  Widget scoreField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter score",
            ),
          ),
        ],
      ),
    );
  }

  Widget collapsedTile(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("IELTS", style: TextStyle(fontSize: 18)),
          Icon(Icons.edit),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

     appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // IELTS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "IELTS",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: scoreField("IELTS SCORE", overall),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload),
                          label: const Text("Upload doc"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: scoreField("Listening", listening)),
                      const SizedBox(width: 12),
                      Expanded(child: scoreField("Reading", reading)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: scoreField("Writing", writing)),
                      const SizedBox(width: 12),
                      Expanded(child: scoreField("Speaking", speaking)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: deleteIELTS,
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: saveIELTS,
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            collapsedTile("GRE"),
            collapsedTile("TOEFL"),
            collapsedTile("GMAT"),
          ],
        ),
      ),

    bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
