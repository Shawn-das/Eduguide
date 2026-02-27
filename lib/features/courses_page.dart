import 'package:eduguide/features/course_details_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';



// CREATE TABLE courses (
//   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
//   course_name TEXT NOT NULL,
//   country TEXT NOT NULL,
//   region TEXT,
//   tuition_fee_per_year INTEGER,
//   language_of_instruction TEXT,
//   degree_type TEXT CHECK (degree_type IN ('Bachelor', 'Master', 'PhD', 'Diploma')),
//   duration_years INTEGER,
//   intake_month TEXT,
//   ielts_required BOOLEAN DEFAULT false,
//   university_name TEXT,
//   university_logo_url TEXT,
//   university_website_url TEXT,
//   created_at TIMESTAMPTZ DEFAULT NOW()
// );


class FindYourCoursePage extends StatefulWidget {
  const FindYourCoursePage({super.key});

  @override
  State<FindYourCoursePage> createState() => _FindYourCoursePageState();
}

class _FindYourCoursePageState extends State<FindYourCoursePage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  // Filter state
  String? _selectedCountry;
  String? _selectedRegion;
  double _maxTuitionFee = 100000;
  String? _selectedLanguage;
  final Set<String> _selectedDegrees = {};
  final Set<int> _selectedDurations = {};
  final Set<String> _selectedIntakeMonths = {};
  final Set<String> _selectedIelts = {};

  // Data
  List<String> _countries = [];
  List<String> _regions = [];
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = false;
  bool _isLoadingCountries = true;

  // Options
  final List<String> _degreeOptions = ['Bachelor', 'Master', 'PhD', 'Diploma'];
  final List<int> _durationOptions = [1, 2, 3, 4];
  final List<String> _intakeMonths = ['January', 'May', 'September'];
  final List<String> _ieltsOptions = ['IELTS Required', 'IELTS Not Required'];
  final List<String> _languageOptions = ['English', 'French', 'German', 'Spanish', 'Mandarin'];

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _searchCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Supabase Methods

  Future<void> _loadCountries() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('country')
          .order('country');

      final countries = (response as List)
          .map((e) => e['country'] as String)
          .toSet()
          .toList();

      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });
    } catch (e) {
      setState(() => _isLoadingCountries = false);
      _showError('Failed to load countries: $e');
    }
  }

  Future<void> _loadRegions(String country) async {
    try {
      final response = await _supabase
          .from('courses')
          .select('region')
          .eq('country', country)
          .order('region');

      final regions = (response as List)
          .map((e) => e['region'] as String)
          .where((r) => r.isNotEmpty)
          .toSet()
          .toList();

      setState(() {
        _regions = regions;
        _selectedRegion = null;
      });
    } catch (e) {
      _showError('Failed to load regions: $e');
    }
  }

  Future<void> _searchCourses() async {
    setState(() => _isLoading = true);

    try {
      var query = _supabase.from('courses').select('*');

      if (_selectedCountry != null) {
        query = query.eq('country', _selectedCountry!);
      }
      if (_selectedRegion != null) {
        query = query.eq('region', _selectedRegion!);
      }
      if (_selectedLanguage != null) {
        query = query.eq('language_of_instruction', _selectedLanguage!);
      }
      if (_selectedDegrees.isNotEmpty) {
        query = query.inFilter('degree_type', _selectedDegrees.toList());
      }
      if (_selectedDurations.isNotEmpty) {
        query = query.inFilter('duration_years', _selectedDurations.toList());
      }
      if (_selectedIntakeMonths.isNotEmpty) {
        query = query.inFilter('intake_month', _selectedIntakeMonths.toList());
      }
      if (_selectedIelts.isNotEmpty) {
        final requireIelts = _selectedIelts.contains('IELTS Required');
        final notRequireIelts = _selectedIelts.contains('IELTS Not Required');
        if (requireIelts && !notRequireIelts) {
          query = query.eq('ielts_required', true);
        } else if (!requireIelts && notRequireIelts) {
          query = query.eq('ielts_required', false);
        }
      }
      if (_searchController.text.isNotEmpty) {
        query = query.ilike('course_name', '%${_searchController.text}%');
      }

      query = query.lte('tuition_fee_per_year', _maxTuitionFee.toInt());

      final response = await query.order('created_at', ascending: false);

      setState(() {
        _courses = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Search failed: $e');
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      _showError('No website available for this university');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) _showError('Could not open website');
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCountry = null;
      _selectedRegion = null;
      _maxTuitionFee = 100000;
      _selectedLanguage = null;
      _selectedDegrees.clear();
      _selectedDurations.clear();
      _selectedIntakeMonths.clear();
      _selectedIelts.clear();
      _regions.clear();
      _searchController.clear();
    });
    _searchCourses();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
        title: const Column(
          children: [
            Text(
              'Find Your Course',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Filter and discover your ideal program',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  _buildSectionLabel('Select Country'),
                  _buildCountryDropdown(),
                  const SizedBox(height: 14),

                  _buildSectionLabel('Select Region'),
                  _buildRegionDropdown(),
                  const SizedBox(height: 14),

                  _buildSectionLabel('Tuition Fee (per year)'),
                  _buildTuitionSlider(),
                  const SizedBox(height: 14),

                  _buildSectionLabel('Language of Instruction'),
                  _buildLanguageDropdown(),
                  const SizedBox(height: 14),

                  _buildChipGroup(
                    options: _degreeOptions,
                    selected: _selectedDegrees,
                    onTap: (val) => setState(() {
                      _selectedDegrees.contains(val)
                          ? _selectedDegrees.remove(val)
                          : _selectedDegrees.add(val);
                    }),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionLabel('Duration'),
                  _buildChipGroup(
                    options: _durationOptions
                        .map((d) => d == 4 ? '4+ Years' : '$d Year${d > 1 ? 's' : ''}')
                        .toList(),
                    selected: _selectedDurations
                        .map((d) => d == 4 ? '4+ Years' : '$d Year${d > 1 ? 's' : ''}')
                        .toSet(),
                    onTap: (val) {
                      int dur = val.startsWith('4') ? 4 : int.parse(val[0]);
                      setState(() {
                        _selectedDurations.contains(dur)
                            ? _selectedDurations.remove(dur)
                            : _selectedDurations.add(dur);
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildSectionLabel('Intake Month'),
                  _buildChipGroup(
                    options: _intakeMonths,
                    selected: _selectedIntakeMonths,
                    onTap: (val) => setState(() {
                      _selectedIntakeMonths.contains(val)
                          ? _selectedIntakeMonths.remove(val)
                          : _selectedIntakeMonths.add(val);
                    }),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: _ieltsOptions.map((opt) {
                      final selected = _selectedIelts.contains(opt);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selected
                                ? _selectedIelts.remove(opt)
                                : _selectedIelts.add(opt);
                          }),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF1565C0) : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF1565C0)
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              opt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_courses.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No courses found. Try adjusting filters.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._courses.map((course) => _buildCourseCard(course)),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text(
                    'Reset Filters',
                    style: TextStyle(
                        color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _searchCourses,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Search Courses',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  UI Helpers 

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by course name (e.g., Computer Science)',
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
        ),
      ),
      onSubmitted: (_) => _searchCourses(),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _isLoadingCountries
          ? const LinearProgressIndicator()
          : DropdownButton<String>(
              value: _selectedCountry,
              hint: const Text('Select Country'),
              isExpanded: true,
              underline: const SizedBox(),
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedCountry = val);
                if (val != null) _loadRegions(val);
              },
            ),
    );
  }

  Widget _buildRegionDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: _selectedRegion,
        hint: const Text('Select Region'),
        isExpanded: true,
        underline: const SizedBox(),
        items: _regions
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: _selectedCountry == null
            ? null
            : (val) => setState(() => _selectedRegion = val),
      ),
    );
  }

  Widget _buildTuitionSlider() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1565C0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Up to \$${_maxTuitionFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} / year',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _maxTuitionFee,
            min: 0,
            max: 100000,
            divisions: 100,
            activeColor: const Color(0xFF1565C0),
            onChanged: (val) => setState(() => _maxTuitionFee = val),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: _selectedLanguage,
        hint: const Text('Select Language'),
        isExpanded: true,
        underline: const SizedBox(),
        items: _languageOptions
            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
            .toList(),
        onChanged: (val) => setState(() => _selectedLanguage = val),
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required Set<String> selected,
    required void Function(String) onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onTap(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1565C0) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final websiteUrl = course['university_website_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // University logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: course['university_logo_url'] != null
                    ? Image.network(
                        course['university_logo_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackLogo(),
                      )
                    : _fallbackLogo(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['course_name'] ?? 'Course Name',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    if (course['university_name'] != null)
                      Text(
                        course['university_name'],
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${course['tuition_fee_per_year'] ?? '—'}/year  •  '
                      '${course['duration_years'] ?? '—'} Years  •  '
                      '${course['language_of_instruction'] ?? '—'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailPage(course: course),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
                child: const Text('View\nDetails', textAlign: TextAlign.center),
              ),
            ],
          ),

          // University website link
          if (websiteUrl != null && websiteUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchURL(websiteUrl),
              child: Row(
                children: [
                  const Icon(Icons.language,
                      size: 16, color: Color(0xFF1565C0)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      websiteUrl,
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.open_in_new,
                      size: 14, color: Color(0xFF1565C0)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fallbackLogo() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade200,
      child: const Icon(Icons.school, color: Colors.grey),
    );
  }
}
