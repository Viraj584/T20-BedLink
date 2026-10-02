import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/test_report.dart';
import '../services/report_analysis_service.dart';
import '../services/openrouter_service.dart';

final reportAnalysisServiceProvider = Provider<ReportAnalysisService>((ref) {
  return ReportAnalysisService();
});

final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  final fallback = ref.watch(reportAnalysisServiceProvider);
  return OpenRouterService(fallbackService: fallback);
});

class OpenRouterApiKeyNotifier extends Notifier<String> {
  @override
  String build() => AppConstants.openRouterApiKey;

  void setApiKey(String key) {
    state = key;
  }
}

final openRouterApiKeyProvider =
    NotifierProvider<OpenRouterApiKeyNotifier, String>(
        OpenRouterApiKeyNotifier.new);

class PatientReportsNotifier extends Notifier<List<TestReport>> {
  @override
  List<TestReport> build() {
    final analyzer = ref.read(reportAnalysisServiceProvider);

    // Initial realistic sample reports
    final sample1 = TestReport(
      id: 'rep_001',
      title: 'Complete Blood Count (CBC) & Anemia Screen',
      patientName: 'Patient (Self)',
      reportType: 'Pathology Blood Test',
      date: DateTime.now().subtract(const Duration(days: 2)),
      rawText: '''
PATIENT BLOOD REPORT
Hemoglobin: 9.8 g/dL (Normal Range: 12.0 - 16.0) -> LOW
WBC Count: 6,800 /uL (Normal Range: 4,000 - 11,000) -> NORMAL
Platelet Count: 245,000 /uL -> NORMAL
RBC Count: 3.9 Million/uL -> SLIGHTLY LOW
Conclusion: Microcytic Mild Anemia observed. Low iron saturation.
''',
    );

    final sample2 = TestReport(
      id: 'rep_002',
      title: 'Thyroid Hormone Profile (T3, T4, TSH)',
      patientName: 'Patient (Self)',
      reportType: 'Endocrine Diagnostic',
      date: DateTime.now().subtract(const Duration(days: 5)),
      rawText: '''
THYROID FUNCTION TEST
Total T3: 1.1 ng/mL (Normal: 0.8 - 2.0)
Total T4: 7.2 uCg/dL (Normal: 5.1 - 14.1)
TSH: 7.8 uIU/mL (Normal Range: 0.45 - 4.50) -> ELEVATED HIGH
Conclusion: Mild primary hypothyroidism pattern detected.
''',
    );

    final sample3 = TestReport(
      id: 'rep_003',
      title: 'Cardiac Markers & SPO2 Emergency Screen',
      patientName: 'Patient (Self)',
      reportType: 'Emergency ECG & Troponin',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      rawText: '''
EMERGENCY TRIAGE REPORT
Pulse Oximetry SPO2: 84% (Normal: 95% - 100%) -> CRITICAL LOW OXYGEN
Cardiac Troponin I: 2.8 ng/mL (Normal: < 0.04) -> CRITICAL HIGH
ECG Trace: ST elevation in anterior leads.
Severe respiratory distress reported.
''',
    );

    final sample4 = TestReport(
      id: 'rep_004',
      title: 'Skin Biopsy & Allergy Panel',
      patientName: 'Patient (Self)',
      reportType: 'Dermatology Lab Test',
      date: DateTime.now().subtract(const Duration(days: 10)),
      rawText: '''
DERMATOLOGY BIOPSY & ALLERGY PANEL
Biopsy Site: Forearm skin lesion
Histopathology: Hyperkeratosis with perivascular lymphocytic infiltrate (Dermatitis).
IgE Antibodies: 380 IU/mL -> ELEVATED (Allergic reaction)
Conclusion: Contact allergic dermatitis.
''',
    );

    final sample5 = TestReport(
      id: 'rep_005',
      title: 'Routine Annual Wellness Checkup',
      patientName: 'Patient (Self)',
      reportType: 'General Health Panel',
      date: DateTime.now().subtract(const Duration(days: 15)),
      rawText: '''
ANNUAL WELLNESS PANEL
Blood Pressure: 118/76 mmHg -> NORMAL
Fasting Blood Sugar: 88 mg/dL -> NORMAL
Lipid Profile: Cholesterol 172 mg/dL, HDL 54 mg/dL, LDL 98 mg/dL -> NORMAL
Kidney & Liver Function: All enzymes within healthy parameters.
Conclusion: Overall healthy profile. No pathology detected.
''',
    );

    // Auto-analyze initial samples
    final List<TestReport> initialReports = [
      sample1.copyWith(analysis: analyzer.analyzeReport(sample1.title, sample1.rawText)),
      sample2.copyWith(analysis: analyzer.analyzeReport(sample2.title, sample2.rawText)),
      sample3.copyWith(analysis: analyzer.analyzeReport(sample3.title, sample3.rawText)),
      sample4.copyWith(analysis: analyzer.analyzeReport(sample4.title, sample4.rawText)),
      sample5.copyWith(analysis: analyzer.analyzeReport(sample5.title, sample5.rawText)),
    ];

    return initialReports;
  }

  Future<TestReport> addReport(
    String title,
    String reportType,
    String rawText, {
    String? base64Image,
  }) async {
    final openRouterService = ref.read(openRouterServiceProvider);
    final apiKey = ref.read(openRouterApiKeyProvider);

    final newReport = TestReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      patientName: 'Patient (Self)',
      reportType: reportType,
      date: DateTime.now(),
      rawText: rawText,
    );

    final analysis = await openRouterService.analyzeDigitalReport(
      reportTitle: title,
      rawText: rawText,
      base64Image: base64Image,
      apiKey: apiKey,
    );

    final analyzedReport = newReport.copyWith(analysis: analysis);
    state = [analyzedReport, ...state];
    return analyzedReport;
  }

  void deleteReport(String id) {
    state = state.where((r) => r.id != id).toList();
  }
}

final patientReportsProvider =
    NotifierProvider<PatientReportsNotifier, List<TestReport>>(
        PatientReportsNotifier.new);

class SelectedReportIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

final selectedReportIdProvider =
    NotifierProvider<SelectedReportIdNotifier, String?>(
        SelectedReportIdNotifier.new);
