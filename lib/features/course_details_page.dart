import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SQL QUERIES — Run these in Supabase SQL Editor
// ─────────────────────────────────────────────────────────────────────────────
//
// -- STEP 1: Add extra detail columns to courses table
// ALTER TABLE courses
//   ADD COLUMN IF NOT EXISTS course_overview TEXT,
//   ADD COLUMN IF NOT EXISTS career_opportunities TEXT,
//   ADD COLUMN IF NOT EXISTS min_gpa NUMERIC(3,2),
//   ADD COLUMN IF NOT EXISTS ielts_min_score NUMERIC(3,1),
//   ADD COLUMN IF NOT EXISTS toefl_min_score INTEGER,
//   ADD COLUMN IF NOT EXISTS work_experience_required BOOLEAN DEFAULT false,
//   ADD COLUMN IF NOT EXISTS scholarship_available BOOLEAN DEFAULT false,
//   ADD COLUMN IF NOT EXISTS scholarship_details TEXT,
//   ADD COLUMN IF NOT EXISTS application_fee INTEGER,
//   ADD COLUMN IF NOT EXISTS application_deadline TEXT,
//   ADD COLUMN IF NOT EXISTS university_ranking INTEGER,
//   ADD COLUMN IF NOT EXISTS university_location TEXT,
//   ADD COLUMN IF NOT EXISTS apply_url TEXT;
//
// -- STEP 2: Create saved_courses table (for bookmark feature)
// CREATE TABLE saved_courses (
//   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
//   user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
//   course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
//   saved_at TIMESTAMPTZ DEFAULT NOW(),
//   UNIQUE(user_id, course_id)
// );
//
// ALTER TABLE saved_courses ENABLE ROW LEVEL SECURITY;
//
// CREATE POLICY "Users can manage their own saved courses" ON saved_courses
//   FOR ALL USING (auth.uid() = user_id);
//
// -- STEP 3: Update sample courses with detail info
// UPDATE courses SET
//   course_overview = 'This program provides a comprehensive foundation in computer science including algorithms, data structures, software engineering, and artificial intelligence.',
//   career_opportunities = 'Software Engineer, Data Scientist, Systems Analyst, AI Researcher, Full Stack Developer',
//   min_gpa = 3.00,
//   ielts_min_score = 6.5,
//   toefl_min_score = 90,
//   work_experience_required = false,
//   scholarship_available = true,
//   scholarship_details = 'Merit-based scholarships available up to $10,000/year for international students.',
//   application_fee = 100,
//   application_deadline = 'October 31, 2025',
//   university_ranking = 42,
//   university_location = 'Sydney, New South Wales, Australia',
//   apply_url = 'https://www.sydney.edu.au/apply'
// WHERE university_name = 'University of Sydney';
//
// -- STEP 4: Query to fetch full course detail by ID
// SELECT * FROM courses WHERE id = '<course_id>';
//
// -- STEP 5: Check if course is saved by current user
// SELECT id FROM saved_courses WHERE user_id = auth.uid() AND course_id = '<course_id>';
//
// -- STEP 6: Save a course
// INSERT INTO saved_courses (user_id, course_id) VALUES (auth.uid(), '<course_id>');
//
// -- STEP 7: Unsave a course
// DELETE FROM saved_courses WHERE user_id = auth.uid() AND course_id = '<course_id>';
//
// ─────────────────────────────────────────────────────────────────────────────

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final _supabase = Supabase.instance.client;

  bool _isSaved = false;
  bool _isSaveLoading = false;
  bool _isDetailLoading = true;
  Map<String, dynamic> _courseDetail = {};

  static const Color _primary = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _courseDetail = Map<String, dynamic>.from(widget.course);
    _fetchFullDetail();
    _checkIfSaved();
  }

  // ─── Supabase Methods ─────────────────────────────────────────────────────

  Future<void> _fetchFullDetail() async {
    try {
      final courseId = widget.course['id'];
      final response = await _supabase
          .from('courses')
          .select('*')
          .eq('id', courseId)
          .single();

      setState(() {
        _courseDetail = Map<String, dynamic>.from(response);
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

      final courseId = widget.course['id'];
      final response = await _supabase
          .from('saved_courses')
          .select('id')
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      setState(() => _isSaved = response != null);
    } catch (_) {}
  }

  Future<void> _toggleSave() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _showSnack('Please log in to save courses', isError: true);
      return;
    }

    setState(() => _isSaveLoading = true);
    final courseId = widget.course['id'];

    try {
      if (_isSaved) {
        await _supabase
            .from('saved_courses')
            .delete()
            .eq('user_id', userId)
            .eq('course_id', courseId);
        setState(() => _isSaved = false);
        _showSnack('Course removed from saved');
      } else {
        await _supabase.from('saved_courses').insert({
          'user_id': userId,
          'course_id': courseId,
        });
        setState(() => _isSaved = true);
        _showSnack('Course saved successfully!');
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isDetailLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUniversityInfoCard(),
                        const SizedBox(height: 16),
                        _buildCourseOverviewCard(),
                        const SizedBox(height: 16),
                        _buildRequirementsCard(),
                        const SizedBox(height: 16),
                        _buildFeesScholarshipsCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  // ─── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
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
                  color: Colors.white,
                ),
          onPressed: _isSaveLoading ? null : _toggleSave,
          tooltip: _isSaved ? 'Unsave Course' : 'Save Course',
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
                  if (_courseDetail['degree_type'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _courseDetail['degree_type'],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _courseDetail['course_name'] ?? 'Course Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_courseDetail['university_name'] != null)
                    Text(
                      _courseDetail['university_name'],
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section Cards ────────────────────────────────────────────────────────

  Widget _buildUniversityInfoCard() {
    return _buildCard(
      title: 'University Info',
      icon: Icons.school_outlined,
      child: Column(
        children: [
          if (_courseDetail['university_logo_url'] != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _courseDetail['university_logo_url'],
                  height: 70,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          if (_courseDetail['university_logo_url'] != null)
            const SizedBox(height: 12),
          _buildInfoRow(Icons.business, 'University',
              _courseDetail['university_name'] ?? '—'),
          _buildInfoRow(Icons.location_on_outlined, 'Location',
              _courseDetail['university_location'] ?? '—'),
          _buildInfoRow(Icons.emoji_events_outlined, 'World Ranking',
              _courseDetail['university_ranking'] != null
                  ? '#${_courseDetail['university_ranking']} globally'
                  : '—'),
          _buildInfoRow(Icons.language, 'Language',
              _courseDetail['language_of_instruction'] ?? '—'),
          if (_courseDetail['university_website_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: () =>
                    _launchURL(_courseDetail['university_website_url']),
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new, size: 16, color: _primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _courseDetail['university_website_url'],
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseOverviewCard() {
    return _buildCard(
      title: 'Course Overview',
      icon: Icons.menu_book_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.access_time, 'Duration',
              '${_courseDetail['duration_years'] ?? '—'} Year(s)'),
          _buildInfoRow(Icons.calendar_month_outlined, 'Intake Month',
              _courseDetail['intake_month'] ?? '—'),
          _buildInfoRow(Icons.flag_outlined, 'Country',
              _courseDetail['country'] ?? '—'),
          _buildInfoRow(Icons.map_outlined, 'Region',
              _courseDetail['region'] ?? '—'),
          if (_courseDetail['course_overview'] != null) ...[
            const SizedBox(height: 12),
            const Text('About This Course',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              _courseDetail['course_overview'],
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54, height: 1.5),
            ),
          ],
          if (_courseDetail['career_opportunities'] != null) ...[
            const SizedBox(height: 12),
            const Text('Career Opportunities',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              _courseDetail['career_opportunities'],
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementsCard() {
    final ieltsRequired = _courseDetail['ielts_required'] == true;
    return _buildCard(
      title: 'Requirements & Eligibility',
      icon: Icons.checklist_outlined,
      child: Column(
        children: [
          _buildInfoRow(Icons.grade_outlined, 'Minimum GPA',
              _courseDetail['min_gpa'] != null
                  ? '${_courseDetail['min_gpa']}/4.0'
                  : '—'),
          _buildInfoRow(
            Icons.record_voice_over_outlined,
            'IELTS',
            ieltsRequired
                ? (_courseDetail['ielts_min_score'] != null
                    ? 'Required — Min ${_courseDetail['ielts_min_score']}'
                    : 'Required')
                : 'Not Required',
            valueColor: ieltsRequired ? Colors.orange : Colors.green,
          ),
          _buildInfoRow(
            Icons.record_voice_over_outlined,
            'TOEFL',
            _courseDetail['toefl_min_score'] != null
                ? 'Min ${_courseDetail['toefl_min_score']} iBT'
                : '—',
          ),
          _buildInfoRow(
            Icons.work_outline,
            'Work Experience',
            _courseDetail['work_experience_required'] == true
                ? 'Required'
                : 'Not Required',
            valueColor: _courseDetail['work_experience_required'] == true
                ? Colors.orange
                : Colors.green,
          ),
          _buildInfoRow(Icons.event_outlined, 'Application Deadline',
              _courseDetail['application_deadline'] ?? '—'),
        ],
      ),
    );
  }

  Widget _buildFeesScholarshipsCard() {
    final scholarshipAvailable =
        _courseDetail['scholarship_available'] == true;
    return _buildCard(
      title: 'Fees & Scholarships',
      icon: Icons.attach_money_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.payments_outlined,
            'Tuition Fee',
            _courseDetail['tuition_fee_per_year'] != null
                ? '\$${_formatNumber(_courseDetail['tuition_fee_per_year'])} / year'
                : '—',
          ),
          _buildInfoRow(
            Icons.receipt_long_outlined,
            'Application Fee',
            _courseDetail['application_fee'] != null
                ? '\$${_formatNumber(_courseDetail['application_fee'])}'
                : '—',
          ),
          _buildInfoRow(
            Icons.card_giftcard_outlined,
            'Scholarship',
            scholarshipAvailable ? 'Available' : 'Not Available',
            valueColor:
                scholarshipAvailable ? Colors.green : Colors.black54,
          ),
          if (scholarshipAvailable &&
              _courseDetail['scholarship_details'] != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _courseDetail['scholarship_details'],
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Bottom Buttons ───────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          // Save / Bookmark button
          OutlinedButton.icon(
            onPressed: _isSaveLoading ? null : _toggleSave,
            icon: _isSaveLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _primary))
                : Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _primary,
                  ),
            label: Text(
              _isSaved ? 'Saved' : 'Save',
              style: const TextStyle(color: _primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
          // Apply Now button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchURL(_courseDetail['apply_url']),
              icon: const Icon(Icons.send_outlined, size: 18),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
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
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    return number
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
