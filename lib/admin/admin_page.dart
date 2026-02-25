import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SETUP
// Add to pubspec.yaml:
//   supabase_flutter: ^2.3.0
//
// Initialize in main.dart:
//   await Supabase.initialize(url: 'YOUR_SUPABASE_URL', anonKey: 'YOUR_ANON_KEY');
// ─────────────────────────────────────────────────────────────────────────────

final _supabase = Supabase.instance.client;

// ─── Theme ────────────────────────────────────────────────────────────────────
const Color kPrimary = Color(0xFF1A237E);
const Color kAccent = Color(0xFF00B0FF);
const Color kSurface = Color(0xFFF0F4FF);

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class UniversityModel {
  final String? id;
  String name;
  String country;
  String? region;
  String? logoUrl;
  String? bannerUrl;
  String? websiteUrl;
  String? applyUrl;
  int? worldRanking;
  double? acceptanceRate;
  int? avgTuitionFee;
  String? overview;
  int? foundedYear;
  int? totalStudents;
  double? intlStudentsPercent;
  String? campusSize;
  String? campusType;
  String? facilities;
  bool housingAvailable;
  String? programsOffered;
  String? popularPrograms;
  double? minGpa;
  bool ieltsRequired;
  double? ieltsMinScore;
  int? toeflMinScore;
  String? applicationDeadline;
  int? applicationFee;

  UniversityModel({
    this.id,
    required this.name,
    required this.country,
    this.region,
    this.logoUrl,
    this.bannerUrl,
    this.websiteUrl,
    this.applyUrl,
    this.worldRanking,
    this.acceptanceRate,
    this.avgTuitionFee,
    this.overview,
    this.foundedYear,
    this.totalStudents,
    this.intlStudentsPercent,
    this.campusSize,
    this.campusType,
    this.facilities,
    this.housingAvailable = false,
    this.programsOffered,
    this.popularPrograms,
    this.minGpa,
    this.ieltsRequired = false,
    this.ieltsMinScore,
    this.toeflMinScore,
    this.applicationDeadline,
    this.applicationFee,
  });

  factory UniversityModel.fromMap(Map<String, dynamic> m) => UniversityModel(
        id: m['id']?.toString(),
        name: m['name'] ?? '',
        country: m['country'] ?? '',
        region: m['region'],
        logoUrl: m['logo_url'],
        bannerUrl: m['banner_url'],
        websiteUrl: m['website_url'],
        applyUrl: m['apply_url'],
        worldRanking: m['world_ranking'],
        acceptanceRate: m['acceptance_rate'] != null
            ? double.tryParse(m['acceptance_rate'].toString())
            : null,
        avgTuitionFee: m['avg_tuition_fee_per_year'],
        overview: m['overview'],
        foundedYear: m['founded_year'],
        totalStudents: m['total_students'],
        intlStudentsPercent: m['international_students_percent'] != null
            ? double.tryParse(m['international_students_percent'].toString())
            : null,
        campusSize: m['campus_size'],
        campusType: m['campus_type'],
        facilities: m['facilities'],
        housingAvailable: m['housing_available'] ?? false,
        programsOffered: m['programs_offered'],
        popularPrograms: m['popular_programs'],
        minGpa: m['min_gpa'] != null ? double.tryParse(m['min_gpa'].toString()) : null,
        ieltsRequired: m['ielts_required'] ?? false,
        ieltsMinScore: m['ielts_min_score'] != null
            ? double.tryParse(m['ielts_min_score'].toString())
            : null,
        toeflMinScore: m['toefl_min_score'],
        applicationDeadline: m['application_deadline'],
        applicationFee: m['application_fee'],
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'country': country,
        if (region != null) 'region': region,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (bannerUrl != null) 'banner_url': bannerUrl,
        if (websiteUrl != null) 'website_url': websiteUrl,
        if (applyUrl != null) 'apply_url': applyUrl,
        if (worldRanking != null) 'world_ranking': worldRanking,
        if (acceptanceRate != null) 'acceptance_rate': acceptanceRate,
        if (avgTuitionFee != null) 'avg_tuition_fee_per_year': avgTuitionFee,
        if (overview != null) 'overview': overview,
        if (foundedYear != null) 'founded_year': foundedYear,
        if (totalStudents != null) 'total_students': totalStudents,
        if (intlStudentsPercent != null)
          'international_students_percent': intlStudentsPercent,
        if (campusSize != null) 'campus_size': campusSize,
        if (campusType != null) 'campus_type': campusType,
        if (facilities != null) 'facilities': facilities,
        'housing_available': housingAvailable,
        if (programsOffered != null) 'programs_offered': programsOffered,
        if (popularPrograms != null) 'popular_programs': popularPrograms,
        if (minGpa != null) 'min_gpa': minGpa,
        'ielts_required': ieltsRequired,
        if (ieltsMinScore != null) 'ielts_min_score': ieltsMinScore,
        if (toeflMinScore != null) 'toefl_min_score': toeflMinScore,
        if (applicationDeadline != null) 'application_deadline': applicationDeadline,
        if (applicationFee != null) 'application_fee': applicationFee,
      };
}

