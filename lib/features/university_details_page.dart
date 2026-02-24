import 'package:eduguide/features/courses_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SQL QUERIES — (All queries are already in find_university_page.dart)
// Additional queries used in this file:
//
// -- Fetch full university detail by id
// SELECT * FROM universities WHERE id = '<university_id>';
//
// -- Check if university is saved by current user
// SELECT id FROM saved_universities
// WHERE user_id = auth.uid() AND university_id = '<university_id>';
//
// -- Save a university
// INSERT INTO saved_universities (user_id, university_id)
// VALUES (auth.uid(), '<university_id>');
//
// -- Unsave a university
// DELETE FROM saved_universities
// WHERE user_id = auth.uid() AND university_id = '<university_id>';
//
// -- Get courses offered by this university (for View Courses button)
// SELECT * FROM courses WHERE university_name = '<university_name>'
// ORDER BY created_at DESC;
//
// ─────────────────────────────────────────────────────────────────────────────

class UniversityDetailPage extends StatefulWidget {
  final Map<String, dynamic> university;

  const UniversityDetailPage({super.key, required this.university});

  @override
  State<UniversityDetailPage> createState() =>
      _UniversityDetailPageState();
}

class _UniversityDetailPageState extends State<UniversityDetailPage>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  static const Color _primary = Color(0xFF1565C0);

  bool _isSaved = false;
  bool _isSaveLoading = false;
  bool _isDetailLoading = true;
  Map<String, dynamic> _detail = {};
  late TabController _tabController;

  final List<String> _tabs = [
    'Overview',
    'Programs',
    'Admission',
    'Campus',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _detail = Map<String, dynamic>.from(widget.university);
    _fetchFullDetail();
    _checkIfSaved();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Supabase Methods ────────────────────────────────────────────────────

  Future<void> _fetchFullDetail() async {
    try {
      final response = await _supabase
          .from('universities')
          .select('*')
          .eq('id', widget.university['id'])
          .single();
      setState(() {
        _detail = Map<String, dynamic>.from(response);
        _isDetailLoading = false;
      });
    } catch (e) {
      setState(() => _isDetailLoading = false);
    }
  }

  Future<void> _checkIfSaved() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final response = await _supabase
          .from('saved_universities')
          .select('id')
          .eq('user_id', userId)
          .eq('university_id', widget.university['id'])
          .maybeSingle();
      setState(() => _isSaved = response != null);
    } catch (_) {}
  }

  Future<void> _toggleSave() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _showSnack('Please log in to save universities', isError: true);
      return;
    }
    setState(() => _isSaveLoading = true);
    try {
      if (_isSaved) {
        await _supabase
            .from('saved_universities')
            .delete()
            .eq('user_id', userId)
            .eq('university_id', widget.university['id']);
        setState(() => _isSaved = false);
        _showSnack('University removed from saved');
      } else {
        await _supabase.from('saved_universities').insert({
          'user_id': userId,
          'university_id': widget.university['id'],
        });
        setState(() => _isSaved = true);
        _showSnack('University saved!');
      }
    } catch (e) {
      _showSnack('Something went wrong. Try again.', isError: true);
    } finally {
      setState(() => _isSaveLoading = false);
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      _showSnack('No URL available', isError: true);
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Could not open link', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isDetailLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, _) => [
                _buildSliverAppBar(),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                      labelColor: _primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: _primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildProgramsTab(),
                  _buildAdmissionTab(),
                  _buildCampusTab(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  // ─── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: _isSaveLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white),
          onPressed: _isSaveLoading ? null : _toggleSave,
          tooltip: _isSaved ? 'Unsave' : 'Save',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _detail['logo_url'] != null
                            ? Image.network(_detail['logo_url'],
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _fallbackLogo(size: 56))
                            : _fallbackLogo(size: 56),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _detail['name'] ?? '—',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 13,
                                    color: Colors.white70),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    '${_detail['region'] ?? ''}, ${_detail['country'] ?? ''}',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (_detail['world_ranking'] != null)
                        _buildHeaderBadge(
                            '🏆 #${_detail['world_ranking']} World'),
                      if (_detail['world_ranking'] != null)
                        const SizedBox(width: 8),
                      if (_detail['acceptance_rate'] != null)
                        _buildHeaderBadge(
                            '${(_detail['acceptance_rate'] as num).toStringAsFixed(0)}% Accept'),
                      if (_detail['founded_year'] != null)
                        const SizedBox(width: 8),
                      if (_detail['founded_year'] != null)
                        _buildHeaderBadge(
                            'Est. ${_detail['founded_year']}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Tab Views ────────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            title: 'University Overview',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_detail['overview'] != null) ...[
                  Text(
                    _detail['overview'],
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.6),
                  ),
                  const SizedBox(height: 14),
                ],
                _buildInfoRow(Icons.calendar_today_outlined,
                    'Founded', '${_detail['founded_year'] ?? '—'}'),
                _buildInfoRow(Icons.people_outline, 'Total Students',
                    _detail['total_students'] != null
                        ? _formatNumber(_detail['total_students'])
                        : '—'),
                _buildInfoRow(Icons.flight_outlined,
                    'International Students',
                    _detail['international_students_percent'] != null
                        ? '${(_detail['international_students_percent'] as num).toStringAsFixed(0)}%'
                        : '—'),
                _buildInfoRow(Icons.public_outlined, 'Website',
                    _detail['website_url'] ?? '—',
                    isLink: true,
                    onLinkTap: () =>
                        _launchURL(_detail['website_url'])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              Expanded(
                  child: _buildStatCard('World\nRanking',
                      '#${_detail['world_ranking'] ?? '—'}',
                      Icons.emoji_events_outlined,
                      Colors.amber)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard('Acceptance\nRate',
                      '${_detail['acceptance_rate'] != null ? (_detail['acceptance_rate'] as num).toStringAsFixed(0) : '—'}%',
                      Icons.how_to_reg_outlined,
                      Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard('Avg Tuition',
                      '\$${_detail['avg_tuition_fee_per_year'] != null ? _formatNumber(_detail['avg_tuition_fee_per_year']) : '—'}',
                      Icons.payments_outlined,
                      Colors.blue)),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgramsTab() {
    final programs = (_detail['programs_offered'] as String?)
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final popular = (_detail['popular_programs'] as String?)
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (popular != null && popular.isNotEmpty)
            _buildCard(
              title: 'Popular Programs',
              icon: Icons.star_outline,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: popular
                    .map((p) => _buildProgramChip(p,
                        color: _primary, isPopular: true))
                    .toList(),
              ),
            ),
          if (popular != null && popular.isNotEmpty)
            const SizedBox(height: 16),
          if (programs != null && programs.isNotEmpty)
            _buildCard(
              title: 'All Programs Offered',
              icon: Icons.menu_book_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    programs.map((p) => _buildProgramChip(p)).toList(),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to course search filtered by university
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FindYourCoursePage()),
                );
              },
              icon: const Icon(Icons.search, color: _primary),
              label: const Text('View All Courses at This University',
                  style: TextStyle(color: _primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAdmissionTab() {
    final ieltsRequired = _detail['ielts_required'] == true;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            title: 'Admission Requirements',
            icon: Icons.checklist_outlined,
            child: Column(
              children: [
                _buildInfoRow(Icons.grade_outlined, 'Minimum GPA',
                    _detail['min_gpa'] != null
                        ? '${_detail['min_gpa']}/4.0'
                        : '—'),
                _buildInfoRow(
                  Icons.record_voice_over_outlined,
                  'IELTS',
                  ieltsRequired
                      ? (_detail['ielts_min_score'] != null
                          ? 'Required — Min ${_detail['ielts_min_score']}'
                          : 'Required')
                      : 'Not Required',
                  valueColor:
                      ieltsRequired ? Colors.orange : Colors.green,
                ),
                _buildInfoRow(
                  Icons.record_voice_over_outlined,
                  'TOEFL',
                  _detail['toefl_min_score'] != null
                      ? 'Min ${_detail['toefl_min_score']} iBT'
                      : '—',
                ),
                _buildInfoRow(
                    Icons.receipt_long_outlined,
                    'Application Fee',
                    _detail['application_fee'] != null
                        ? '\$${_formatNumber(_detail['application_fee'])}'
                        : '—'),
                _buildInfoRow(
                    Icons.event_outlined,
                    'Application Deadline',
                    _detail['application_deadline'] ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCampusTab() {
    final facilities = (_detail['facilities'] as String?)
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            title: 'Campus & Facilities',
            icon: Icons.location_city_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.location_on_outlined, 'Campus Type',
                    _detail['campus_type'] ?? '—'),
                _buildInfoRow(Icons.straighten_outlined, 'Campus Size',
                    _detail['campus_size'] ?? '—'),
                _buildInfoRow(
                    Icons.home_outlined,
                    'Housing',
                    _detail['housing_available'] == true
                        ? 'Available'
                        : 'Not Available',
                    valueColor: _detail['housing_available'] == true
                        ? Colors.green
                        : Colors.black54),
                if (facilities != null && facilities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Facilities',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facilities
                        .map((f) => _buildFacilityChip(f))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Bottom Buttons ───────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Row(
        children: [
          // Save button
          _buildIconBtn(
            icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
            label: _isSaved ? 'Saved' : 'Save',
            isLoading: _isSaveLoading,
            onTap: _isSaveLoading ? null : _toggleSave,
          ),
          const SizedBox(width: 8),
          // Visit Website
          _buildIconBtn(
            icon: Icons.language,
            label: 'Website',
            onTap: () => _launchURL(_detail['website_url']),
          ),
          const SizedBox(width: 8),
          // View Courses
          _buildIconBtn(
            icon: Icons.menu_book,
            label: 'Courses',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FindYourCoursePage()),
            ),
          ),
          const SizedBox(width: 8),
          // Apply Now
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchURL(_detail['apply_url']),
              icon: const Icon(Icons.send_outlined, size: 16),
              label: const Text('Apply Now',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _primary))
                : Icon(icon, color: _primary, size: 20),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: _primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ─── UI Helpers ───────────────────────────────────────────────────────────

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor,
      bool isLink = false,
      VoidCallback? onLinkTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13)),
          ),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: onLinkTap,
                    child: Text(value,
                        style: const TextStyle(
                            color: _primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline),
                        overflow: TextOverflow.ellipsis),
                  )
                : Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: valueColor ?? Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildProgramChip(String label,
      {Color color = Colors.transparent, bool isPopular = false}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPopular ? _primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: isPopular ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFacilityChip(String label) {
    final icons = {
      'Library': Icons.local_library_outlined,
      'Sports Complex': Icons.sports_basketball_outlined,
      'Research Labs': Icons.science_outlined,
      'Student Center': Icons.people_outline,
      'Swimming Pool': Icons.pool_outlined,
      'Medical Center': Icons.local_hospital_outlined,
      'Student Union': Icons.groups_outlined,
      'Innovation Hub': Icons.lightbulb_outlined,
      'Cafeteria': Icons.restaurant_outlined,
      'Sports Facilities': Icons.fitness_center_outlined,
      'Student Hub': Icons.hub_outlined,
      'Health Clinic': Icons.health_and_safety_outlined,
    };
    final icon = icons[label] ?? Icons.check_circle_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: _primary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style:
              const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _fallbackLogo({double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Icon(Icons.school, color: Colors.white, size: size * 0.5),
    );
  }

  String _formatNumber(dynamic number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

// ─── Tab Bar Delegate ─────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
