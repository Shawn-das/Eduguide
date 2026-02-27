import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CountryUniversitiesPage extends StatefulWidget {
  final dynamic country; // the country object passed as argument

  const CountryUniversitiesPage({super.key, required this.country});

  @override
  State<CountryUniversitiesPage> createState() =>
      _CountryUniversitiesPageState();
}

class _CountryUniversitiesPageState extends State<CountryUniversitiesPage> {
  final supabase = Supabase.instance.client;

  List _universities = [];
  List _filtered = [];
  bool _loading = true;
  String _search = '';
  String _sortBy = 'name'; // 'name' | 'ranking' | 'tuition'

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
  }

  String get _countryName =>
      widget.country['name']?.toString() ?? 'Unknown Country';

  String get _countryImage =>
      widget.country['image_url']?.toString() ?? '';

  Future<void> _fetchUniversities() async {
    setState(() => _loading = true);
    try {
      final data = await supabase
          .from('universities')
          .select()
          .ilike('country', '%$_countryName%')
          .order('name', ascending: true);

      setState(() {
        _universities = data;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading universities: $e');
      setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    List result = _universities.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final region = (u['region'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase()) ||
          region.contains(_search.toLowerCase());
    }).toList();

    // Sort
    result.sort((a, b) {
      if (_sortBy == 'ranking') {
        final ra = a['world_ranking'] ?? 99999;
        final rb = b['world_ranking'] ?? 99999;
        return ra.compareTo(rb);
      } else if (_sortBy == 'tuition') {
        final ta = a['avg_tuition_fee_per_year'] ?? 0;
        final tb = b['avg_tuition_fee_per_year'] ?? 0;
        return ta.compareTo(tb);
      }
      return (a['name'] ?? '').compareTo(b['name'] ?? '');
    });

    setState(() => _filtered = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.blue[700],
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 56),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _countryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Country banner image
                  if (_countryImage.isNotEmpty)
                    Image.network(
                      _countryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.blue.shade800,
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade900,
                            Colors.blue.shade500,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search + sort bar pinned at bottom of app bar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (v) {
                            _search = v;
                            _applyFilter();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search in $_countryName...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search,
                                size: 18, color: Colors.black38),
                            filled: true,
                            fillColor: const Color(0xFFF0F4FF),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort dropdown
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          icon: const Icon(Icons.sort, size: 16),
                          style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          items: const [
                            DropdownMenuItem(
                                value: 'name', child: Text('A–Z')),
                            DropdownMenuItem(
                                value: 'ranking', child: Text('Ranking')),
                            DropdownMenuItem(
                                value: 'tuition', child: Text('Tuition')),
                          ],
                          onChanged: (v) {
                            setState(() => _sortBy = v!);
                            _applyFilter();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blue))
            : _filtered.isEmpty
                ? _EmptyState(countryName: _countryName)
                : Column(
                    children: [
                      // Result count strip
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          '${_filtered.length} ${_filtered.length == 1 ? 'University' : 'Universities'} in $_countryName',
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _fetchUniversities,
                          color: Colors.blue,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) =>
                                _UniversityCard(
                              uni: _filtered[index],
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/universityDetails',
                                arguments: _filtered[index],
                              ),
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


// University Card

class _UniversityCard extends StatelessWidget {
  final dynamic uni;
  final VoidCallback onTap;

  const _UniversityCard({required this.uni, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasBanner = uni['banner_url'] != null &&
        (uni['banner_url'] as String).isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.09),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Banner / Gradient header
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: hasBanner
                  ? Image.network(
                      uni['banner_url'],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _GradientBanner(name: uni['name']),
                    )
                  : _GradientBanner(name: uni['name']),
            ),

            //  Logo + Name row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.blue.shade100, width: 1.5),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        uni['logo_url'] ?? '',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.blue.shade50,
                          child: const Icon(Icons.account_balance,
                              color: Colors.blue, size: 26),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uni['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A237E),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        if (uni['region'] != null ||
                            uni['country'] != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
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
                                      color: Colors.grey,
                                      fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (uni['founded_year'] != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.history,
                                  size: 13, color: Colors.black38),
                              const SizedBox(width: 3),
                              Text(
                                'Est. ${uni['founded_year']}',
                                style: const TextStyle(
                                    color: Colors.black38, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Ranking badge
                  if (uni['world_ranking'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.amber.shade300, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events,
                              size: 14, color: Colors.amber),
                          Text(
                            '#${uni['world_ranking']}',
                            style: TextStyle(
                                color: Colors.amber.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Badges 
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (uni['avg_tuition_fee_per_year'] != null)
                    _Chip('\$${uni['avg_tuition_fee_per_year']}/yr',
                        Icons.attach_money, Colors.green.shade700),
                  if (uni['campus_type'] != null)
                    _Chip(uni['campus_type'], Icons.location_city,
                        Colors.teal),
                  if (uni['acceptance_rate'] != null)
                    _Chip('${uni['acceptance_rate']}% accept',
                        Icons.percent, Colors.purple.shade600),
                  if (uni['total_students'] != null)
                    _Chip(
                        '${_formatNumber(uni['total_students'])} students',
                        Icons.people,
                        Colors.indigo.shade600),
                  _Chip(
                    uni['ielts_required'] == true
                        ? 'IELTS Required'
                        : 'No IELTS',
                    Icons.language,
                    uni['ielts_required'] == true
                        ? Colors.orange.shade700
                        : Colors.blue.shade600,
                  ),
                  if (uni['housing_available'] == true)
                    _Chip('Housing', Icons.home, Colors.brown.shade600),
                ],
              ),
            ),

            //  Overview 
            if (uni['overview'] != null &&
                (uni['overview'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Text(
                  uni['overview'],
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12.5,
                      height: 1.45),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Popular programs 
            if (uni['popular_programs'] != null &&
                (uni['popular_programs'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        uni['popular_programs'],
                        style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Footer 
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // Website
                  if (uni['website_url'] != null &&
                      (uni['website_url'] as String).isNotEmpty) ...[
                    const Icon(Icons.language,
                        size: 13, color: Colors.black38),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        uni['website_url']
                            .toString()
                            .replaceAll('https://', '')
                            .replaceAll('http://', ''),
                        style: const TextStyle(
                            color: Colors.black38, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),

                  // Deadline chip
                  if (uni['application_deadline'] != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.red.shade200, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 11, color: Colors.red.shade400),
                          const SizedBox(width: 3),
                          Text(
                            uni['application_deadline'],
                            style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(width: 8),

                  // View button
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(dynamic n) {
    final num = int.tryParse(n.toString()) ?? 0;
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)}k';
    return num.toString();
  }
}


// Helpers

class _GradientBanner extends StatelessWidget {
  final String? name;
  const _GradientBanner({this.name});

  @override
  Widget build(BuildContext context) => Container(
        height: 120,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.account_balance,
              color: Colors.white.withOpacity(0.25), size: 52),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Chip(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String countryName;
  const _EmptyState({required this.countryName});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No universities found\nin $countryName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black26, fontSize: 13),
            ),
          ],
        ),
      );
}