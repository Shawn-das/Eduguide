import 'package:flutter/material.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:eduguide/profile/qualification.dart';
import 'package:eduguide/profile/document_page.dart';
import 'package:eduguide/profile/scores.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const ProfilePage();
        break;
      case 1:
        page = const QualificationPage();
        break;
      case 2:
        page = const DocumentPage();
        break;
      case 3:
        page = const ScorePage();
        break;
      default:
        page = const ProfilePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => _navigate(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.person, "Profile", 0),
          _navItem(context, Icons.school, "Qualification", 1),
          _navItem(context, Icons.insert_drive_file, "Document", 2),
          _navItem(context, Icons.description, "Scores", 3),
        ],
      ),
    );
  }
}