class CourseModel {
  final String? id;
  String courseName;
  String country;
  String? region;
  int? tuitionFeePerYear;
  String? languageOfInstruction;
  String? degreeType;
  int? durationYears;
  String? intakeMonth;
  bool ieltsRequired;
  String universityName;
  String? universityLogoUrl;
  String? universityWebsiteUrl;
  String? courseOverview;
  String? careerOpportunities;
  double? minGpa;
  double? ieltsMinScore;
  int? toeflMinScore;
  bool workExperienceRequired;
  bool scholarshipAvailable;
  String? scholarshipDetails;
  int? applicationFee;
  String? applicationDeadline;
  int? universityRanking;
  String? universityLocation;
  String? applyUrl;

  CourseModel({
    this.id,
    required this.courseName,
    required this.country,
    this.region,
    this.tuitionFeePerYear,
    this.languageOfInstruction,
    this.degreeType,
    this.durationYears,
    this.intakeMonth,
    this.ieltsRequired = false,
    required this.universityName,
    this.universityLogoUrl,
    this.universityWebsiteUrl,
    this.courseOverview,
    this.careerOpportunities,
    this.minGpa,
    this.ieltsMinScore,
    this.toeflMinScore,
    this.workExperienceRequired = false,
    this.scholarshipAvailable = false,
    this.scholarshipDetails,
    this.applicationFee,
    this.applicationDeadline,
    this.universityRanking,
    this.universityLocation,
    this.applyUrl,
  });

  factory CourseModel.fromMap(Map<String, dynamic> m) => CourseModel(
        id: m['id']?.toString(),
        courseName: m['course_name'] ?? '',
        country: m['country'] ?? '',
        region: m['region'],
        tuitionFeePerYear: m['tuition_fee_per_year'],
        languageOfInstruction: m['language_of_instruction'],
        degreeType: m['degree_type'],
        durationYears: m['duration_years'],
        intakeMonth: m['intake_month'],
        ieltsRequired: m['ielts_required'] ?? false,
        universityName: m['university_name'] ?? '',
        universityLogoUrl: m['university_logo_url'],
        universityWebsiteUrl: m['university_website_url'],
        courseOverview: m['course_overview'],
        careerOpportunities: m['career_opportunities'],
        minGpa: m['min_gpa'] != null ? double.tryParse(m['min_gpa'].toString()) : null,
        ieltsMinScore: m['ielts_min_score'] != null
            ? double.tryParse(m['ielts_min_score'].toString())
            : null,
        toeflMinScore: m['toefl_min_score'],
        workExperienceRequired: m['work_experience_required'] ?? false,
        scholarshipAvailable: m['scholarship_available'] ?? false,
        scholarshipDetails: m['scholarship_details'],
        applicationFee: m['application_fee'],
        applicationDeadline: m['application_deadline'],
        universityRanking: m['university_ranking'],
        universityLocation: m['university_location'],
        applyUrl: m['apply_url'],
      );

