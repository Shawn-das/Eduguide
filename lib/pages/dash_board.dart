import 'package:eduguide/admin/admin_login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 

// Profile Model

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String? dob;
  final String? address;
  final String? country;
  final String? role;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.dob,
    this.address,
    this.country,
    this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id']?.toString() ?? '',
        fullName: m['full_name'] ?? 'User',
        email: m['email'] ?? '',
        phone: m['phone'],
        gender: m['gender'],
        dob: m['dob'],
        address: m['address'],
        country: m['country'],
        role: m['role'],
      );

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }
}

// Dashboard Drawer

class DashboardDrawer extends StatefulWidget {
  const DashboardDrawer({super.key});

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer>
    with SingleTickerProviderStateMixin {
  UserProfile? _profile;
  bool _loading = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  
  static const Color _navy = Color(0xFF0D1F5C);
 // static const Color _blue = Color(0xFF1565C0);
  static const Color _sky = Color(0xFF1E88E5);
  //static const Color _accent = Color(0xFF00B0FF);
  static const Color _surface = Color(0xFFF0F4FF);
  //static const Color _cardBg = Colors.white;

  // Nav items 
  static const List<_NavItem> _items = [
    _NavItem('Home', Icons.home_rounded, '/home', _sky),
    _NavItem('Profile', Icons.person_rounded, '/profile', Color(0xFF7C3AED)),
    _NavItem('Universities', Icons.account_balance_rounded, '/university', Color(0xFF0F766E)),
    _NavItem('Courses', Icons.menu_book_rounded, '/courses', Color(0xFFD97706)),
    _NavItem('AI Prediction', Icons.auto_awesome_rounded, '/ai', Color(0xFFE11D48)),
    _NavItem('Application Status', Icons.track_changes_rounded, '/status', Color(0xFF059669)),
    _NavItem('Admin', Icons.admin_panel_settings_rounded, '__admin__', Color(0xFF9333EA)),
    _NavItem('About Us', Icons.info_rounded, '/about', Color(0xFF64748B)),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadProfile();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final res = await Supabase.instance.client
            .from('profile')
            .select()
            .eq('id', userId)
            .single();
        setState(() {
          _profile = UserProfile.fromMap(res);
          _loading = false;
        });
      } else {
        // Fallback: load by email or first row (for testing)
        final res = await Supabase.instance.client
            .from('profile')
            .select()
            .limit(1)
            .single();
        setState(() {
          _profile = UserProfile.fromMap(res);
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
    _animCtrl.forward();
  }

  void _onItemTap(_NavItem item) {
    Navigator.pop(context);
    if (item.route == '__admin__') {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AdminLoginPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      Navigator.pushNamed(context, item.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenW * 0.82,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
        ),
        child: Column(
          children: [
            
            _ProfileHeader(profile: _profile, loading: _loading),
            
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section label
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'NAVIGATION',
                          style: TextStyle(
                            color: _navy.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      // 2-column grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: _items
                            .map((item) => _NavCard(
                                  item: item,
                                  onTap: () => _onItemTap(item),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Header

class _ProfileHeader extends StatelessWidget {
  final UserProfile? profile;
  final bool loading;

  const _ProfileHeader({required this.profile, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1F5C), Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row — logo + close
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'EduGuide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

            
                Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white38, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          profile?.initials ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.fullName ?? 'Welcome!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}



// Nav Card

class _NavItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  const _NavItem(this.title, this.icon, this.route, this.color);
}

class _NavCard extends StatefulWidget {
  final _NavItem item;
  final VoidCallback onTap;

  const _NavCard({required this.item, required this.onTap});

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isAdmin = item.route == '__admin__';

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isAdmin
                  ? item.color.withOpacity(0.3)
                  : Colors.transparent,
              width: isAdmin ? 1.5 : 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isAdmin ? item.color : const Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isAdmin) ...[
                const SizedBox(height: 3),
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
