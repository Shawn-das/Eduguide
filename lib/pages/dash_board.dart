import 'package:flutter/material.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFE3F2FD), // light bluish background
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔹 Header with logo & user info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.school, color: Colors.white, size: 48),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eduguide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'student@example.com',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Card Grid (2 per row)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _dashboardCard(context, 'Home', Icons.home, '/home'),
                _dashboardCard(context, 'Profile', Icons.person, '/profile'),
                _dashboardCard(
                  context,
                  'University',
                  Icons.account_balance,
                  '/university',
                ),
                _dashboardCard(context, 'Courses', Icons.school, '/courses'),
                _dashboardCard(
                  context,
                  'AI Prediction',
                  Icons.psychology,
                  '/ai',
                ),
                _dashboardCard(
                  context,
                  'Application Status',
                  Icons.track_changes,
                  '/status',
                ),
                _dashboardCard(context, 'Admin Forum', Icons.forum, '/forum'),
                _dashboardCard(context, 'About Us', Icons.info, '/about'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      height: 120,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, route);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF1976D2)),
              const SizedBox(height: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
