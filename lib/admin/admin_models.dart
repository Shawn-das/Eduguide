
// UNIVERSITY MODEL

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
        acceptanceRate: m['acceptance_rate'] != null ? double.tryParse(m['acceptance_rate'].toString()) : null,
        avgTuitionFee: m['avg_tuition_fee_per_year'],
        overview: m['overview'],
        foundedYear: m['founded_year'],
        totalStudents: m['total_students'],
        intlStudentsPercent: m['international_students_percent'] != null ? double.tryParse(m['international_students_percent'].toString()) : null,
        campusSize: m['campus_size'],
        campusType: m['campus_type'],
        facilities: m['facilities'],
        housingAvailable: m['housing_available'] ?? false,
        programsOffered: m['programs_offered'],
        popularPrograms: m['popular_programs'],
        minGpa: m['min_gpa'] != null ? double.tryParse(m['min_gpa'].toString()) : null,
        ieltsRequired: m['ielts_required'] ?? false,
        ieltsMinScore: m['ielts_min_score'] != null ? double.tryParse(m['ielts_min_score'].toString()) : null,
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
        if (intlStudentsPercent != null) 'international_students_percent': intlStudentsPercent,
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


// COURSE MODEL

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
        ieltsMinScore: m['ielts_min_score'] != null ? double.tryParse(m['ielts_min_score'].toString()) : null,
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
