import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../models/test_report.dart';
import '../../providers/report_providers.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  bool _isAnalyzing = false;
  String? _selectedFilePresetName;



  void _showAddReportModal() {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    String selectedPresetType = 'Blood Tests & Pathology';
    String? pickedFileName;
    String? base64ImageStr;
    _selectedFilePresetName = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics_rounded,
                            color: AppColors.primary, size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Upload Digital Report for AI Analysis',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Digital File / Photo Upload Selector Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.cloud_upload_rounded,
                                  color: AppColors.primary, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Select Digital Report File / Scan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pick any PDF document or image report directly from your device storage, camera, or choose a sample scan below:',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),

                          // Device Image & Camera Scan Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final picker = ImagePicker();
                                      final image = await picker.pickImage(
                                          source: ImageSource.gallery);
                                      if (image != null) {
                                        final bytes = await image.readAsBytes();
                                        setModalState(() {
                                          pickedFileName = image.name;
                                          _selectedFilePresetName = 'custom_img';
                                          titleController.text = image.name;
                                          base64ImageStr = base64Encode(bytes);
                                          textController.text =
                                              'Digital report image scan picked from gallery: ${image.name}';
                                        });
                                      }
                                    } catch (e) {
                                      debugPrint('ImagePicker gallery error: $e');
                                    }
                                  },
                                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                                  label: const Text('Device Gallery Scan',
                                      style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final picker = ImagePicker();
                                      final image = await picker.pickImage(
                                          source: ImageSource.camera);
                                      if (image != null) {
                                        final bytes = await image.readAsBytes();
                                        setModalState(() {
                                          pickedFileName = image.name;
                                          _selectedFilePresetName = 'camera_img';
                                          titleController.text =
                                              'Camera Photo Scan ${DateFormat('HH:mm').format(DateTime.now())}';
                                          base64ImageStr = base64Encode(bytes);
                                          textController.text =
                                              'Photo scan captured with camera: ${image.name}';
                                        });
                                      }
                                    } catch (e) {
                                      debugPrint('ImagePicker camera error: $e');
                                    }
                                  },
                                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                                  label: const Text('Take Camera Photo',
                                      style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (pickedFileName != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.successTint,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.success),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.success, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Selected: $pickedFileName',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Text(
                            'Or try sample digital lab report scans:',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('📄 CBC Blood Scan.pdf'),
                                selected: _selectedFilePresetName == 'cbc',
                                onSelected: (sel) {
                                  setModalState(() {
                                    _selectedFilePresetName = 'cbc';
                                    pickedFileName = 'CBC Blood Scan.pdf';
                                    selectedPresetType = 'Blood Tests & Pathology';
                                    titleController.text =
                                        'Digital CBC & Iron Saturation Report';
                                    textController.text =
                                        'Hemoglobin: 9.6 g/dL (LOW)\nWBC: 6,400 /uL\nPlatelets: 230,000 /uL\nFerritin: 11 ng/mL (LOW)\nDiagnosis: Iron deficiency anemia.';
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('📄 Thyroid Profile.pdf'),
                                selected: _selectedFilePresetName == 'thyroid',
                                onSelected: (sel) {
                                  setModalState(() {
                                    _selectedFilePresetName = 'thyroid';
                                    pickedFileName = 'Thyroid Profile.pdf';
                                    selectedPresetType = 'Endocrine Diagnostic';
                                    titleController.text =
                                        'Digital Thyroid TSH Panel Scan';
                                    textController.text =
                                        'TSH: 8.4 uIU/mL (HIGH ELEVATED)\nTotal T3: 1.0 ng/mL\nTotal T4: 6.8 uCg/dL\nDiagnosis: Hypothyroidism requiring thyroxine therapy.';
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('🚨 Cardiac Troponin.pdf'),
                                selected: _selectedFilePresetName == 'cardiac',
                                onSelected: (sel) {
                                  setModalState(() {
                                    _selectedFilePresetName = 'cardiac';
                                    pickedFileName = 'Cardiac Troponin.pdf';
                                    selectedPresetType =
                                        'Emergency ECG & Troponin';
                                    titleController.text =
                                        'Emergency Cardiac Triage Scan';
                                    textController.text =
                                        'SPO2: 86% (CRITICAL LOW OXYGEN)\nTroponin I: 3.1 ng/mL (HIGH)\nECG: ST elevation in V2-V4.\nAcute ischemic alert.';
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('📄 Skin Biopsy.pdf'),
                                selected: _selectedFilePresetName == 'skin',
                                onSelected: (sel) {
                                  setModalState(() {
                                    _selectedFilePresetName = 'skin';
                                    pickedFileName = 'Skin Biopsy.pdf';
                                    selectedPresetType = 'Dermatology Lab Test';
                                    titleController.text =
                                        'Dermatology Skin Biopsy Report';
                                    textController.text =
                                        'Biopsy: Epidermal spongiosis with eczema\nIgE Antibody: 410 IU/mL (HIGH)\nDiagnosis: Allergic contact dermatitis.';
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Report Category',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPresetType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Blood Tests & Pathology',
                            child: Text('Blood Tests & Pathology')),
                        DropdownMenuItem(
                            value: 'Endocrine Diagnostic',
                            child: Text('Thyroid / Hormone Profile')),
                        DropdownMenuItem(
                            value: 'Emergency ECG & Troponin',
                            child: Text('Emergency ECG & Cardiac Marker')),
                        DropdownMenuItem(
                            value: 'Dermatology Lab Test',
                            child: Text('Dermatology & Skin Biopsy')),
                        DropdownMenuItem(
                            value: 'General Health Panel',
                            child: Text('General Health Checkup')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedPresetType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Report Title / Document Name',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Digital CBC Report or Skin Biopsy',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Report Summary / Scanned Text',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Digital text extracted from report or paste key lab findings (e.g. Hemoglobin 9.5 g/dL, SPO2 88%, TSH 7.2)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () async {
                              final title = titleController.text.trim().isEmpty
                                  ? selectedPresetType
                                  : titleController.text.trim();
                              final raw = textController.text.trim().isEmpty
                                  ? 'Report type: $selectedPresetType'
                                  : textController.text.trim();

                              setState(() => _isAnalyzing = true);
                              Navigator.pop(ctx);

                              try {
                                await ref
                                    .read(patientReportsProvider.notifier)
                                    .addReport(title, selectedPresetType, raw,
                                        base64Image: base64ImageStr);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Digital report analyzed by OpenRouter AI!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Analysis error: $e'),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isAnalyzing = false);
                              }
                            },
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(_isAnalyzing
                          ? 'AI Analyzing Report...'
                          : 'Analyze Digital Report with AI'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getSeverityColor(RiskSeverity? severity) {
    switch (severity) {
      case RiskSeverity.critical:
        return AppColors.danger;
      case RiskSeverity.attention:
        return AppColors.warning;
      case RiskSeverity.normal:
      default:
        return AppColors.success;
    }
  }

  String _getSeverityLabel(RiskSeverity? severity) {
    switch (severity) {
      case RiskSeverity.critical:
        return '🚨 Critical Emergency';
      case RiskSeverity.attention:
        return '🟡 Requires Clinic';
      case RiskSeverity.normal:
      default:
        return '🟢 Fit / Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(patientReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medical Test Reports & AI Analysis'),
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/patient/hub'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                color: AppColors.primaryTint,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'AI Medical Report Analyzer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'AI Powered',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Upload digital PDF/images for instant plain-English analysis and smart healthcare recommendations.',
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
              ),
              const SizedBox(height: 16),

              // Upload New Digital Report Button
              ElevatedButton.icon(
                onPressed: _showAddReportModal,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('Upload Digital Test Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Report History (${reports.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Tap to view AI analysis',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: reports.isEmpty
                    ? const Center(child: Text('No test reports uploaded yet.'))
                    : ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final item = reports[index];
                          final color = _getSeverityColor(item.analysis?.severity);
                          final label = _getSeverityLabel(item.analysis?.severity);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: color.withValues(alpha: 0.4), width: 1.5),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                ref
                                    .read(selectedReportIdProvider.notifier)
                                    .select(item.id);
                                context.push('/patient/reports/analysis');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(color: color),
                                          ),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(item.date),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Category: ${item.reportType}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (item.analysis != null) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.analysis!.headline,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
