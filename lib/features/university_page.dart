import 'package:eduguide/features/university_details_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// CREATE TABLE universities (
//   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
//   name TEXT NOT NULL,
//   country TEXT NOT NULL,
//   region TEXT,
//   logo_url TEXT,
//   banner_url TEXT,
//   website_url TEXT,
//   apply_url TEXT,
//   world_ranking INTEGER,
//   acceptance_rate NUMERIC(5,2),
//   avg_tuition_fee_per_year INTEGER,
//   overview TEXT,
//   founded_year INTEGER,
//   total_students INTEGER,
//   international_students_percent NUMERIC(5,2),
//   campus_size TEXT,
//   campus_type TEXT CHECK (campus_type IN ('Urban', 'Suburban', 'Rural')),
//   facilities TEXT,
//   housing_available BOOLEAN DEFAULT false,
//   programs_offered TEXT,
//   popular_programs TEXT,
//   min_gpa NUMERIC(3,2),
//   ielts_required BOOLEAN DEFAULT false,
//   ielts_min_score NUMERIC(3,1),
//   toefl_min_score INTEGER,
//   application_deadline TEXT,
//   application_fee INTEGER,
//   created_at TIMESTAMPTZ DEFAULT NOW()
// );

class FindUniversityPage extends StatefulWidget {
  const FindUniversityPage({super.key});

  @override
  State<FindUniversityPage> createState() => _FindUniversityPageState();
}

class _FindUniversityPageState extends State<FindUniversityPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  static const Color _primary = Color(0xFF1565C0);

  // Filter state
  String? _selectedCountry;
  String? _selectedRegion;
  double _maxTuitionFee = 100000;
  RangeValues _rankingRange = const RangeValues(1, 1000);
  RangeValues _acceptanceRange = const RangeValues(0, 100);

  // Data
  List<String> _countries = [];
  List<String> _regions = [];
  List<Map<String, dynamic>> _universities = [];
  bool _isLoading = false;
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _searchUniversities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Supabase Methods ────────────────────────────────────────────────────

  Future<void> _loadCountries() async {
    try {
      final response = await _supabase
          .from('universities')
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
      _showError('Failed to load countries');
    }
  }

  Future<void> _loadRegions(String country) async {
    try {
      final response = await _supabase
          .from('universities')
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
      _showError('Failed to load regions');
    }
  }

  Future<void> _searchUniversities() async {
    setState(() => _isLoading = true);
    try {
      var query = _supabase.from('universities').select('*');

      if (_selectedCountry != null) {
        query = query.eq('country', _selectedCountry!);
      }
      if (_selectedRegion != null) {
        query = query.eq('region', _selectedRegion!);
      }
      if (_searchController.text.isNotEmpty) {
        query = query.ilike('name', '%${_searchController.text}%');
      }

      query = query
          .gte('world_ranking', _rankingRange.start.toInt())
          .lte('world_ranking', _rankingRange.end.toInt())
          .lte('avg_tuition_fee_per_year', _maxTuitionFee.toInt())
          .gte('acceptance_rate', _acceptanceRange.start)
          .lte('acceptance_rate', _acceptanceRange.end);

      final response =
          await query.order('world_ranking', ascending: true);

      setState(() {
        _universities = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Search failed: $e');
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCountry = null;
      _selectedRegion = null;
      _maxTuitionFee = 100000;
      _rankingRange = const RangeValues(1, 1000);
      _acceptanceRange = const RangeValues(0, 100);
      _regions.clear();
      _searchController.clear();
    });
    _searchUniversities();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // ─── Build ───────────────────────────────────────────────────────────────

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
            Text('Find Your University',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text('Filter and discover your ideal university',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
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

                  _buildSectionLabel('World Ranking Range'),
                  _buildRankingSlider(),
                  const SizedBox(height: 14),

                  _buildSectionLabel('Tuition Fee (per year)'),
                  _buildTuitionSlider(),
                  const SizedBox(height: 14),

                  _buildSectionLabel('Acceptance Rate (%)'),
                  _buildAcceptanceSlider(),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_universities.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No universities found.\nTry adjusting your filters.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._universities.map((u) => _buildUniversityCard(u)),

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
                  child: const Text('Reset Filters',
                      style: TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _searchUniversities,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Search Universities',
                        style:
                            TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by university name...',
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: _primary)),
      ),
      onSubmitted: (_) => _searchUniversities(),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _isLoadingCountries
          ? const LinearProgressIndicator()
          : DropdownButton<String>(
              value: _selectedCountry,
              hint: const Text('Select Country'),
              isExpanded: true,
              underline: const SizedBox(),
              items: _countries
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
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
          borderRadius: BorderRadius.circular(10)),
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

  Widget _buildRankingSlider() {
    return _buildSliderCard(
      label:
          'Ranking: #${_rankingRange.start.toInt()} – #${_rankingRange.end.toInt()}',
      child: RangeSlider(
        values: _rankingRange,
        min: 1,
        max: 1000,
        divisions: 100,
        activeColor: _primary,
        labels: RangeLabels('#${_rankingRange.start.toInt()}',
            '#${_rankingRange.end.toInt()}'),
        onChanged: (val) => setState(() => _rankingRange = val),
      ),
    );
  }

  Widget _buildTuitionSlider() {
    return _buildSliderCard(
      label:
          'Up to \$${_formatNumber(_maxTuitionFee.toInt())} / year',
      child: Slider(
        value: _maxTuitionFee,
        min: 0,
        max: 100000,
        divisions: 100,
        activeColor: _primary,
        onChanged: (val) => setState(() => _maxTuitionFee = val),
      ),
    );
  }

  Widget _buildAcceptanceSlider() {
    return _buildSliderCard(
      label:
          'Acceptance: ${_acceptanceRange.start.toInt()}% – ${_acceptanceRange.end.toInt()}%',
      child: RangeSlider(
        values: _acceptanceRange,
        min: 0,
        max: 100,
        divisions: 100,
        activeColor: _primary,
        labels: RangeLabels('${_acceptanceRange.start.toInt()}%',
            '${_acceptanceRange.end.toInt()}%'),
        onChanged: (val) => setState(() => _acceptanceRange = val),
      ),
    );
  }

  Widget _buildSliderCard(
      {required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _primary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          child,
        ],
      ),
    );
  }

  Widget _buildUniversityCard(Map<String, dynamic> university) {
    final ranking = university['world_ranking'];
    final acceptance = university['acceptance_rate'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                UniversityDetailPage(university: university)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: university['logo_url'] != null
                  ? Image.network(university['logo_url'],
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackLogo())
                  : _fallbackLogo(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university['name'] ?? '—',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${university['region'] ?? ''}, ${university['country'] ?? ''}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (ranking != null)
                        _buildBadge('🏆 #$ranking',
                            Colors.amber.shade100, Colors.amber.shade800),
                      if (acceptance != null)
                        _buildBadge(
                            '${(acceptance as num).toStringAsFixed(0)}% Accept',
                            Colors.blue.shade50,
                            Colors.blue.shade700),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (university['avg_tuition_fee_per_year'] != null)
                    Text(
                      '\$${_formatNumber(university['avg_tuition_fee_per_year'])}/year avg',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _fallbackLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.school, color: Colors.grey, size: 28),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
