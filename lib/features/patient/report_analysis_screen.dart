import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/test_report.dart';
import '../../providers/report_providers.dart';
import '../../providers/request_providers.dart';
import '../../providers/clinic_providers.dart';

class ReportAnalysisScreen extends ConsumerWidget {
  const ReportAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedReportIdProvider);
    final reports = ref.watch(patientReportsProvider);

    final report = reports.firstWhere(
      (r) => r.id == selectedId,
      orElse: () => reports.first,
    );

    final analysis = report.analysis;

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Report Analysis')),
        body: const Center(child: Text('No analysis available for this report.')),
      );
    }

    final isCritical = analysis.severity == RiskSeverity.critical;
    final isAttention = analysis.severity == RiskSeverity.attention;

    final themeColor = isCritical
        ? AppColors.danger
        : (isAttention ? AppColors.warning : AppColors.success);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Report Analysis'),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analysis summary copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prominent Medical Safety Disclaimer Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.shield_outlined, color: AppColors.info, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'MEDICAL DISCLAIMER: This AI analysis provides plain-English informational summary only and is NOT a certified medical diagnosis. Always consult a licensed doctor or practitioner.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title & Date Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${report.reportType} • ${DateFormat('MMMM dd, yyyy').format(report.date)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Risk Severity Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeColor, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCritical
                          ? Icons.warning_rounded
                          : (isAttention
                              ? Icons.info_rounded
                              : Icons.check_circle_rounded),
                      color: themeColor,
                      size: 36,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.headline,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCritical
                                ? 'Urgent Hospital Attention Suggested'
                                : (isAttention
                                    ? 'Outpatient Specialist Consultation Advised'
                                    : 'No Medical Action Required'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Patient Friendly Explanation Section
              Text(
                'Patient-Friendly Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    analysis.simpleExplanation,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Key Biomarker Breakdown Section
              Text(
                'Key Findings & Biomarkers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: analysis.keyFindings.map((finding) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                finding,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Smart Recommendation & Next Steps Section
              Text(
                'AI Recommended Next Action',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),

              if (analysis.recommendationType == RecommendationType.hospital) ...[
                // Emergency Hospital Recommendation Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerTint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.danger, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        analysis.recommendationReason,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(isPatientModeProvider.notifier)
                              .setPatientMode(true);
                          context.push('/dispatch/new');
                        },
                        icon: const Icon(Icons.local_hospital_rounded),
                        label: const Text('Search Emergency Hospital Beds'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (analysis.recommendationType == RecommendationType.clinic) ...[
                // Specialist Clinic / Lab Recommendation Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.infoTint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.info, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        analysis.recommendationReason,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (analysis.recommendedSpecialty != null) {
                            ref
                                .read(clinicFilterDraftProvider.notifier)
                                .toggleSpecialty(analysis.recommendedSpecialty!);
                          }
                          context.push('/patient/clinics/search');
                        },
                        icon: const Icon(Icons.science_rounded),
                        label: Text(
                            'Find Nearby ${analysis.recommendedSpecialty ?? "Clinics"}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Fit For Now Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successTint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sentiment_very_satisfied_rounded,
                          color: AppColors.success, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'You Are Fit For Now!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'No emergency hospital bed or clinic visit is required. Keep maintaining healthy habits!',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
