import 'dart:async';

import 'package:eduguide/pages/dash_board.dart';
import 'package:eduguide/pages/university_per_country_page.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Auth listener
  StreamSubscription<AuthState>? _authSubscription;

  List _countries = [];
  bool _isLoading = true;

  List _searchResults = [];
  bool _isSearching = false;
  bool _searchLoading = false;
  DateTime? _lastSearch;

  List _savedUniversities = [];
  List _savedCourses = [];
  bool _savedLoading = true;
  Map<String, String> _savedUniRowIds = {};
  Map<String, String> _savedCourseRowIds = {};
  int _savedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    _searchCtrl.addListener(_onSearchChanged);

    // ── KEY FIX: listen to auth state ──────────────────────────────────────
    // If user is already logged in → fetch immediately
    // If not yet → wait for the signedIn event
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      // Already authenticated — fetch right away
      _fetchSaved();
    } else {
      // Not yet authenticated — mark loading and wait
      setState(() => _savedLoading = true);
    }

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      debugPrint('Auth event: $event');
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.initialSession) {
        // User is now confirmed logged in — safe to fetch
        _fetchSaved();
      } else if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          setState(() {
            _savedUniversities = [];
            _savedCourses = [];
            _savedLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ─── Fetch home countries ─────────────────────────────────────────────────

  Future<void> _fetchHomeData() async {
    try {
      final countryData = await _supabase
          .from('countries')
          .select()
          .order('id')
          .limit(5);
      if (mounted) {
        setState(() {
          _countries = countryData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Home data error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Fetch saved items ────────────────────────────────────────────────────

  Future<void> _fetchSaved() async {
    if (mounted) setState(() => _savedLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      debugPrint('_fetchSaved called, userId: $userId');

      if (userId == null) {
        debugPrint('userId is null — skipping fetch');
        if (mounted) {
          setState(() {
            _savedUniversities = [];
            _savedCourses = [];
            _savedLoading = false;
          });
        }
        return;
      }

      // ── Saved Universities ────────────────────────────────────────────────
      final savedUniRows = await _supabase
          .from('saved_universities')
          .select('id, university_id, saved_at')
          .eq('user_id', userId)
          .order('saved_at', ascending: false);

      debugPrint('saved_universities rows: ${(savedUniRows as List).length}');

      final List<Map<String, dynamic>> uniResults = [];
      final Map<String, String> uniRowIds = {};

      if (savedUniRows.isNotEmpty) {
        final uniIds = savedUniRows
            .map((r) => r['university_id'].toString())
            .toList();

        debugPrint('Fetching universities with ids: $uniIds');

        final uniData = await _supabase
            .from('universities')
            .select()
            .inFilter('id', uniIds);

        debugPrint('universities fetched: ${(uniData as List).length}');

        // Preserve saved_at order
        for (final row in savedUniRows) {
          final uniId = row['university_id'].toString();
          final uni = (uniData).cast<Map<String, dynamic>>().firstWhere(
            (u) => u['id'].toString() == uniId,
            orElse: () => <String, dynamic>{},
          );
          if (uni.isNotEmpty) {
            uniResults.add(uni);
            uniRowIds[uniId] = row['id'].toString();
          }
        }
      }

      // ── Saved Courses ─────────────────────────────────────────────────────
      final savedCourseRows = await _supabase
          .from('saved_courses')
          .select('id, course_id, saved_at')
          .eq('user_id', userId)
          .order('saved_at', ascending: false);

      debugPrint('saved_courses rows: ${(savedCourseRows as List).length}');

      final List<Map<String, dynamic>> courseResults = [];
      final Map<String, String> courseRowIds = {};

      if ((savedCourseRows as List).isNotEmpty) {
        final courseIds = savedCourseRows
            .map((r) => r['course_id'].toString())
            .toList();

        final courseData = await _supabase
            .from('courses')
            .select()
            .inFilter('id', courseIds);

        for (final row in savedCourseRows) {
          final courseId = row['course_id'].toString();
          final course = (courseData as List).cast<Map<String, dynamic>>().firstWhere(
            (c) => c['id'].toString() == courseId,
            orElse: () => <String, dynamic>{},
          );
          if (course.isNotEmpty) {
            courseResults.add(course);
            courseRowIds[courseId] = row['id'].toString();
          }
        }
      }

      if (mounted) {
        setState(() {
          _savedUniversities = uniResults;
          _savedCourses = courseResults;
          _savedUniRowIds = uniRowIds;
          _savedCourseRowIds = courseRowIds;
          _savedLoading = false;
        });
        debugPrint('setState done: ${uniResults.length} unis, ${courseResults.length} courses');
      }
    } catch (e, stack) {
      debugPrint('Saved fetch error: $e');
      debugPrint('Stack: $stack');
      if (mounted) setState(() => _savedLoading = false);
    }
  }

  // ─── Remove saved ─────────────────────────────────────────────────────────

  Future<void> _removeSavedUniversity(String universityId) async {
    final savedRowId = _savedUniRowIds[universityId];
    if (savedRowId == null) return;
    try {
      await _supabase.from('saved_universities').delete().eq('id', savedRowId);
      setState(() {
        _savedUniversities.removeWhere(
            (u) => u['id'].toString() == universityId);
        _savedUniRowIds.remove(universityId);
      });
      _showSnack('Removed from saved', Colors.red.shade400);
    } catch (e) {
      debugPrint('Remove uni error: $e');
    }
  }

  Future<void> _removeSavedCourse(String courseId) async {
    final savedRowId = _savedCourseRowIds[courseId];
    if (savedRowId == null) return;
    try {
      await _supabase.from('saved_courses').delete().eq('id', savedRowId);
      setState(() {
        _savedCourses.removeWhere(
            (c) => c['id'].toString() == courseId);
        _savedCourseRowIds.remove(courseId);
      });
      _showSnack('Removed from saved', Colors.red.shade400);
    } catch (e) {
      debugPrint('Remove course error: $e');
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ─── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _searchLoading = true;
    });
    final now = DateTime.now();
    _lastSearch = now;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_lastSearch == now) _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    try {
      final results = await _supabase
          .from('universities')
          .select()
          .ilike('name', '%$query%')
          .limit(20);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _searchLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() {
      _isSearching = false;
      _searchResults = [];
      _searchLoading = false;
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0,
        title: const Text('EduGuide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const Drawer(child: DashboardDrawer()),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchHomeData();
                await _fetchSaved();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Welcome ──────────────────────────────────────────
                    const Text(
                      "Welcome back 👋",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // ── Search Bar ───────────────────────────────────────
                    TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(
                        hintText: "Search universities...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.black38, size: 20),
                                onPressed: _clearSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── SEARCH MODE ──────────────────────────────────────
                    if (_isSearching) ...[
                      if (_searchLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blue)),
                        )
                      else if (_searchResults.isEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(children: [
                              Icon(Icons.search_off,
                                  size: 56,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'No results for\n"${_searchCtrl.text}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14),
                              ),
                            ]),
                          ),
                        )
                      else ...[
                        Row(children: [
                          Text(
                            '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} found',
                            style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _clearSearch,
                            child: const Text('Clear',
                                style:
                                    TextStyle(color: Colors.blue)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        ..._searchResults
                            .map((uni) => _SearchUniversityCard(
                                  uni: uni,
                                  onTap: () {
                                    _searchFocus.unfocus();
                                    Navigator.pushNamed(
                                        context, '/universityDetails',
                                        arguments: uni);
                                  },
                                ))
                            .toList(),
                      ],
                    ],

                    // ── NORMAL MODE ──────────────────────────────────────
                    if (!_isSearching) ...[

                      // ── Featured Countries ────────────────────────────
                      _SectionTitle("Featured Countries"),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 160,
                        child: _countries.isEmpty
                            ? const Center(
                                child: Text("No countries available"))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _countries.length,
                                itemBuilder: (context, index) {
                                  final country = _countries[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CountryUniversitiesPage(
                                                country: country),
                                      ),
                                    ),
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(
                                          right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            country['image_url'] ??
                                                'https://via.placeholder.com/150',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 6,
                                              offset: Offset(0, 3))
                                        ],
                                      ),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.all(10),
                                        alignment:
                                            Alignment.bottomLeft,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black
                                                  .withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                            begin:
                                                Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                        child: Text(
                                          country['name'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 30),

                      // ── My Saved ──────────────────────────────────────
                      _SavedHeader(
                        savedTab: _savedTab,
                        uniCount: _savedUniversities.length,
                        courseCount: _savedCourses.length,
                        onTabChanged: (t) =>
                            setState(() => _savedTab = t),
                        onViewAll: () =>
                            Navigator.pushNamed(context, '/saved'),
                      ),
                      const SizedBox(height: 14),

                      if (_savedLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(
                                color: Colors.blue, strokeWidth: 2.5),
                          ),
                        )
                      else if (_savedTab == 0) ...[
                        if (_savedUniversities.isEmpty)
                          _EmptyState(
                            label: 'No saved universities yet',
                            icon: Icons.account_balance_outlined,
                            buttonLabel: 'Browse Universities',
                            onTap: () => Navigator.pushNamed(
                                context, '/university'),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _savedUniversities.length,
                              itemBuilder: (_, i) {
                                final uni = _savedUniversities[i];
                                return _SavedUniversityCard(
                                  uni: uni,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/universityDetails',
                                      arguments: uni),
                                  onRemove: () =>
                                      _removeSavedUniversity(
                                          uni['id'].toString()),
                                );
                              },
                            ),
                          ),
                      ] else ...[
                        if (_savedCourses.isEmpty)
                          _EmptyState(
                            label: 'No saved courses yet',
                            icon: Icons.menu_book_outlined,
                            buttonLabel: 'Browse Courses',
                            onTap: () => Navigator.pushNamed(
                                context, '/courses'),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _savedCourses.length,
                              itemBuilder: (_, i) {
                                final course = _savedCourses[i];
                                return _SavedCourseCard(
                                  course: course,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/courseDetails',
                                      arguments: course),
                                  onRemove: () =>
                                      _removeSavedCourse(
                                          course['id'].toString()),
                                );
                              },
                            ),
                          ),
                      ],

                      const SizedBox(height: 30),

                      // ── Suggestions Banner ────────────────────────────
                      _SectionTitle("Suggested For You"),
                      const SizedBox(height: 15),
                      _SuggestionsBanner(
                        onTap: () => Navigator.pushNamed(
                            context, '/suggestions'),
                      ),
                      const SizedBox(height: 24),

                      // ── Applications Banner ───────────────────────────
                      _SectionTitle("My Applications"),
                      const SizedBox(height: 15),
                      _ApplicationsBanner(
                        onTap: () => Navigator.pushNamed(
                            context, '/applications'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved Header
// ─────────────────────────────────────────────────────────────────────────────

class _SavedHeader extends StatelessWidget {
  final int savedTab, uniCount, courseCount;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onViewAll;

  const _SavedHeader({
    required this.savedTab,
    required this.uniCount,
    required this.courseCount,
    required this.onTabChanged,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.bookmark_rounded,
              color: Color(0xFF1A237E), size: 20),
          const SizedBox(width: 6),
          const Text('My Saved',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: const Text('View all →',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TabBtn(
                  label: 'Universities',
                  icon: Icons.account_balance_rounded,
                  count: uniCount,
                  selected: savedTab == 0,
                  color: Colors.blue.shade700,
                  onTap: () => onTabChanged(0)),
              _TabBtn(
                  label: 'Courses',
                  icon: Icons.menu_book_rounded,
                  count: courseCount,
                  selected: savedTab == 1,
                  color: Colors.purple.shade700,
                  onTap: () => onTabChanged(1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.white : Colors.black38),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black45)),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.25)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : color)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved University Card
// ─────────────────────────────────────────────────────────────────────────────

class _SavedUniversityCard extends StatelessWidget {
  final dynamic uni;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedUniversityCard(
      {required this.uni,
      required this.onTap,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 195,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: uni['banner_url'] != null &&
                        (uni['banner_url'] as String).isNotEmpty
                    ? Image.network(uni['banner_url'],
                        height: 72,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _BlueBanner())
                    : _BlueBanner(),
              ),
              Positioned(
                bottom: -16,
                left: 12,
                child: _LogoBadge(
                    logoUrl: uni['logo_url'], isUniversity: true),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: _RemoveBtn(onRemove: onRemove),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 22, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypeBadge(
                      label: 'University',
                      color: Colors.blue.shade700),
                  const SizedBox(height: 5),
                  Text(
                    uni['name'] ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A237E),
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _LocationRow(
                    text: [uni['region'], uni['country']]
                        .where((e) =>
                            e != null && e.toString().isNotEmpty)
                        .join(', '),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _CardFooter(
              color: Colors.blue.shade700,
              leftContent: uni['world_ranking'] != null
                  ? '# ${uni['world_ranking']} Ranked'
                  : uni['avg_tuition_fee_per_year'] != null
                      ? '\$${uni['avg_tuition_fee_per_year']}/yr'
                      : 'View details',
              leftIcon: uni['world_ranking'] != null
                  ? Icons.emoji_events
                  : uni['avg_tuition_fee_per_year'] != null
                      ? Icons.attach_money
                      : Icons.info_outline,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved Course Card
// ─────────────────────────────────────────────────────────────────────────────

class _SavedCourseCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedCourseCard(
      {required this.course,
      required this.onTap,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 195,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.purple.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: _PurpleBanner(),
              ),
              Positioned(
                bottom: -16,
                left: 12,
                child: _LogoBadge(
                    logoUrl: course['university_logo_url'],
                    isUniversity: false),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: _RemoveBtn(onRemove: onRemove),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 22, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypeBadge(
                    label: course['degree_type'] ?? 'Course',
                    color: Colors.purple.shade700,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    course['course_name'] ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A237E),
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _LocationRow(
                      text: course['university_name'] ?? ''),
                ],
              ),
            ),
            const Spacer(),
            _CardFooter(
              color: Colors.purple.shade700,
              leftContent: course['tuition_fee_per_year'] != null
                  ? '\$${course['tuition_fee_per_year']}/yr'
                  : course['duration_years'] != null
                      ? '${course['duration_years']} Years'
                      : 'View details',
              leftIcon: course['tuition_fee_per_year'] != null
                  ? Icons.attach_money
                  : Icons.timer,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BlueBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Center(
            child: Icon(Icons.account_balance,
                color: Colors.white.withOpacity(0.2), size: 32)),
      );
}

class _PurpleBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFBA68C8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Center(
            child: Icon(Icons.menu_book,
                color: Colors.white.withOpacity(0.2), size: 32)),
      );
}

class _LogoBadge extends StatelessWidget {
  final String? logoUrl;
  final bool isUniversity;
  const _LogoBadge({this.logoUrl, required this.isUniversity});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: logoUrl != null && logoUrl!.isNotEmpty
              ? Image.network(logoUrl!,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback())
              : _fallback(),
        ),
      );

  Widget _fallback() => Container(
        width: 38,
        height: 38,
        color: isUniversity
            ? Colors.blue.shade50
            : Colors.purple.shade50,
        child: Icon(
            isUniversity ? Icons.account_balance : Icons.menu_book,
            color: isUniversity ? Colors.blue : Colors.purple,
            size: 18),
      );
}

class _RemoveBtn extends StatelessWidget {
  final VoidCallback onRemove;
  const _RemoveBtn({required this.onRemove});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.bookmark_remove,
              color: Colors.white, size: 14),
        ),
      );
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5)),
      );
}

class _LocationRow extends StatelessWidget {
  final String text;
  const _LocationRow({required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.location_on, size: 11, color: Colors.grey),
          const SizedBox(width: 2),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ],
      );
}

class _CardFooter extends StatelessWidget {
  final Color color;
  final String? leftContent;
  final IconData? leftIcon;
  const _CardFooter(
      {required this.color, this.leftContent, this.leftIcon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(18)),
        ),
        child: Row(
          children: [
            if (leftContent != null && leftIcon != null) ...[
              Icon(leftIcon!, size: 12, color: color),
              const SizedBox(width: 3),
              Expanded(
                  child: Text(leftContent!,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color),
                      overflow: TextOverflow.ellipsis)),
            ] else
              const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 10, color: color.withOpacity(0.5)),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String label, buttonLabel;
  final IconData icon;
  final VoidCallback onTap;
  const _EmptyState(
      {required this.label,
      required this.icon,
      required this.buttonLabel,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.blue.shade50, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34, color: Colors.black12),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.black38, fontSize: 13)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(buttonLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Result Card
// ─────────────────────────────────────────────────────────────────────────────

class _SearchUniversityCard extends StatelessWidget {
  final dynamic uni;
  final VoidCallback onTap;
  const _SearchUniversityCard(
      {required this.uni, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasBanner = uni['banner_url'] != null &&
        (uni['banner_url'] as String).isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.09),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
          border:
              Border.all(color: Colors.blue.shade50, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
              child: hasBanner
                  ? Image.network(uni['banner_url'],
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          SizedBox(height: 72, child: _BlueBanner()))
                  : SizedBox(height: 72, child: _BlueBanner()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(uni['logo_url'] ?? '',
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                    BorderRadius.circular(12)),
                            child: const Icon(Icons.account_balance,
                                color: Colors.blue, size: 26))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(uni['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1A237E)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                              child: Text(
                            [uni['region'], uni['country']]
                                .where((e) =>
                                    e != null &&
                                    e.toString().isNotEmpty)
                                .join(', '),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Wrap(spacing: 6, runSpacing: 4, children: [
                if (uni['world_ranking'] != null)
                  _MiniChip('# ${uni['world_ranking']} World',
                      Colors.amber.shade700),
                if (uni['avg_tuition_fee_per_year'] != null)
                  _MiniChip(
                      '\$${uni['avg_tuition_fee_per_year']}/yr',
                      Colors.green.shade700),
                if (uni['campus_type'] != null)
                  _MiniChip(uni['campus_type'], Colors.teal),
                if (uni['acceptance_rate'] != null)
                  _MiniChip('${uni['acceptance_rate']}% Accept',
                      Colors.purple.shade600),
                _MiniChip(
                  uni['ielts_required'] == true
                      ? 'IELTS Required'
                      : 'No IELTS',
                  uni['ielts_required'] == true
                      ? Colors.orange.shade700
                      : Colors.blue.shade700,
                ),
              ]),
            ),
            if (uni['overview'] != null &&
                (uni['overview'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Text(uni['overview'],
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.45),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  if (uni['application_deadline'] != null) ...[
                    const Icon(Icons.calendar_today,
                        size: 13, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                        'Deadline: ${uni['application_deadline']}',
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 12)),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                    child: const Text('View Details',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700)));
}

// ─────────────────────────────────────────────────────────────────────────────
// Suggestions Banner
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SuggestionsBanner({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Row(children: [
            Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 32)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Suggestions based on your profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                      'Get university & course picks tailored to your profile and goals.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.5,
                          height: 1.4)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Explore Suggestions →',
                        style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ])),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Applications Banner
// ─────────────────────────────────────────────────────────────────────────────

class _ApplicationsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ApplicationsBanner({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.blue.shade100, width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4))
            ],
          ),
          child: Row(children: [
            Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.orange,
                    size: 32)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('My Applications',
                      style: TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text(
                      'Track and manage all your university applications in one place.',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.5,
                          height: 1.4)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _StatusChip('Pending', Colors.orange),
                    const SizedBox(width: 6),
                    _StatusChip('Accepted', Colors.green),
                    const SizedBox(width: 6),
                    _StatusChip('Review', Colors.blue),
                  ]),
                ])),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.black26, size: 28),
          ]),
        ),
      );
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700)));
}
