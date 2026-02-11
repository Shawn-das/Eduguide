import 'package:flutter/material.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(child: Text("Courses Page",style: TextStyle(color: Colors.black,fontSize: 30.0),))
        ],
      ),
    );
  }
}