  Map<String, dynamic> toMap() => {
        'course_name': courseName,
        'country': country,
        if (region != null) 'region': region,
        if (tuitionFeePerYear != null) 'tuition_fee_per_year': tuitionFeePerYear,
        if (languageOfInstruction != null) 'language_of_instruction': languageOfInstruction,
        if (degreeType != null) 'degree_type': degreeType,
        if (durationYears != null) 'duration_years': durationYears,
        if (intakeMonth != null) 'intake_month': intakeMonth,
        'ielts_required': ieltsRequired,
        'university_name': universityName,
        if (universityLogoUrl != null) 'university_logo_url': universityLogoUrl,
        if (universityWebsiteUrl != null) 'university_website_url': universityWebsiteUrl,
        if (courseOverview != null) 'course_overview': courseOverview,
        if (careerOpportunities != null) 'career_opportunities': careerOpportunities,
        if (minGpa != null) 'min_gpa': minGpa,
        if (ieltsMinScore != null) 'ielts_min_score': ieltsMinScore,
        if (toeflMinScore != null) 'toefl_min_score': toeflMinScore,
        'work_experience_required': workExperienceRequired,
        'scholarship_available': scholarshipAvailable,
        if (scholarshipDetails != null) 'scholarship_details': scholarshipDetails,
        if (applicationFee != null) 'application_fee': applicationFee,
        if (applicationDeadline != null) 'application_deadline': applicationDeadline,
        if (universityRanking != null) 'university_ranking': universityRanking,
        if (universityLocation != null) 'university_location': universityLocation,
        if (applyUrl != null) 'apply_url': applyUrl,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN DASHBOARD PAGE
// ─────────────────────────────────────────────────────────────────────────────

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

  void _logout() {
    Navigator.pop(context);
  }

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
            _showUniversityDialog(context, null, () => setState(() {}));
          } else {
            _showCourseDialog(context, null, () => setState(() {}));
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

// ─────────────────────────────────────────────────────────────────────────────
// UNIVERSITY TAB
// ─────────────────────────────────────────────────────────────────────────────

class UniversityManagementTab extends StatefulWidget {
  const UniversityManagementTab({super.key});

  @override
  State<UniversityManagementTab> createState() => _UniversityManagementTabState();
}

class _UniversityManagementTabState extends State<UniversityManagementTab> {
  List<UniversityModel> _universities = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final res = await _supabase
          .from('universities')
          .select()
          .order('name', ascending: true);
      setState(() {
        _universities = (res as List).map((e) => UniversityModel.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showErr('Failed to load universities: $e');
    }
  }

  Future<void> _delete(UniversityModel uni) async {
    final confirm = await _confirmDialog(context, 'Delete "${uni.name}"?',
        'This will permanently remove the university.');
    if (!confirm) return;
    try {
      await _supabase.from('universities').delete().eq('id', uni.id!);
      _loadData();
      _showSnack('University deleted');
    } catch (e) {
      _showErr('Delete failed: $e');
    }
  }

  void _showErr(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  List<UniversityModel> get _filtered => _universities
      .where((u) => u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.country.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats + Search
        Container(
          color: kPrimary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  _StatChip('Total', '${_universities.length}', Icons.account_balance),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search universities...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _filtered.isEmpty
                  ? _EmptyState('No universities found', Icons.account_balance_outlined,
                      onRefresh: _loadData)
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: kPrimary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final u = _filtered[i];
                          return _UniversityCard(
                            university: u,
                            onEdit: () => _showUniversityDialog(
                                context, u, _loadData),
                            onDelete: () => _delete(u),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _UniversityCard extends StatelessWidget {
  final UniversityModel university;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UniversityCard(
      {required this.university, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final u = university;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [kPrimary, Color(0xFF283593)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                if (u.logoUrl != null && u.logoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(u.logoUrl!, width: 36, height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.account_balance, color: Colors.white70, size: 28)),
                  )
                else
                  const Icon(Icons.account_balance, color: Colors.white70, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('${u.country}${u.region != null ? ', ${u.region}' : ''}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                _ActionBtn(Icons.edit, kAccent, onEdit),
                const SizedBox(width: 6),
                _ActionBtn(Icons.delete, Colors.red.shade300, onDelete),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (u.worldRanking != null)
                      _Badge('Rank #${u.worldRanking}', Colors.amber.shade700),
                    if (u.avgTuitionFee != null)
                      _Badge('\$${u.avgTuitionFee}/yr', Colors.green.shade700),
                    if (u.campusType != null) _Badge(u.campusType!, Colors.teal),
                    if (u.foundedYear != null)
                      _Badge('Est. ${u.foundedYear}', Colors.purple.shade700),
                    _Badge(u.ieltsRequired ? 'IELTS Required' : 'No IELTS', 
                        u.ieltsRequired ? Colors.orange.shade700 : Colors.blue.shade700),
                  ],
                ),
                if (u.overview != null && u.overview!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(u.overview!,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                if (u.applicationDeadline != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 13, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text('Deadline: ${u.applicationDeadline}',
                        style: const TextStyle(color: Colors.black45, fontSize: 12)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COURSE TAB
// ─────────────────────────────────────────────────────────────────────────────

class CourseManagementTab extends StatefulWidget {
  const CourseManagementTab({super.key});

  @override
  State<CourseManagementTab> createState() => _CourseManagementTabState();
}

class _CourseManagementTabState extends State<CourseManagementTab> {
  List<CourseModel> _courses = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final res = await _supabase
          .from('courses')
          .select()
          .order('course_name', ascending: true);
      setState(() {
        _courses = (res as List).map((e) => CourseModel.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showErr('Failed to load courses: $e');
    }
  }

  Future<void> _delete(CourseModel c) async {
    final confirm = await _confirmDialog(
        context, 'Delete "${c.courseName}"?', 'This will permanently remove the course.');
    if (!confirm) return;
    try {
      await _supabase.from('courses').delete().eq('id', c.id!);
      _loadData();
      _showSnack('Course deleted');
    } catch (e) {
      _showErr('Delete failed: $e');
    }
  }

  void _showErr(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  List<CourseModel> get _filtered => _courses
      .where((c) =>
          c.courseName.toLowerCase().contains(_search.toLowerCase()) ||
          c.universityName.toLowerCase().contains(_search.toLowerCase()) ||
          c.country.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: kPrimary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Row(children: [
                _StatChip('Total Courses', '${_courses.length}', Icons.menu_book),
              ]),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search courses, university, country...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _filtered.isEmpty
                  ? _EmptyState('No courses found', Icons.menu_book_outlined,
                      onRefresh: _loadData)
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: kPrimary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final c = _filtered[i];
                          return _CourseCard(
                            course: c,
                            onEdit: () =>
                                _showCourseDialog(context, c, _loadData),
                            onDelete: () => _delete(c),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard(
      {required this.course, required this.onEdit, required this.onDelete});

  Color _degreeColor() {
    switch (course.degreeType?.toLowerCase()) {
      case 'bachelor': return Colors.blue.shade700;
      case 'master': return Colors.purple.shade700;
      case 'phd': return Colors.red.shade700;
      default: return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = course;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _degreeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.school, color: _degreeColor(), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.courseName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: kPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(c.universityName,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                _ActionBtn(Icons.edit, kAccent, onEdit),
                const SizedBox(width: 6),
                _ActionBtn(Icons.delete, Colors.red.shade300, onDelete),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (c.degreeType != null) _Badge(c.degreeType!, _degreeColor()),
                if (c.country.isNotEmpty) _Badge(c.country, Colors.indigo.shade600),
                if (c.durationYears != null)
                  _Badge('${c.durationYears} yr${c.durationYears! > 1 ? 's' : ''}',
                      Colors.orange.shade700),
                if (c.tuitionFeePerYear != null)
                  _Badge('\$${c.tuitionFeePerYear}/yr', Colors.green.shade700),
                if (c.intakeMonth != null) _Badge(c.intakeMonth!, Colors.teal),
                if (c.scholarshipAvailable)
                  _Badge('Scholarship', Colors.amber.shade800),
                _Badge(c.ieltsRequired ? 'IELTS Required' : 'No IELTS',
                    c.ieltsRequired ? Colors.orange.shade700 : Colors.blue.shade700),
              ],
            ),
            if (c.courseOverview != null && c.courseOverview!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(c.courseOverview!,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            if (c.applicationDeadline != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.calendar_today, size: 13, color: Colors.black38),
                const SizedBox(width: 4),
                Text('Deadline: ${c.applicationDeadline}',
                    style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UNIVERSITY DIALOG (Add / Edit)
// ─────────────────────────────────────────────────────────────────────────────

void _showUniversityDialog(
    BuildContext context, UniversityModel? existing, VoidCallback onSaved) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UniversityFormSheet(existing: existing, onSaved: onSaved),
  );
}

class _UniversityFormSheet extends StatefulWidget {
  final UniversityModel? existing;
  final VoidCallback onSaved;

  const _UniversityFormSheet({this.existing, required this.onSaved});

  @override
  State<_UniversityFormSheet> createState() => _UniversityFormSheetState();
}

class _UniversityFormSheetState extends State<_UniversityFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Controllers
  late TextEditingController _name, _country, _region, _logoUrl, _bannerUrl,
      _websiteUrl, _applyUrl, _worldRanking, _acceptanceRate, _avgTuition,
      _overview, _foundedYear, _totalStudents, _intlPercent, _campusSize,
      _facilities, _programsOffered, _popularPrograms, _minGpa, _ieltsScore,
      _toeflScore, _appDeadline, _appFee;

  String _campusType = 'Urban';
  bool _housingAvailable = false;
  bool _ieltsRequired = false;

  final _campusTypes = ['Urban', 'Suburban', 'Rural'];

  @override
  void initState() {
    super.initState();
    final u = widget.existing;
    _name = TextEditingController(text: u?.name ?? '');
    _country = TextEditingController(text: u?.country ?? '');
    _region = TextEditingController(text: u?.region ?? '');
    _logoUrl = TextEditingController(text: u?.logoUrl ?? '');
    _bannerUrl = TextEditingController(text: u?.bannerUrl ?? '');
    _websiteUrl = TextEditingController(text: u?.websiteUrl ?? '');
    _applyUrl = TextEditingController(text: u?.applyUrl ?? '');
    _worldRanking = TextEditingController(text: u?.worldRanking?.toString() ?? '');
    _acceptanceRate = TextEditingController(text: u?.acceptanceRate?.toString() ?? '');
    _avgTuition = TextEditingController(text: u?.avgTuitionFee?.toString() ?? '');
    _overview = TextEditingController(text: u?.overview ?? '');
    _foundedYear = TextEditingController(text: u?.foundedYear?.toString() ?? '');
    _totalStudents = TextEditingController(text: u?.totalStudents?.toString() ?? '');
    _intlPercent = TextEditingController(text: u?.intlStudentsPercent?.toString() ?? '');
    _campusSize = TextEditingController(text: u?.campusSize ?? '');
    _facilities = TextEditingController(text: u?.facilities ?? '');
    _programsOffered = TextEditingController(text: u?.programsOffered ?? '');
    _popularPrograms = TextEditingController(text: u?.popularPrograms ?? '');
    _minGpa = TextEditingController(text: u?.minGpa?.toString() ?? '');
    _ieltsScore = TextEditingController(text: u?.ieltsMinScore?.toString() ?? '');
    _toeflScore = TextEditingController(text: u?.toeflMinScore?.toString() ?? '');
    _appDeadline = TextEditingController(text: u?.applicationDeadline ?? '');
    _appFee = TextEditingController(text: u?.applicationFee?.toString() ?? '');
    _campusType = u?.campusType ?? 'Urban';
    _housingAvailable = u?.housingAvailable ?? false;
    _ieltsRequired = u?.ieltsRequired ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _country, _region, _logoUrl, _bannerUrl, _websiteUrl,
      _applyUrl, _worldRanking, _acceptanceRate, _avgTuition, _overview,
      _foundedYear, _totalStudents, _intlPercent, _campusSize, _facilities,
      _programsOffered, _popularPrograms, _minGpa, _ieltsScore, _toeflScore,
      _appDeadline, _appFee]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final model = UniversityModel(
      id: widget.existing?.id,
      name: _name.text.trim(),
      country: _country.text.trim(),
      region: _region.text.trim().isEmpty ? null : _region.text.trim(),
      logoUrl: _logoUrl.text.trim().isEmpty ? null : _logoUrl.text.trim(),
      bannerUrl: _bannerUrl.text.trim().isEmpty ? null : _bannerUrl.text.trim(),
      websiteUrl: _websiteUrl.text.trim().isEmpty ? null : _websiteUrl.text.trim(),
      applyUrl: _applyUrl.text.trim().isEmpty ? null : _applyUrl.text.trim(),
      worldRanking: int.tryParse(_worldRanking.text),
      acceptanceRate: double.tryParse(_acceptanceRate.text),
      avgTuitionFee: int.tryParse(_avgTuition.text),
      overview: _overview.text.trim().isEmpty ? null : _overview.text.trim(),
      foundedYear: int.tryParse(_foundedYear.text),
      totalStudents: int.tryParse(_totalStudents.text),
      intlStudentsPercent: double.tryParse(_intlPercent.text),
      campusSize: _campusSize.text.trim().isEmpty ? null : _campusSize.text.trim(),
      campusType: _campusType,
      facilities: _facilities.text.trim().isEmpty ? null : _facilities.text.trim(),
      housingAvailable: _housingAvailable,
      programsOffered: _programsOffered.text.trim().isEmpty ? null : _programsOffered.text.trim(),
      popularPrograms: _popularPrograms.text.trim().isEmpty ? null : _popularPrograms.text.trim(),
      minGpa: double.tryParse(_minGpa.text),
      ieltsRequired: _ieltsRequired,
      ieltsMinScore: double.tryParse(_ieltsScore.text),
      toeflMinScore: int.tryParse(_toeflScore.text),
      applicationDeadline: _appDeadline.text.trim().isEmpty ? null : _appDeadline.text.trim(),
      applicationFee: int.tryParse(_appFee.text),
    );

    try {
      if (widget.existing == null) {
        await _supabase.from('universities').insert(model.toMap());
      } else {
        await _supabase.from('universities').update(model.toMap()).eq('id', model.id!);
      }
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.existing == null
            ? 'University added!' : 'University updated!'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [kPrimary, Color(0xFF283593)]),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    widget.existing == null ? 'Add University' : 'Edit University',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _SectionHeader('Basic Information'),
                    _FieldRow([
                      _Field(_name, 'University Name *', Icons.account_balance, required: true),
                    ]),
                    _FieldRow([
                      _Field(_country, 'Country *', Icons.public, required: true),
                      _Field(_region, 'Region / State', Icons.map),
                    ]),
                    _FieldRow([
                      _Field(_websiteUrl, 'Website URL', Icons.language),
                      _Field(_applyUrl, 'Apply URL', Icons.open_in_new),
                    ]),
                    _FieldRow([
                      _Field(_logoUrl, 'Logo URL', Icons.image),
                      _Field(_bannerUrl, 'Banner URL', Icons.panorama),
                    ]),

                    _SectionHeader('Stats & Rankings'),
                    _FieldRow([
                      _Field(_worldRanking, 'World Ranking', Icons.leaderboard,
                          type: TextInputType.number),
                      _Field(_acceptanceRate, 'Acceptance Rate (%)', Icons.percent,
                          type: TextInputType.number),
                    ]),
                    _FieldRow([
                      _Field(_avgTuition, 'Avg Tuition/Year (\$)', Icons.attach_money,
                          type: TextInputType.number),
                      _Field(_foundedYear, 'Founded Year', Icons.history,
                          type: TextInputType.number),
                    ]),
                    _FieldRow([
                      _Field(_totalStudents, 'Total Students', Icons.people,
                          type: TextInputType.number),
                      _Field(_intlPercent, 'Intl Students (%)', Icons.flight,
                          type: TextInputType.number),
                    ]),

                    _SectionHeader('Campus'),
                    _FieldRow([
                      _Field(_campusSize, 'Campus Size', Icons.landscape),
                    ]),
                    const SizedBox(height: 4),
                    const Text('Campus Type',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kPrimary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _campusType,
                      decoration: _dec('Campus Type', Icons.location_city),
                      items: _campusTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _campusType = v!),
                    ),
                    const SizedBox(height: 14),
                    _Field(_facilities, 'Facilities (comma separated)', Icons.business, maxLines: 2),
                    const SizedBox(height: 8),
                    _SwitchTile('Housing Available', _housingAvailable,
                        (v) => setState(() => _housingAvailable = v)),

                    _SectionHeader('Programs'),
                    _Field(_programsOffered, 'Programs Offered', Icons.list, maxLines: 2),
                    const SizedBox(height: 8),
                    _Field(_popularPrograms, 'Popular Programs', Icons.star, maxLines: 2),

                    _SectionHeader('Requirements'),
                    _FieldRow([
                      _Field(_minGpa, 'Min GPA', Icons.grade, type: TextInputType.number),
                    ]),
                    _SwitchTile('IELTS Required', _ieltsRequired,
                        (v) => setState(() => _ieltsRequired = v)),
                    if (_ieltsRequired)
                      _FieldRow([
                        _Field(_ieltsScore, 'Min IELTS Score', Icons.score,
                            type: TextInputType.number),
                        _Field(_toeflScore, 'Min TOEFL Score', Icons.score,
                            type: TextInputType.number),
                      ]),

                    _SectionHeader('Application'),
                    _FieldRow([
                      _Field(_appDeadline, 'Application Deadline', Icons.calendar_today),
                      _Field(_appFee, 'Application Fee (\$)', Icons.payment,
                          type: TextInputType.number),
                    ]),

                    _SectionHeader('Overview'),
                    _Field(_overview, 'University Overview', Icons.info_outline, maxLines: 4),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _saving
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                widget.existing == null ? 'Add University' : 'Update University',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COURSE DIALOG (Add / Edit)
// ─────────────────────────────────────────────────────────────────────────────

void _showCourseDialog(
    BuildContext context, CourseModel? existing, VoidCallback onSaved) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CourseFormSheet(existing: existing, onSaved: onSaved),
  );
}

class _CourseFormSheet extends StatefulWidget {
  final CourseModel? existing;
  final VoidCallback onSaved;

  const _CourseFormSheet({this.existing, required this.onSaved});

  @override
  State<_CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<_CourseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late TextEditingController _courseName, _country, _region, _tuitionFee,
      _language, _duration, _intakeMonth, _uniName, _uniLogoUrl, _uniWebsite,
      _courseOverview, _careerOpps, _minGpa, _ieltsScore, _toeflScore,
      _scholarshipDetails, _appFee, _appDeadline, _uniRanking, _uniLocation,
      _applyUrl;

  String _degreeType = 'Bachelor';
  bool _ieltsRequired = false;
  bool _workExpRequired = false;
  bool _scholarshipAvailable = false;

  final _degreeTypes = ['Bachelor', 'Master', 'PhD', 'Diploma', 'Certificate', 'Associate'];
  final _intakeMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
    'January / September', 'February / September', 'March / September',
  ];

  String? _selectedIntake;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _courseName = TextEditingController(text: c?.courseName ?? '');
    _country = TextEditingController(text: c?.country ?? '');
    _region = TextEditingController(text: c?.region ?? '');
    _tuitionFee = TextEditingController(text: c?.tuitionFeePerYear?.toString() ?? '');
    _language = TextEditingController(text: c?.languageOfInstruction ?? 'English');
    _duration = TextEditingController(text: c?.durationYears?.toString() ?? '');
    _intakeMonth = TextEditingController(text: c?.intakeMonth ?? '');
    _uniName = TextEditingController(text: c?.universityName ?? '');
    _uniLogoUrl = TextEditingController(text: c?.universityLogoUrl ?? '');
    _uniWebsite = TextEditingController(text: c?.universityWebsiteUrl ?? '');
    _courseOverview = TextEditingController(text: c?.courseOverview ?? '');
    _careerOpps = TextEditingController(text: c?.careerOpportunities ?? '');
    _minGpa = TextEditingController(text: c?.minGpa?.toString() ?? '');
    _ieltsScore = TextEditingController(text: c?.ieltsMinScore?.toString() ?? '');
    _toeflScore = TextEditingController(text: c?.toeflMinScore?.toString() ?? '');
    _scholarshipDetails = TextEditingController(text: c?.scholarshipDetails ?? '');
    _appFee = TextEditingController(text: c?.applicationFee?.toString() ?? '');
    _appDeadline = TextEditingController(text: c?.applicationDeadline ?? '');
    _uniRanking = TextEditingController(text: c?.universityRanking?.toString() ?? '');
    _uniLocation = TextEditingController(text: c?.universityLocation ?? '');
    _applyUrl = TextEditingController(text: c?.applyUrl ?? '');
    _degreeType = c?.degreeType ?? 'Bachelor';
    _ieltsRequired = c?.ieltsRequired ?? false;
    _workExpRequired = c?.workExperienceRequired ?? false;
    _scholarshipAvailable = c?.scholarshipAvailable ?? false;
    _selectedIntake = c?.intakeMonth;
  }

  @override
  void dispose() {
    for (final ctrl in [_courseName, _country, _region, _tuitionFee, _language,
      _duration, _intakeMonth, _uniName, _uniLogoUrl, _uniWebsite, _courseOverview,
      _careerOpps, _minGpa, _ieltsScore, _toeflScore, _scholarshipDetails,
      _appFee, _appDeadline, _uniRanking, _uniLocation, _applyUrl]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final model = CourseModel(
      id: widget.existing?.id,
      courseName: _courseName.text.trim(),
      country: _country.text.trim(),
      region: _region.text.trim().isEmpty ? null : _region.text.trim(),
      tuitionFeePerYear: int.tryParse(_tuitionFee.text),
      languageOfInstruction: _language.text.trim().isEmpty ? null : _language.text.trim(),
      degreeType: _degreeType,
      durationYears: int.tryParse(_duration.text),
      intakeMonth: _selectedIntake,
      ieltsRequired: _ieltsRequired,
      universityName: _uniName.text.trim(),
      universityLogoUrl: _uniLogoUrl.text.trim().isEmpty ? null : _uniLogoUrl.text.trim(),
      universityWebsiteUrl: _uniWebsite.text.trim().isEmpty ? null : _uniWebsite.text.trim(),
      courseOverview: _courseOverview.text.trim().isEmpty ? null : _courseOverview.text.trim(),
      careerOpportunities: _careerOpps.text.trim().isEmpty ? null : _careerOpps.text.trim(),
      minGpa: double.tryParse(_minGpa.text),
      ieltsMinScore: double.tryParse(_ieltsScore.text),
      toeflMinScore: int.tryParse(_toeflScore.text),
      workExperienceRequired: _workExpRequired,
      scholarshipAvailable: _scholarshipAvailable,
      scholarshipDetails: _scholarshipDetails.text.trim().isEmpty ? null : _scholarshipDetails.text.trim(),
      applicationFee: int.tryParse(_appFee.text),
      applicationDeadline: _appDeadline.text.trim().isEmpty ? null : _appDeadline.text.trim(),
      universityRanking: int.tryParse(_uniRanking.text),
      universityLocation: _uniLocation.text.trim().isEmpty ? null : _uniLocation.text.trim(),
      applyUrl: _applyUrl.text.trim().isEmpty ? null : _applyUrl.text.trim(),
    );

    try {
      if (widget.existing == null) {
        await _supabase.from('courses').insert(model.toMap());
      } else {
        await _supabase.from('courses').update(model.toMap()).eq('id', model.id!);
      }
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.existing == null ? 'Course added!' : 'Course updated!'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [kPrimary, Color(0xFF283593)]),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    widget.existing == null ? 'Add Course' : 'Edit Course',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _SectionHeader('Course Information'),
                    _Field(_courseName, 'Course Name *', Icons.menu_book, required: true),
                    const SizedBox(height: 8),
                    const Text('Degree Type',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kPrimary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _degreeType,
                      decoration: _dec('Degree Type', Icons.school),
                      items: _degreeTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _degreeType = v!),
                    ),
                    const SizedBox(height: 14),
                    _FieldRow([
                      _Field(_duration, 'Duration (Years)', Icons.timer,
                          type: TextInputType.number),
                      _Field(_language, 'Language of Instruction', Icons.translate),
                    ]),

                    _SectionHeader('University Details'),
                    _Field(_uniName, 'University Name *', Icons.account_balance, required: true),
                    const SizedBox(height: 8),
                    _FieldRow([
                      _Field(_country, 'Country *', Icons.public, required: true),
                      _Field(_region, 'Region', Icons.map),
                    ]),
                    _FieldRow([
                      _Field(_uniLocation, 'University Location', Icons.location_on),
                      _Field(_uniRanking, 'University Ranking', Icons.leaderboard,
                          type: TextInputType.number),
                    ]),
                    _FieldRow([
                      _Field(_uniWebsite, 'University Website', Icons.language),
                      _Field(_uniLogoUrl, 'University Logo URL', Icons.image),
                    ]),

                    _SectionHeader('Fees & Intake'),
                    _FieldRow([
                      _Field(_tuitionFee, 'Tuition Fee/Year (\$)', Icons.attach_money,
                          type: TextInputType.number),
                      _Field(_appFee, 'Application Fee (\$)', Icons.payment,
                          type: TextInputType.number),
                    ]),
                    const SizedBox(height: 4),
                    const Text('Intake Month',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kPrimary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedIntake,
                      decoration: _dec('Select Intake Month', Icons.calendar_today),
                      items: _intakeMonths
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedIntake = v),
                    ),
                    const SizedBox(height: 14),
                    _Field(_appDeadline, 'Application Deadline', Icons.event),
                    _Field(_applyUrl, 'Apply URL', Icons.open_in_new),

                    _SectionHeader('Requirements'),
                    _Field(_minGpa, 'Minimum GPA', Icons.grade, type: TextInputType.number),
                    const SizedBox(height: 8),
                    _SwitchTile('IELTS Required', _ieltsRequired,
                        (v) => setState(() => _ieltsRequired = v)),
                    if (_ieltsRequired) ...[
                      const SizedBox(height: 6),
                      _FieldRow([
                        _Field(_ieltsScore, 'Min IELTS Score', Icons.score,
                            type: TextInputType.number),
                        _Field(_toeflScore, 'Min TOEFL Score', Icons.score,
                            type: TextInputType.number),
                      ]),
                    ],
                    _SwitchTile('Work Experience Required', _workExpRequired,
                        (v) => setState(() => _workExpRequired = v)),
                    _SwitchTile('Scholarship Available', _scholarshipAvailable,
                        (v) => setState(() => _scholarshipAvailable = v)),
                    if (_scholarshipAvailable) ...[
                      const SizedBox(height: 6),
                      _Field(_scholarshipDetails, 'Scholarship Details', Icons.card_giftcard, maxLines: 2),
                    ],

                    _SectionHeader('Overview & Careers'),
                    _Field(_courseOverview, 'Course Overview', Icons.info_outline, maxLines: 4),
                    const SizedBox(height: 8),
                    _Field(_careerOpps, 'Career Opportunities', Icons.work_outline, maxLines: 3),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _saving
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                widget.existing == null ? 'Add Course' : 'Update Course',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Widget _Field(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  bool required = false,
  int maxLines = 1,
  TextInputType type = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: type,
      decoration: _dec(label, icon),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
    ),
  );
}

Widget _FieldRow(List<Widget> children) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children
        .map((c) => Expanded(child: Padding(
              padding: EdgeInsets.only(
                  right: c == children.last ? 0 : 8),
              child: c,
            )))
        .toList(),
  );
}

InputDecoration _dec(String label, IconData icon) => InputDecoration(
  labelText: label,
  prefixIcon: Icon(icon, color: kPrimary, size: 18),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: kPrimary, width: 2),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  isDense: true,
);

Widget _SectionHeader(String title) => Padding(
  padding: const EdgeInsets.only(top: 8, bottom: 12),
  child: Row(
    children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(2),
      )),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: kPrimary)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: kPrimary.withOpacity(0.15))),
    ],
  ),
);

Widget _SwitchTile(String label, bool value, ValueChanged<bool> onChanged) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        dense: true,
        title: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        value: value,
        activeColor: kPrimary,
        onChanged: onChanged,
      ),
    );

Future<bool> _confirmDialog(
    BuildContext context, String title, String content) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ??
      false;
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kAccent, size: 16),
            const SizedBox(width: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 10)),
      );
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;

  const _EmptyState(this.message, this.icon, {this.onRefresh});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black12),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: Colors.black38, fontSize: 16)),
            if (onRefresh != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
}
