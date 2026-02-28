import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'university_tab.dart';
import 'course_tab.dart';

// CONSTANTS (shared across all admin files)

final supabase = Supabase.instance.client;

const Color kPrimary = Color(0xFF1A237E);
const Color kAccent  = Color(0xFF00B0FF);
const Color kSurface = Color(0xFFF0F4FF);


// ADMIN DASHBOARD PAGE


class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _logout() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, color: kAccent, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EduGuide Admin',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Data Management Portal',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: kAccent,
          indicatorWeight: 3,
          labelColor: kAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance, size: 20), text: 'Universities'),
            Tab(icon: Icon(Icons.menu_book, size: 20), text: 'Courses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          UniversityManagementTab(),
          CourseManagementTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tab.index == 0) {
            showUniversityFormSheet(context, null, () => setState(() {}));
          } else {
            showCourseFormSheet(context, null, () => setState(() {}));
          }
        },
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tab.index == 0 ? 'Add University' : 'Add Course',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
