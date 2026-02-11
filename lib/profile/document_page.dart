import 'dart:io';
import 'package:eduguide/profile/custom_navigation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final supabase = Supabase.instance.client;
  List documents = [];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('documents')
        .select()
        .eq('user_id', user.id)
        .order('created_at');

    setState(() => documents = data);
  }

  Future<void> addDocument() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final filePath = '${user.id}/$fileName';

    await supabase.storage.from('documents').upload(filePath, file);

    await supabase.from('documents').insert({
      'user_id': user.id,
      'name': fileName,
      'file_path': filePath,
    });

    fetchDocuments();
  }

  Future<void> deleteDocument(String id, String path) async {
    await supabase.storage.from('documents').remove([path]);
    await supabase.from('documents').delete().eq('id', id);
    fetchDocuments();
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, size: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Documents",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("${documents.length} Items"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Files",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.more_vert),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: documents.isEmpty
                  ? const Center(child: Text("No records found"))
                  : ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.insert_drive_file),
                                  const SizedBox(width: 10),
                                  Text(doc['name']),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    deleteDocument(doc['id'], doc['file_path']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: addDocument,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
     
    );
  }
}
