import 'package:eduguide/admin/admin_dashboard.dart';
import 'package:eduguide/admin/admin_models.dart';
import 'package:flutter/material.dart';
import 'admin_widgets.dart';

// COURSE TAB
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
      final res = await supabase
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
    final confirm = await showConfirmDialog(context, 'Delete "${c.courseName}"?',
        'This will permanently remove the course.');
    if (!confirm) return;
    try {
      await supabase.from('courses').delete().eq('id', c.id!);
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
                StatChip('Total Courses', '${_courses.length}', Icons.menu_book),
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
                  ? EmptyState('No courses found', Icons.menu_book_outlined,
                      onRefresh: _loadData)
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: kPrimary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final c = _filtered[i];
                          return CourseCard(
                            course: c,
                            onEdit: () => showCourseFormSheet(context, c, _loadData),
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

// COURSE CARD

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard(
      {super.key, required this.course, required this.onEdit, required this.onDelete});

  Color _degreeColor() {
    switch (course.degreeType?.toLowerCase()) {
      case 'bachelor': return Colors.blue.shade700;
      case 'master':   return Colors.purple.shade700;
      case 'phd':      return Colors.red.shade700;
      default:         return Colors.teal;
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: _degreeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.school, color: _degreeColor(), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.courseName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kPrimary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(c.universityName,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            ActionBtn(Icons.edit, kAccent, onEdit),
            const SizedBox(width: 6),
            ActionBtn(Icons.delete, Colors.red.shade300, onDelete),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 4, children: [
            if (c.degreeType != null) BadgeChip(c.degreeType!, _degreeColor()),
            if (c.country.isNotEmpty) BadgeChip(c.country, Colors.indigo.shade600),
            if (c.durationYears != null)
              BadgeChip('${c.durationYears} yr${c.durationYears! > 1 ? 's' : ''}', Colors.orange.shade700),
            if (c.tuitionFeePerYear != null)
              BadgeChip('\$${c.tuitionFeePerYear}/yr', Colors.green.shade700),
            if (c.intakeMonth != null) BadgeChip(c.intakeMonth!, Colors.teal),
            if (c.scholarshipAvailable) BadgeChip('Scholarship', Colors.amber.shade800),
            BadgeChip(c.ieltsRequired ? 'IELTS Required' : 'No IELTS',
                c.ieltsRequired ? Colors.orange.shade700 : Colors.blue.shade700),
          ]),
          if (c.courseOverview != null && c.courseOverview!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(c.courseOverview!,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
                maxLines: 2, overflow: TextOverflow.ellipsis),
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
        ]),
      ),
    );
  }
}


// COURSE FORM SHEET (Add / Edit)


