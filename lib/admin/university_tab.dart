import 'package:eduguide/admin/admin_dashboard.dart';
import 'package:eduguide/admin/admin_models.dart';
import 'package:flutter/material.dart';
import 'admin_widgets.dart';

// UNIVERSITY TAB

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
      final res = await supabase
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
    final confirm = await showConfirmDialog(context, 'Delete "${uni.name}"?',
        'This will permanently remove the university.');
    if (!confirm) return;
    try {
      await supabase.from('universities').delete().eq('id', uni.id!);
      _loadData();
      _showSnack('University deleted');
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

  List<UniversityModel> get _filtered => _universities
      .where((u) =>
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.country.toLowerCase().contains(_search.toLowerCase()))
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
                StatChip('Total', '${_universities.length}', Icons.account_balance),
              ]),
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
                      borderSide: BorderSide.none),
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
                  ? EmptyState('No universities found',
                      Icons.account_balance_outlined, onRefresh: _loadData)
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: kPrimary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final u = _filtered[i];
                          return UniversityCard(
                            university: u,
                            onEdit: () => showUniversityFormSheet(context, u, _loadData),
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

// UNIVERSITY CARD

class UniversityCard extends StatelessWidget {
  final UniversityModel university;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UniversityCard(
      {super.key,
      required this.university,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final u = university;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kPrimary, const Color(0xFF283593)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                if (u.logoUrl != null && u.logoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(u.logoUrl!,
                        width: 36, height: 36, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.account_balance, color: Colors.white70, size: 28)),
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          '${u.country}${u.region != null ? ', ${u.region}' : ''}',
                          style:
                              const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                ActionBtn(Icons.edit, kAccent, onEdit),
                const SizedBox(width: 6),
                ActionBtn(Icons.delete, Colors.red.shade300, onDelete),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (u.worldRanking != null)
                    BadgeChip('Rank #${u.worldRanking}', Colors.amber.shade700),
                  if (u.avgTuitionFee != null)
                    BadgeChip('\$${u.avgTuitionFee}/yr', Colors.green.shade700),
                  if (u.campusType != null) BadgeChip(u.campusType!, Colors.teal),
                  if (u.foundedYear != null)
                    BadgeChip('Est. ${u.foundedYear}', Colors.purple.shade700),
                  BadgeChip(
                    u.ieltsRequired ? 'IELTS Required' : 'No IELTS',
                    u.ieltsRequired ? Colors.orange.shade700 : Colors.blue.shade700,
                  ),
                ]),
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


// UNIVERSITY FORM SHEET (Add / Edit)

void showUniversityFormSheet(
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
    _name           = TextEditingController(text: u?.name ?? '');
    _country        = TextEditingController(text: u?.country ?? '');
    _region         = TextEditingController(text: u?.region ?? '');
    _logoUrl        = TextEditingController(text: u?.logoUrl ?? '');
    _bannerUrl      = TextEditingController(text: u?.bannerUrl ?? '');
    _websiteUrl     = TextEditingController(text: u?.websiteUrl ?? '');
    _applyUrl       = TextEditingController(text: u?.applyUrl ?? '');
    _worldRanking   = TextEditingController(text: u?.worldRanking?.toString() ?? '');
    _acceptanceRate = TextEditingController(text: u?.acceptanceRate?.toString() ?? '');
    _avgTuition     = TextEditingController(text: u?.avgTuitionFee?.toString() ?? '');
    _overview       = TextEditingController(text: u?.overview ?? '');
    _foundedYear    = TextEditingController(text: u?.foundedYear?.toString() ?? '');
    _totalStudents  = TextEditingController(text: u?.totalStudents?.toString() ?? '');
    _intlPercent    = TextEditingController(text: u?.intlStudentsPercent?.toString() ?? '');
    _campusSize     = TextEditingController(text: u?.campusSize ?? '');
    _facilities     = TextEditingController(text: u?.facilities ?? '');
    _programsOffered= TextEditingController(text: u?.programsOffered ?? '');
    _popularPrograms= TextEditingController(text: u?.popularPrograms ?? '');
    _minGpa         = TextEditingController(text: u?.minGpa?.toString() ?? '');
    _ieltsScore     = TextEditingController(text: u?.ieltsMinScore?.toString() ?? '');
    _toeflScore     = TextEditingController(text: u?.toeflMinScore?.toString() ?? '');
    _appDeadline    = TextEditingController(text: u?.applicationDeadline ?? '');
    _appFee         = TextEditingController(text: u?.applicationFee?.toString() ?? '');
    _campusType       = u?.campusType ?? 'Urban';
    _housingAvailable = u?.housingAvailable ?? false;
    _ieltsRequired    = u?.ieltsRequired ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _country, _region, _logoUrl, _bannerUrl, _websiteUrl,
      _applyUrl, _worldRanking, _acceptanceRate, _avgTuition, _overview,
      _foundedYear, _totalStudents, _intlPercent, _campusSize, _facilities,
      _programsOffered, _popularPrograms, _minGpa, _ieltsScore, _toeflScore,
      _appDeadline, _appFee]) { c.dispose(); }
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
        await supabase.from('universities').insert(model.toMap());
      } else {
        await supabase.from('universities').update(model.toMap()).eq('id', model.id!);
      }
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.existing == null ? 'University added!' : 'University updated!'),
        backgroundColor: kPrimary, behavior: SnackBarBehavior.floating,
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
      initialChildSize: 0.92, maxChildSize: 0.97, minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Center(child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [kPrimary, Color(0xFF283593)])),
            child: Row(children: [
              const Icon(Icons.account_balance, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(widget.existing == null ? 'Add University' : 'Edit University',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white70)),
            ]),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
                buildSectionHeader('Basic Information'),
                buildFieldRow([buildField(_name, 'University Name *', Icons.account_balance, required: true)]),
                buildFieldRow([
                  buildField(_country, 'Country *', Icons.public, required: true),
                  buildField(_region, 'Region / State', Icons.map),
                ]),
                buildFieldRow([
                  buildField(_websiteUrl, 'Website URL', Icons.language),
                  buildField(_applyUrl, 'Apply URL', Icons.open_in_new),
                ]),
                buildFieldRow([
                  buildField(_logoUrl, 'Logo URL', Icons.image),
                  buildField(_bannerUrl, 'Banner URL', Icons.panorama),
                ]),
                buildSectionHeader('Stats & Rankings'),
                buildFieldRow([
                  buildField(_worldRanking, 'World Ranking', Icons.leaderboard, type: TextInputType.number),
                  buildField(_acceptanceRate, 'Acceptance Rate (%)', Icons.percent, type: TextInputType.number),
                ]),
                buildFieldRow([
                  buildField(_avgTuition, 'Avg Tuition/Year (\$)', Icons.attach_money, type: TextInputType.number),
                  buildField(_foundedYear, 'Founded Year', Icons.history, type: TextInputType.number),
                ]),
                buildFieldRow([
                  buildField(_totalStudents, 'Total Students', Icons.people, type: TextInputType.number),
                  buildField(_intlPercent, 'Intl Students (%)', Icons.flight, type: TextInputType.number),
                ]),
                buildSectionHeader('Campus'),
                buildFieldRow([buildField(_campusSize, 'Campus Size', Icons.landscape)]),
                const SizedBox(height: 4),
                const Text('Campus Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _campusType,
                  decoration: buildDecoration('Campus Type', Icons.location_city),
                  items: _campusTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _campusType = v!),
                ),
                const SizedBox(height: 14),
                buildField(_facilities, 'Facilities (comma separated)', Icons.business, maxLines: 2),
                const SizedBox(height: 8),
                buildSwitchTile('Housing Available', _housingAvailable, (v) => setState(() => _housingAvailable = v)),
                buildSectionHeader('Programs'),
                buildField(_programsOffered, 'Programs Offered', Icons.list, maxLines: 2),
                const SizedBox(height: 8),
                buildField(_popularPrograms, 'Popular Programs', Icons.star, maxLines: 2),
                buildSectionHeader('Requirements'),
                buildFieldRow([buildField(_minGpa, 'Min GPA', Icons.grade, type: TextInputType.number)]),
                buildSwitchTile('IELTS Required', _ieltsRequired, (v) => setState(() => _ieltsRequired = v)),
                if (_ieltsRequired)
                  buildFieldRow([
                    buildField(_ieltsScore, 'Min IELTS Score', Icons.score, type: TextInputType.number),
                    buildField(_toeflScore, 'Min TOEFL Score', Icons.score, type: TextInputType.number),
                  ]),
                buildSectionHeader('Application'),
                buildFieldRow([
                  buildField(_appDeadline, 'Application Deadline', Icons.calendar_today),
                  buildField(_appFee, 'Application Fee (\$)', Icons.payment, type: TextInputType.number),
                ]),
                buildSectionHeader('Overview'),
                buildField(_overview, 'University Overview', Icons.info_outline, maxLines: 4),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(widget.existing == null ? 'Add University' : 'Update University',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
