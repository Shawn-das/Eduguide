import 'package:flutter/material.dart';

class AIPredictionPage extends StatelessWidget {
  const AIPredictionPage({super.key});

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
          Center(child: Text("Ai Prediction Page",style: TextStyle(color: Colors.black,fontSize: 30.0),))
        ],
      ),
    );
  }
}