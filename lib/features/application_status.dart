import 'package:flutter/material.dart';

class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

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
          Center(child: Text("Application Status page",style: TextStyle(color: Colors.black,fontSize: 30.0),))
        ],
      ),
    );
  }
}