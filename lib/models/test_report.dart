enum RiskSeverity {
  normal,    // Fit for now
  attention, // Needs Specialist Clinic / Diagnostic Lab
  critical   // Needs Emergency Hospital Bed
}

enum RecommendationType {
  none,     // You are fit for now!
  clinic,   // Specialist Clinic / Lab
  hospital  // Emergency Hospital Bed
}

class ReportAnalysisResult {
  final RiskSeverity severity;
  final String headline;
  final String simpleExplanation;
  final List<String> keyFindings;
  final RecommendationType recommendationType;
  final String recommendationReason;
  final String? recommendedSpecialty;

  const ReportAnalysisResult({
    required this.severity,
    required this.headline,
    required this.simpleExplanation,
    required this.keyFindings,
    required this.recommendationType,
    required this.recommendationReason,
    this.recommendedSpecialty,
  });

  Map<String, dynamic> toJson() {
    return {
      'severity': severity.name,
      'headline': headline,
      'simpleExplanation': simpleExplanation,
      'keyFindings': keyFindings,
      'recommendationType': recommendationType.name,
      'recommendationReason': recommendationReason,
      'recommendedSpecialty': recommendedSpecialty,
    };
  }

  factory ReportAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ReportAnalysisResult(
      severity: RiskSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => RiskSeverity.normal,
      ),
      headline: json['headline'] ?? 'Report Analysis Complete',
      simpleExplanation: json['simpleExplanation'] ?? '',
      keyFindings: List<String>.from(json['keyFindings'] ?? []),
      recommendationType: RecommendationType.values.firstWhere(
        (e) => e.name == json['recommendationType'],
        orElse: () => RecommendationType.none,
      ),
      recommendationReason: json['recommendationReason'] ?? '',
      recommendedSpecialty: json['recommendedSpecialty'],
    );
  }
}

class TestReport {
  final String id;
  final String title;
  final String patientName;
  final String reportType;
  final DateTime date;
  final String rawText;
  final ReportAnalysisResult? analysis;

  const TestReport({
    required this.id,
    required this.title,
    required this.patientName,
    required this.reportType,
    required this.date,
    required this.rawText,
    this.analysis,
  });

  TestReport copyWith({
    String? id,
    String? title,
    String? patientName,
    String? reportType,
    DateTime? date,
    String? rawText,
    ReportAnalysisResult? analysis,
  }) {
    return TestReport(
      id: id ?? this.id,
      title: title ?? this.title,
      patientName: patientName ?? this.patientName,
      reportType: reportType ?? this.reportType,
      date: date ?? this.date,
      rawText: rawText ?? this.rawText,
      analysis: analysis ?? this.analysis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'patientName': patientName,
      'reportType': reportType,
      'date': date.toIso8601String(),
      'rawText': rawText,
      'analysis': analysis?.toJson(),
    };
  }

  factory TestReport.fromJson(Map<String, dynamic> json) {
    return TestReport(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Test Report',
      patientName: json['patientName'] ?? 'Patient',
      reportType: json['reportType'] ?? 'General Lab Test',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      rawText: json['rawText'] ?? '',
      analysis: json['analysis'] != null
          ? ReportAnalysisResult.fromJson(Map<String, dynamic>.from(json['analysis']))
          : null,
    );
  }
}