void showCourseFormSheet(
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
      _scholarshipDetails, _appFee, _appDeadline, _uniRanking, _uniLocation, _applyUrl;

  String _degreeType = 'Bachelor';
  bool _ieltsRequired = false;
  bool _workExpRequired = false;
  bool _scholarshipAvailable = false;
  String? _selectedIntake;

  final _degreeTypes = ['Bachelor', 'Master', 'PhD', 'Diploma', 'Certificate', 'Associate'];
  final _intakeMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
    'January / September', 'February / September', 'March / September',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _courseName         = TextEditingController(text: c?.courseName ?? '');
    _country            = TextEditingController(text: c?.country ?? '');
    _region             = TextEditingController(text: c?.region ?? '');
    _tuitionFee         = TextEditingController(text: c?.tuitionFeePerYear?.toString() ?? '');
    _language           = TextEditingController(text: c?.languageOfInstruction ?? 'English');
    _duration           = TextEditingController(text: c?.durationYears?.toString() ?? '');
    _intakeMonth        = TextEditingController(text: c?.intakeMonth ?? '');
    _uniName            = TextEditingController(text: c?.universityName ?? '');
    _uniLogoUrl         = TextEditingController(text: c?.universityLogoUrl ?? '');
    _uniWebsite         = TextEditingController(text: c?.universityWebsiteUrl ?? '');
    _courseOverview     = TextEditingController(text: c?.courseOverview ?? '');
    _careerOpps         = TextEditingController(text: c?.careerOpportunities ?? '');
    _minGpa             = TextEditingController(text: c?.minGpa?.toString() ?? '');
    _ieltsScore         = TextEditingController(text: c?.ieltsMinScore?.toString() ?? '');
    _toeflScore         = TextEditingController(text: c?.toeflMinScore?.toString() ?? '');
    _scholarshipDetails = TextEditingController(text: c?.scholarshipDetails ?? '');
    _appFee             = TextEditingController(text: c?.applicationFee?.toString() ?? '');
    _appDeadline        = TextEditingController(text: c?.applicationDeadline ?? '');
    _uniRanking         = TextEditingController(text: c?.universityRanking?.toString() ?? '');
    _uniLocation        = TextEditingController(text: c?.universityLocation ?? '');
    _applyUrl           = TextEditingController(text: c?.applyUrl ?? '');
    _degreeType           = c?.degreeType ?? 'Bachelor';
    _ieltsRequired        = c?.ieltsRequired ?? false;
    _workExpRequired      = c?.workExperienceRequired ?? false;
    _scholarshipAvailable = c?.scholarshipAvailable ?? false;
    _selectedIntake       = c?.intakeMonth;
  }

  @override
  void dispose() {
    for (final ctrl in [_courseName, _country, _region, _tuitionFee, _language, _duration,
      _intakeMonth, _uniName, _uniLogoUrl, _uniWebsite, _courseOverview, _careerOpps,
      _minGpa, _ieltsScore, _toeflScore, _scholarshipDetails, _appFee, _appDeadline,
      _uniRanking, _uniLocation, _applyUrl]) { ctrl.dispose(); }
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
        await supabase.from('courses').insert(model.toMap());
      } else {
        await supabase.from('courses').update(model.toMap()).eq('id', model.id!);
      }
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.existing == null ? 'Course added!' : 'Course updated!'),
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
              const Icon(Icons.menu_book, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(widget.existing == null ? 'Add Course' : 'Edit Course',
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
                buildSectionHeader('Course Information'),
                buildField(_courseName, 'Course Name *', Icons.menu_book, required: true),
                const SizedBox(height: 8),
                const Text('Degree Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _degreeType,
                  decoration: buildDecoration('Degree Type', Icons.school),
                  items: _degreeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _degreeType = v!),
                ),
                const SizedBox(height: 14),
                buildFieldRow([
                  buildField(_duration, 'Duration (Years)', Icons.timer, type: TextInputType.number),
                  buildField(_language, 'Language of Instruction', Icons.translate),
                ]),
                buildSectionHeader('University Details'),
                buildField(_uniName, 'University Name *', Icons.account_balance, required: true),
                const SizedBox(height: 8),
                buildFieldRow([
                  buildField(_country, 'Country *', Icons.public, required: true),
                  buildField(_region, 'Region', Icons.map),
                ]),
                buildFieldRow([
                  buildField(_uniLocation, 'University Location', Icons.location_on),
                  buildField(_uniRanking, 'University Ranking', Icons.leaderboard, type: TextInputType.number),
                ]),
                buildFieldRow([
                  buildField(_uniWebsite, 'University Website', Icons.language),
                  buildField(_uniLogoUrl, 'University Logo URL', Icons.image),
                ]),
                buildSectionHeader('Fees & Intake'),
                buildFieldRow([
                  buildField(_tuitionFee, 'Tuition Fee/Year (\$)', Icons.attach_money, type: TextInputType.number),
                  buildField(_appFee, 'Application Fee (\$)', Icons.payment, type: TextInputType.number),
                ]),
                const SizedBox(height: 4),
                const Text('Intake Month', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedIntake,
                  decoration: buildDecoration('Select Intake Month', Icons.calendar_today),
                  items: _intakeMonths.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _selectedIntake = v),
                ),
                const SizedBox(height: 14),
                buildField(_appDeadline, 'Application Deadline', Icons.event),
                buildField(_applyUrl, 'Apply URL', Icons.open_in_new),
                buildSectionHeader('Requirements'),
                buildField(_minGpa, 'Minimum GPA', Icons.grade, type: TextInputType.number),
                const SizedBox(height: 8),
                buildSwitchTile('IELTS Required', _ieltsRequired, (v) => setState(() => _ieltsRequired = v)),
                if (_ieltsRequired) ...[
                  const SizedBox(height: 6),
                  buildFieldRow([
                    buildField(_ieltsScore, 'Min IELTS Score', Icons.score, type: TextInputType.number),
                    buildField(_toeflScore, 'Min TOEFL Score', Icons.score, type: TextInputType.number),
                  ]),
                ],
                buildSwitchTile('Work Experience Required', _workExpRequired, (v) => setState(() => _workExpRequired = v)),
                buildSwitchTile('Scholarship Available', _scholarshipAvailable, (v) => setState(() => _scholarshipAvailable = v)),
                if (_scholarshipAvailable) ...[
                  const SizedBox(height: 6),
                  buildField(_scholarshipDetails, 'Scholarship Details', Icons.card_giftcard, maxLines: 2),
                ],
                buildSectionHeader('Overview & Careers'),
                buildField(_courseOverview, 'Course Overview', Icons.info_outline, maxLines: 4),
                const SizedBox(height: 8),
                buildField(_careerOpps, 'Career Opportunities', Icons.work_outline, maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(widget.existing == null ? 'Add Course' : 'Update Course',
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
