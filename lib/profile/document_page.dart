import 'dart:typed_data';
import 'package:eduguide/profile/custom_navigation.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  // FETCH DOCUMENTS 

  Future<void> fetchDocuments() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from("documents")
        .select()
        .eq("user_id", user.id)
        .order("created_at", ascending: false);

    setState(() {
      documents = response;
      isLoading = false;
    });
  }

  //  OPEN DOCUMENT 

  Future<void> openDocument(String filePath) async {
    try {
      final signedUrl = await supabase.storage
          .from("documents")
          .createSignedUrl(filePath, 60);

      final Uri url = Uri.parse(signedUrl);

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception("Could not launch document");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening file: $e")),
      );
    }
  }

  // DELETE DOCUMENT 

  Future<void> deleteDocument(Map<String, dynamic> doc) async {
    try {
      final filePath = doc["file_path"];
      final documentId = doc["id"];

      // Delete from storage bucket
      await supabase.storage
          .from("documents")
          .remove([filePath]);

      // Delete from database table
      await supabase
          .from("documents")
          .delete()
          .eq("id", documentId);

      await fetchDocuments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  //  DELETE CONFIRMATION

  void showDeleteDialog(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Document"),
          content: const Text(
              "Are you sure you want to delete this document?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await deleteDocument(doc);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  //  SHOW UPLOAD BOTTOM SHEET

  void showUploadBottomSheet() {
    String? selectedType;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select Document",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "Passport", child: Text("Passport")),
                      DropdownMenuItem(
                          value: "Transcript", child: Text("Transcript")),
                      DropdownMenuItem(value: "CV", child: Text("CV")),
                      DropdownMenuItem(
                          value: "IELTS", child: Text("IELTS Result")),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon:
                            const Icon(Icons.insert_drive_file),
                        label: const Text("File"),
                        onPressed: () {
                          pickAndUploadFile(selectedType);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Camera"),
                        onPressed: () {
                          pickAndUploadFile(selectedType,
                              fromCamera: true);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child: const Text("Cancel")),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // FILE UPLOAD 

  Future<void> pickAndUploadFile(String? docType,
      {bool fromCamera = false}) async {
    final user = supabase.auth.currentUser;
    if (user == null || docType == null) return;

    Uint8List? fileBytes;
    String fileName = "";

    try {
      if (fromCamera) {
        final picker = ImagePicker();
        final image =
            await picker.pickImage(source: ImageSource.camera);

        if (image == null) return;

        fileBytes = await image.readAsBytes();
        fileName = image.name;
      } else {
        final result =
            await FilePicker.platform.pickFiles(
                withData: true);

        if (result == null) return;

        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;
      }

      final filePath = "${user.id}/$fileName";

      await supabase.storage
          .from("documents")
          .uploadBinary(filePath, fileBytes!);

      await supabase.from("documents").insert({
        "user_id": user.id,
        "document_type": docType,
        "file_name": fileName,
        "file_path": filePath,
      });

      Navigator.pop(context);
      await fetchDocuments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
  }

  //  UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text('Eduguide'),
        actions: [
          IconButton(
            icon: const Icon(
                Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const ProfilePage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showUploadBottomSheet,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : documents.isEmpty
              ? const Center(
                  child: Text("No records found"))
              : ListView.builder(
                  itemCount: documents.length,
                  itemBuilder:
                      (context, index) {
                    final doc = documents[index];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6),
                      child: ListTile(
                        leading: const Icon(
                            Icons.description),
                        title: Text(
                            doc["document_type"] ??
                                ""),
                        subtitle: Text(
                            doc["file_name"] ?? ""),
                        onTap: () {
                          openDocument(
                              doc["file_path"]);
                        },
                        trailing:
                            PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value ==
                                "delete") {
                              showDeleteDialog(
                                  doc);
                            }
                          },
                          itemBuilder:
                              (context) => const [
                            PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color:
                                          Colors.red),
                                  SizedBox(width: 8),
                                  Text("Delete"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: 2),
    );
  }
}
