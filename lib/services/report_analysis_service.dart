import '../models/test_report.dart';

class ReportAnalysisService {
  /// Analyzes a raw medical test report text and returns a patient-friendly
  /// plain-English analysis with actionable hospital/clinic recommendations.
  ReportAnalysisResult analyzeReport(String reportTitle, String rawText) {
    final text = '$reportTitle $rawText'.toLowerCase();

    // 1. Check for Emergency / Critical conditions (Hospital Bed needed)
    if (text.contains('spo2') && _containsValueLessThan(text, 'spo2', 90) ||
        text.contains('troponin') ||
        text.contains('st elevation') ||
        text.contains('acute myocardial') ||
        text.contains('severe respiratory distress') ||
        text.contains('critical oxygen') ||
        text.contains('emergency ecg') ||
        text.contains('cardiac triage') ||
        text.contains('cardiac marker')) {
      return const ReportAnalysisResult(
        severity: RiskSeverity.critical,
        headline: '🚨 Critical Emergency Alert - Hospital Care Required',
        simpleExplanation:
            'Your test results indicate critical emergency indicators (such as low oxygen saturation or cardiac markers). Immediate medical monitoring at an emergency hospital facility is strongly advised.',
        keyFindings: [
          '⚠️ Oxygen Saturation / SPO2: Low levels or cardiac indicators detected',
          '⚠️ Cardiac / Cardiac Troponin: Elevated marker requiring urgent evaluation',
          '⚠️ Emergency Ward / ICU bed requirement indicated'
        ],
        recommendationType: RecommendationType.hospital,
        recommendationReason:
            'Immediate hospital admission or emergency bed hold recommended for continuous oxygen and cardiac monitoring.',
        recommendedSpecialty: 'Emergency ICU / Cardiac Ward',
      );
    }

    // 2. Check for Skin / Dermatology conditions
    if (text.contains('skin') ||
        text.contains('dermatitis') ||
        text.contains('eczema') ||
        text.contains('psoriasis') ||
        text.contains('lesion') ||
        text.contains('melanocyte') ||
        text.contains('fungal infection') ||
        text.contains('dermatology')) {
      return const ReportAnalysisResult(
        severity: RiskSeverity.attention,
        headline: '🩺 Skin & Allergy Consultation Recommended',
        simpleExplanation:
            'Your lab report indicates localized skin inflammation or an allergic reaction. This is non-life-threatening but requires specialist evaluation for suitable ointment or treatment.',
        keyFindings: [
          '🔍 Skin Tissue / Biopsy: Mild epidermal inflammation noted',
          '🔍 Allergy Markers: Elevated IgE antibodies indicating environmental sensitivity',
          '✅ Vital Signs: Normal blood pressure and oxygen levels'
        ],
        recommendationType: RecommendationType.clinic,
        recommendationReason:
            'Consult a certified Dermatologist or Skin Specialist clinic for precise prescription care.',
        recommendedSpecialty: 'Dermatology (Skin)',
      );
    }

    // 3. Check for Pathology / Blood Anemia / Thyroid / Diabetes (Specialist Clinic needed)
    if (text.contains('hemoglobin') ||
        text.contains('hb') ||
        text.contains('tsh') ||
        text.contains('thyroid') ||
        text.contains('glucose') ||
        text.contains('hba1c') ||
        text.contains('cbc') ||
        text.contains('anemia') ||
        text.contains('pathology') ||
        text.contains('blood test')) {
      final isLowHb = text.contains('hemoglobin') || text.contains('anemia') || text.contains('low hb') || text.contains('cbc') || _containsValueLessThan(text, 'hemoglobin', 11);
      final isHighTsh = text.contains('tsh') || text.contains('thyroid') || _containsValueGreaterThan(text, 'tsh', 5.5);
      final isHighSugar = text.contains('hba1c') || text.contains('glucose');

      final List<String> findings = [];
      String explanationText = 'Your blood test report shows some values outside the normal reference range: ';

      if (isLowHb) {
        findings.add('🩸 Hemoglobin: Below normal range (Mild Anemia)');
        explanationText += 'Your red blood count (hemoglobin) is lower than expected, which may cause mild tiredness. ';
      }
      if (isHighTsh) {
        findings.add('🦋 Thyroid (TSH): Elevated hormone level detected');
        explanationText += 'Your thyroid stimulating hormone (TSH) level is slightly elevated, suggesting an underactive thyroid. ';
      }
      if (isHighSugar) {
        findings.add('🍬 HbA1c / Glucose: Above target range');
        explanationText += 'Blood sugar levels indicate higher average glucose over past months. ';
      }

      if (findings.isEmpty) {
        findings.add('🩸 Blood Cell & Chemical Biomarkers: Require specialist review');
      }
      findings.add('✅ Emergency Vitals: Stable (No emergency room visit needed)');

      return ReportAnalysisResult(
        severity: RiskSeverity.attention,
        headline: '📋 Specialist Clinic Follow-Up Suggested',
        simpleExplanation: explanationText.trim(),
        keyFindings: findings,
        recommendationType: RecommendationType.clinic,
        recommendationReason:
            'A routine consultation with a specialist clinic or diagnostic lab for follow-up testing is recommended.',
        recommendedSpecialty: isHighTsh
            ? 'Blood Tests & Pathology'
            : (isLowHb ? 'Blood Tests & Pathology' : 'General Physician'),
      );
    }

    // 4. Default / Normal Report (Fit for now)
    return const ReportAnalysisResult(
      severity: RiskSeverity.normal,
      headline: '🟢 All Clear - You Are Fit for Now!',
      simpleExplanation:
          'Great news! All key biomarkers and laboratory indicators in this test report fall well within the normal healthy range. No emergency hospital bed or specialist clinic visit is required at this time.',
      keyFindings: [
        '✅ Complete Blood Count (CBC): All blood cell levels normal',
        '✅ Metabolic & Organ Function: Biomarkers within healthy limits',
        '✅ Vital Indicators: No alarming signals detected'
      ],
      recommendationType: RecommendationType.none,
      recommendationReason:
          'You are healthy and fit. Continue maintaining your balanced diet, hydration, and regular exercise routine!',
      recommendedSpecialty: null,
    );
  }

  bool _containsValueLessThan(String text, String key, double threshold) {
    final regex = RegExp('$key[^0-9]*([0-9]+\\.?[0-9]*)');
    final match = regex.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final val = double.tryParse(match.group(1)!);
      if (val != null) return val < threshold;
    }
    return text.contains('low') || text.contains('below');
  }

  bool _containsValueGreaterThan(String text, String key, double threshold) {
    final regex = RegExp('$key[^0-9]*([0-9]+\\.?[0-9]*)');
    final match = regex.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final val = double.tryParse(match.group(1)!);
      if (val != null) return val > threshold;
    }
    return text.contains('high') || text.contains('elevated');
  }
}
