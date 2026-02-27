import 'package:eduguide/profile/custom_navigation.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final supabase = Supabase.instance.client;

  String? editingExam;
  Map<String, dynamic>? existingScores;

  //             CONTROLLERS 

  // IELTS
  final ieltsOverall = TextEditingController();
  final ieltsReading = TextEditingController();
  final ieltsWriting = TextEditingController();
  final ieltsListening = TextEditingController();
  final ieltsSpeaking = TextEditingController();

  // GRE
  final greOverall = TextEditingController();
  final greVerbal = TextEditingController();
  final greQuant = TextEditingController();
  final greAnalytical = TextEditingController();

  // TOEFL
  final toeflOverall = TextEditingController();
  final toeflReading = TextEditingController();
  final toeflWriting = TextEditingController();
  final toeflListening = TextEditingController();
  final toeflSpeaking = TextEditingController();

  // GMAT
  final gmatOverall = TextEditingController();
  final gmatVerbal = TextEditingController();
  final gmatQuant = TextEditingController();
  final gmatAwa = TextEditingController();
  final gmatIr = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchScores();
  }

  @override
  void dispose() {
    ieltsOverall.dispose();
    ieltsReading.dispose();
    ieltsWriting.dispose();
    ieltsListening.dispose();
    ieltsSpeaking.dispose();

    greOverall.dispose();
    greVerbal.dispose();
    greQuant.dispose();
    greAnalytical.dispose();

    toeflOverall.dispose();
    toeflReading.dispose();
    toeflWriting.dispose();
    toeflListening.dispose();
    toeflSpeaking.dispose();

    gmatOverall.dispose();
    gmatVerbal.dispose();
    gmatQuant.dispose();
    gmatAwa.dispose();
    gmatIr.dispose();

    super.dispose();
  }

 Future<void> fetchScores() async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

 final response = await supabase
    .from('exam_scores')
    .select()
    .eq('user_id', user.id) as List<dynamic>;


  final dataMap = {
    for (var item in response) item['exam_type']: item
  };

  setState(() {
    existingScores = dataMap.cast<String, dynamic>();
  });

  //IELTS
  if (dataMap["IELTS"] != null) {
    final d = dataMap["IELTS"];
    ieltsOverall.text = d["overall"]?.toString() ?? "";
    ieltsReading.text = d["reading"]?.toString() ?? "";
    ieltsWriting.text = d["writing"]?.toString() ?? "";
    ieltsListening.text = d["listening"]?.toString() ?? "";
    ieltsSpeaking.text = d["speaking"]?.toString() ?? "";
  }

  //GRE
  if (dataMap["GRE"] != null) {
    final d = dataMap["GRE"];
    greOverall.text = d["overall"]?.toString() ?? "";
    greVerbal.text = d["verbal"]?.toString() ?? "";
    greQuant.text = d["quantitative"]?.toString() ?? "";
    greAnalytical.text = d["analytical"]?.toString() ?? "";
  }

  // TOEFL 
  if (dataMap["TOEFL"] != null) {
    final d = dataMap["TOEFL"];
    toeflOverall.text = d["overall"]?.toString() ?? "";
    toeflReading.text = d["reading"]?.toString() ?? "";
    toeflWriting.text = d["writing"]?.toString() ?? "";
    toeflListening.text = d["listening"]?.toString() ?? "";
    toeflSpeaking.text = d["speaking"]?.toString() ?? "";
  }

  // GMAT 
  if (dataMap["GMAT"] != null) {
    final d = dataMap["GMAT"];
    gmatOverall.text = d["overall"]?.toString() ?? "";
    gmatVerbal.text = d["verbal"]?.toString() ?? "";
    gmatQuant.text = d["quantitative"]?.toString() ?? "";
    gmatAwa.text = d["awa"]?.toString() ?? "";
    gmatIr.text = d["ir"]?.toString() ?? "";
  }
}

  Future<void> saveScore(String examType, Map<String, dynamic> data) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    data['user_id'] = user.id;
    data['exam_type'] = examType;

    await supabase.from('exam_scores').upsert(data);

    await fetchScores();

    setState(() {
      editingExam = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved successfully")),
    );
  }

  Widget buildExamCard(String title, Widget form) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      editingExam =
                          editingExam == title ? null : title;
                    });
                  },
                )
              ],
            ),
            if (editingExam == title) form
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget buildRowField(
      String label1,
      TextEditingController controller1,
      String label2,
      TextEditingController controller2) {
    return Row(
      children: [
        Expanded(child: buildTextField(label1, controller1)),
        Expanded(child: buildTextField(label2, controller2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text('Eduguide'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // IELTS
            buildExamCard(
              "IELTS",
              Column(
                children: [
                  buildTextField("Overall", ieltsOverall),
                  buildRowField("Listening", ieltsListening,
                      "Reading", ieltsReading),
                  buildRowField("Writing", ieltsWriting,
                      "Speaking", ieltsSpeaking),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        saveScore("IELTS", {
                          "overall": double.tryParse(ieltsOverall.text),
                          "reading": double.tryParse(ieltsReading.text),
                          "writing": double.tryParse(ieltsWriting.text),
                          "listening":
                              double.tryParse(ieltsListening.text),
                          "speaking":
                              double.tryParse(ieltsSpeaking.text),
                        });
                      },
                      child: const Text("Save"),
                    ),
                  )
                ],
              ),
            ),

            // GRE
            buildExamCard(
              "GRE",
              Column(
                children: [
                  buildTextField("Overall", greOverall),
                  buildRowField("Analytical", greAnalytical,
                      "Verbal", greVerbal),
                  buildTextField("Quantitative", greQuant),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        saveScore("GRE", {
                          "overall": double.tryParse(greOverall.text),
                          "verbal": double.tryParse(greVerbal.text),
                          "quantitative":
                              double.tryParse(greQuant.text),
                          "analytical":
                              double.tryParse(greAnalytical.text),
                        });
                      },
                      child: const Text("Save"),
                    ),
                  )
                ],
              ),
            ),

            // TOEFL
            buildExamCard(
              "TOEFL",
              Column(
                children: [
                  buildTextField("Overall", toeflOverall),
                  buildRowField("Listening", toeflListening,
                      "Reading", toeflReading),
                  buildRowField("Writing", toeflWriting,
                      "Speaking", toeflSpeaking),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        saveScore("TOEFL", {
                          "overall": double.tryParse(toeflOverall.text),
                          "reading": double.tryParse(toeflReading.text),
                          "writing": double.tryParse(toeflWriting.text),
                          "listening":
                              double.tryParse(toeflListening.text),
                          "speaking":
                              double.tryParse(toeflSpeaking.text),
                        });
                      },
                      child: const Text("Save"),
                    ),
                  )
                ],
              ),
            ),

            // GMAT
            buildExamCard(
              "GMAT",
              Column(
                children: [
                  buildTextField("Overall", gmatOverall),
                  buildRowField("AWA", gmatAwa,
                      "IR", gmatIr),
                  buildRowField("Quantitative", gmatQuant,
                      "Verbal", gmatVerbal),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        saveScore("GMAT", {
                          "overall": double.tryParse(gmatOverall.text),
                          "verbal": double.tryParse(gmatVerbal.text),
                          "quantitative":
                              double.tryParse(gmatQuant.text),
                          "awa": double.tryParse(gmatAwa.text),
                          "ir": double.tryParse(gmatIr.text),
                        });
                      },
                      child: const Text("Save"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}