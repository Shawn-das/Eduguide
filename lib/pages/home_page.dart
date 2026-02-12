import 'package:eduguide/pages/dash_borad.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

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

      // ✅ CARD-STYLE DASHBOARD DRAWER
      drawer: const Drawer(child: DashboardDrawer()),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Your Dream Study Destination',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Explore courses, universities & scholarships',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Search courses, universities...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _QuickCard(
                    icon: Icons.school_outlined,
                    title: 'Courses',
                    color: Color(0xFF42A5F5),
                  ),
                  _QuickCard(
                    icon: Icons.account_balance_outlined,
                    title: 'Universities',
                    color: Color(0xFF1976D2),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Popular Destinations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _DestinationCard(
                      country: 'Australia',
                      imagePlaceholderColor: Colors.orange,
                    ),
                    _DestinationCard(
                      country: 'Canada',
                      imagePlaceholderColor: Colors.red,
                    ),
                    _DestinationCard(
                      country: 'UK',
                      imagePlaceholderColor: Colors.blueGrey,
                    ),
                    _DestinationCard(
                      country: 'Germany',
                      imagePlaceholderColor: Colors.black26,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= HELPER WIDGETS =================

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: SizedBox(
          width: 140,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final String country;
  final Color imagePlaceholderColor;

  const _DestinationCard({
    required this.country,
    required this.imagePlaceholderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: imagePlaceholderColor.withOpacity(0.4)),
              Center(
                child: Text(
                  country,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
