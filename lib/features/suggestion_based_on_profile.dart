import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eduguide/features/course_details_page.dart';
import 'package:eduguide/features/university_details_page.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:eduguide/profile/qualification.dart';
import 'package:eduguide/profile/document_page.dart';
import 'package:eduguide/profile/scores.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> qualifications = [];
  Map<String, dynamic> examScores = {};

  List<Map<String, dynamic>> recommendedCourses = [];
  List<Map<String, dynamic>> recommendedUniversities = [];

  late TabController _tabController;

  static const int _topMatch = 85;
  static const int _goodMatch = 65;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllDataAndRecommend();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────── DATA LOADING ───────────────────────────

  Future<void> _loadAllDataAndRecommend() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final qualData = await supabase
          .from('qualifications')
          .select()
          .eq('user_id', user.id);

      final scoreData = await supabase
          .from('exam_scores')
          .select()
          .eq('user_id', user.id) as List<dynamic>;

      final scoresMap = {
        for (var item in scoreData) item['exam_type'] as String: item
      };

      final coursesData =
          await supabase.from('courses').select() as List<dynamic>;
      final universitiesData =
          await supabase.from('universities').select() as List<dynamic>;

      final userQuals = List<Map<String, dynamic>>.from(qualData);
      final double bestCgpa = _getBestCgpa(userQuals);
      final double? ieltsScore = _getScore(scoresMap, 'IELTS', 'overall');
      final double? toeflScore = _getScore(scoresMap, 'TOEFL', 'overall');
      final String userCountry =
          (profileData['country'] ?? '').toString().toLowerCase();

      final scoredCourses = coursesData
          .map((c) {
            final course = Map<String, dynamic>.from(c as Map);
            final score = _scoreCourse(
              course: course,
              bestCgpa: bestCgpa,
              ieltsScore: ieltsScore,
              toeflScore: toeflScore,
              userCountry: userCountry,
              qualifications: userQuals,
            );
            course['_matchScore'] = score;
            return course;
          })
          .where((c) => c['_matchScore'] >= _goodMatch)
          .toList()
        ..sort((a, b) =>
            (b['_matchScore'] as int).compareTo(a['_matchScore'] as int));

      final scoredUniversities = universitiesData
          .map((u) {
            final uni = Map<String, dynamic>.from(u as Map);
            final score = _scoreUniversity(
              uni: uni,
              bestCgpa: bestCgpa,
              ieltsScore: ieltsScore,
              toeflScore: toeflScore,
              userCountry: userCountry,
            );
            uni['_matchScore'] = score;
            return uni;
          })
          .where((u) => u['_matchScore'] >= _goodMatch)
          .toList()
        ..sort((a, b) =>
            (b['_matchScore'] as int).compareTo(a['_matchScore'] as int));

      setState(() {
        profile = profileData;
        qualifications = userQuals;
        examScores = scoresMap;
        recommendedCourses = scoredCourses.take(20).toList();
        recommendedUniversities = scoredUniversities.take(20).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ─────────────────────────── SCORING LOGIC ───────────────────────────

  double _getBestCgpa(List<Map<String, dynamic>> quals) {
    if (quals.isEmpty) return 0;
    double best = 0;
    for (final q in quals) {
      final val = double.tryParse(q['cgpa']?.toString() ?? '') ?? 0;
      if (val > best) best = val;
    }
    return best;
  }

  double? _getScore(Map<String, dynamic> scores, String exam, String field) {
    if (!scores.containsKey(exam)) return null;
    return double.tryParse(scores[exam][field]?.toString() ?? '');
  }

  int _scoreCourse({
    required Map<String, dynamic> course,
    required double bestCgpa,
    required double? ieltsScore,
    required double? toeflScore,
    required String userCountry,
    required List<Map<String, dynamic>> qualifications,
  }) {
    int score = 60;

    final minGpa = double.tryParse(course['min_gpa']?.toString() ?? '') ?? 0;
    if (minGpa > 0) {
      if (bestCgpa >= minGpa) {
        score += 15;
      } else {
        score -= 20;
      }
    } else {
      score += 10;
    }

    final requiresIelts = course['ielts_required'] == true;
    final minIelts =
        double.tryParse(course['ielts_min_score']?.toString() ?? '') ?? 0;
    if (requiresIelts && minIelts > 0) {
      if (ieltsScore != null && ieltsScore >= minIelts) {
        score += 10;
      } else if (ieltsScore == null) {
        score -= 10;
      } else {
        score -= 15;
      }
    } else if (!requiresIelts) {
      score += 5;
    }

    final minToefl =
        int.tryParse(course['toefl_min_score']?.toString() ?? '') ?? 0;
    if (minToefl > 0 && toeflScore != null) {
      if (toeflScore >= minToefl) score += 5;
    }

    final courseCountry = (course['country'] ?? '').toString().toLowerCase();
    if (courseCountry == userCountry) score += 5;

    final degreeType = (course['degree_type'] ?? '').toString().toLowerCase();
    final highestQual = _getHighestQualification(qualifications);
    if (_degreeTypeMatches(degreeType, highestQual)) score += 5;

    return score.clamp(0, 100);
  }

  int _scoreUniversity({
    required Map<String, dynamic> uni,
    required double bestCgpa,
    required double? ieltsScore,
    required double? toeflScore,
    required String userCountry,
  }) {
    int score = 60;

    final minGpa = double.tryParse(uni['min_gpa']?.toString() ?? '') ?? 0;
    if (minGpa > 0) {
      if (bestCgpa >= minGpa) {
        score += 15;
      } else {
        score -= 20;
      }
    } else {
      score += 10;
    }

    final requiresIelts = uni['ielts_required'] == true;
    final minIelts =
        double.tryParse(uni['ielts_min_score']?.toString() ?? '') ?? 0;
    if (requiresIelts && minIelts > 0) {
      if (ieltsScore != null && ieltsScore >= minIelts) {
        score += 10;
      } else if (ieltsScore == null) {
        score -= 10;
      } else {
        score -= 15;
      }
    } else if (!requiresIelts) {
      score += 5;
    }

    final minToefl =
        int.tryParse(uni['toefl_min_score']?.toString() ?? '') ?? 0;
    if (minToefl > 0 && toeflScore != null) {
      if (toeflScore >= minToefl) score += 5;
    }

    final acceptance =
        double.tryParse(uni['acceptance_rate']?.toString() ?? '') ?? 0;
    if (acceptance > 40) score += 5;

    return score.clamp(0, 100);
  }

  String _getHighestQualification(List<Map<String, dynamic>> quals) {
    const order = ['SSC', 'HSC', 'Diploma', 'Bachelor', 'Master'];
    String highest = '';
    int highestIdx = -1;
    for (final q in quals) {
      final qual = q['qualification']?.toString() ?? '';
      final idx = order.indexOf(qual);
      if (idx > highestIdx) {
        highestIdx = idx;
        highest = qual;
      }
    }
    return highest;
  }

  bool _degreeTypeMatches(String degreeType, String highestQual) {
    if (highestQual == 'Bachelor' || highestQual == 'Diploma') {
      return degreeType.contains('master') ||
          degreeType.contains('msc') ||
          degreeType.contains('mba');
    }
    if (highestQual == 'HSC' || highestQual == 'SSC') {
      return degreeType.contains('bachelor') ||
          degreeType.contains('bsc') ||
          degreeType.contains('ba');
    }
    return true;
  }

  // ─────────────────────────── HELPER UI ───────────────────────────

  Color _matchColor(int score) {
    if (score >= _topMatch) return const Color(0xFF22C55E);
    if (score >= 75) return const Color(0xFF3B82F6);
    return const Color(0xFFF59E0B);
  }

  String _matchLabel(int score) {
    if (score >= _topMatch) return 'Top Match';
    if (score >= 75) return 'Great Match';
    return 'Good Match';
  }

  // ─────────────────────────── CUSTOM BOTTOM NAV (no item selected) ───────────────────────────

  Widget _buildBottomNav() {
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

  Widget _navItem(
      BuildContext context, IconData icon, String label, int index) {
    // No item is "active" on this page
    return GestureDetector(
      onTap: () {
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
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── BUILD ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        // ✅ Back arrow will take user back to home/wherever they came from
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Recommendations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadAllDataAndRecommend,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
              icon: const Icon(Icons.school_outlined),
              text: 'Courses (${recommendedCourses.length})',
            ),
            Tab(
              icon: const Icon(Icons.account_balance_outlined),
              text: 'Universities (${recommendedUniversities.length})',
            ),
          ],
        ),
      ),
      body: isLoading
          ? _buildLoading()
          : errorMessage != null
              ? _buildError()
              : Column(
                  children: [
                    _buildProfileSummaryBanner(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCoursesList(),
                          _buildUniversitiesList(),
                        ],
                      ),
                    ),
                  ],
                ),
      // ✅ Custom bottom nav with NO tab highlighted
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            'Analyzing your profile...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(errorMessage ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAllDataAndRecommend,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummaryBanner() {
    final bestCgpa = _getBestCgpa(qualifications);
    final ielts = _getScore(examScores, 'IELTS', 'overall');
    final country = profile?['country'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Based on your profile · GPA: ${bestCgpa.toStringAsFixed(2)} · IELTS: ${ielts?.toStringAsFixed(1) ?? 'N/A'} · $country',
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── COURSES LIST ───────────────────────────

  Widget _buildCoursesList() {
    if (recommendedCourses.isEmpty) {
      return _buildEmptyState(
          'No matching courses found',
          'Try updating your qualifications or exam scores to get better matches.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: recommendedCourses.length,
      itemBuilder: (context, index) {
        final course = recommendedCourses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final matchScore = course['_matchScore'] as int;
    final color = _matchColor(matchScore);
    final label = _matchLabel(matchScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(course: course),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: course['university_logo_url'] != null &&
                            (course['university_logo_url'] as String).isNotEmpty
                        ? Image.network(
                            course['university_logo_url'],
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultLogoBox(),
                          )
                        : _defaultLogoBox(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['course_name'] ?? 'Unknown Course',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course['university_name'] ?? '',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$matchScore%',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        Text(label,
                            style: TextStyle(color: color, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _chip(Icons.location_on_outlined, course['country'] ?? ''),
                  _chip(Icons.school_outlined, course['degree_type'] ?? ''),
                  if (course['tuition_fee_per_year'] != null)
                    _chip(Icons.attach_money,
                        '\$${course['tuition_fee_per_year']}/yr'),
                  if (course['duration_years'] != null)
                    _chip(Icons.schedule, '${course['duration_years']} yrs'),
                  if (course['scholarship_available'] == true)
                    _chip(Icons.card_giftcard, 'Scholarship',
                        color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── UNIVERSITIES LIST ───────────────────────────

  Widget _buildUniversitiesList() {
    if (recommendedUniversities.isEmpty) {
      return _buildEmptyState(
          'No matching universities found',
          'Update your profile or exam scores to get university suggestions.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: recommendedUniversities.length,
      itemBuilder: (context, index) {
        final uni = recommendedUniversities[index];
        return _buildUniversityCard(uni);
      },
    );
  }

  Widget _buildUniversityCard(Map<String, dynamic> uni) {
    final matchScore = uni['_matchScore'] as int;
    final color = _matchColor(matchScore);
    final label = _matchLabel(matchScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UniversityDetailPage(university: uni),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: uni['logo_url'] != null &&
                            (uni['logo_url'] as String).isNotEmpty
                        ? Image.network(
                            uni['logo_url'],
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultLogoBox(),
                          )
                        : _defaultLogoBox(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uni['name'] ?? 'Unknown University',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${uni['country'] ?? ''} · ${uni['campus_type'] ?? ''}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$matchScore%',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        Text(label,
                            style: TextStyle(color: color, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (uni['world_ranking'] != null)
                    _chip(Icons.emoji_events_outlined,
                        'Rank #${uni['world_ranking']}',
                        color: Colors.amber.shade700),
                  _chip(Icons.location_on_outlined, uni['country'] ?? ''),
                  if (uni['acceptance_rate'] != null)
                    _chip(Icons.how_to_reg_outlined,
                        'Acceptance: ${uni['acceptance_rate']}%'),
                  if (uni['avg_tuition_fee_per_year'] != null)
                    _chip(Icons.attach_money,
                        '\$${uni['avg_tuition_fee_per_year']}/yr'),
                  if (uni['housing_available'] == true)
                    _chip(Icons.home_outlined, 'Housing',
                        color: Colors.indigo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── SMALL WIDGETS ───────────────────────────

  Widget _chip(IconData icon, String label, {Color? color}) {
    final c = color ?? Colors.blueGrey.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: c)),
        ],
      ),
    );
  }

  Widget _defaultLogoBox() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.account_balance, color: Colors.blue, size: 22),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 70, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
