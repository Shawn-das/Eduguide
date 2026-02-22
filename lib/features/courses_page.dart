import 'package:flutter/material.dart';

class CoursesPage extends StatelessWidget {
  final List<Map<String, dynamic>> courses;

  const CoursesPage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses for You'),
        backgroundColor: Colors.blue[300],
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text(
                'No courses match your profile',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(course['name'] ?? 'Course Name'),
                    subtitle: Text(course['description'] ?? 'Description'),
                  ),
                );
              },
            ),
    );
  }
}
