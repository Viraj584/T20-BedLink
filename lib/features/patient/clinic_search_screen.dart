import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../providers/location_providers.dart';
import '../../providers/clinic_providers.dart';

class ClinicSearchScreen extends ConsumerStatefulWidget {
  const ClinicSearchScreen({super.key});

  @override
  ConsumerState<ClinicSearchScreen> createState() => _ClinicSearchScreenState();
}

class _ClinicSearchScreenState extends ConsumerState<ClinicSearchScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isLocating = false;

  static const List<String> availableSpecialties = [
    'Dermatology (Skin)',
    'Blood Tests & Pathology',
    'Gynecology & Maternity',
    'Dental Care',
    'Pediatrics (Child)',
    'Orthopedics (Bone)',
    'Ophthalmology (Eye)',
    'X-Ray & Imaging',
    'MRI/CT Scan',
    'Ultrasound',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _detectGps());
  }

  Future<void> _detectGps() async {
    if (!mounted) return;
    setState(() => _isLocating = true);
    final locationService = ref.read(locationServiceProvider);
    final result = await locationService.getCurrentLocation();
    if (!mounted) return;
    ref.read(currentLocationProvider.notifier).updateLocation(
          result.latitude,
          result.longitude,
          isGps: result.isGps,
        );
    if (mounted) setState(() => _isLocating = false);
  }

  void _showMapPinDialog() {
    final currentLocation = ref.read(currentLocationProvider);
    LatLng selectedPin =
        LatLng(currentLocation.latitude, currentLocation.longitude);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set Location Pin'),
              content: SizedBox(
                width: 320,
                height: 350,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedPin,
                      initialZoom: 13.0,
                      onTap: (_, point) {
                        setDialogState(() {
                          selectedPin = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.bedlink.bedlink',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedPin,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.danger,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(currentLocationProvider.notifier).updateLocation(
                          selectedPin.latitude,
                          selectedPin.longitude,
                          isGps: false,
                        );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Confirm Location'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(currentLocationProvider);
    final draft = ref.watch(clinicFilterDraftProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Clinics & Pathology Labs'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info),
              ),
              child: Row(
                children: const [
                  Icon(Icons.science_rounded, color: AppColors.info, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Find specialist doctors & diagnostic pathology labs near you.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location Header Card with Map Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Preview Bar
                    GestureDetector(
                      onTap: _showMapPinDialog,
                      child: Container(
                        height: 140,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              FlutterMap(
                                key: ValueKey(
                                    '${location.latitude}_${location.longitude}'),
                                options: MapOptions(
                                  initialCenter: LatLng(
                                      location.latitude, location.longitude),
                                  initialZoom: 14.0,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.bedlink.bedlink',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(location.latitude,
                                            location.longitude),
                                        width: 36,
                                        height: 36,
                                        child: const Icon(
                                          Icons.location_on_rounded,
                                          color: AppColors.danger,
                                          size: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.touch_app_rounded,
                                          color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tap to adjust pin',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_isLocating)
                                Container(
                                  color: Colors.black26,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          location.isGps
                              ? Icons.my_location_rounded
                              : Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          location.isGps
                              ? 'GPS Location Acquired'
                              : 'Map Pin Location',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_isLocating)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLocating ? null : _detectGps,
                            icon:
                                const Icon(Icons.gps_fixed_rounded, size: 18),
                            label: const Text('Refresh GPS'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showMapPinDialog,
                            icon: const Icon(Icons.map_rounded, size: 18),
                            label: const Text('Set Map Pin'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Facility Category Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Facility Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'all',
                          label: Text('All'),
                          icon: Icon(Icons.health_and_safety_rounded),
                        ),
                        ButtonSegment(
                          value: 'clinic',
                          label: Text('Clinics'),
                          icon: Icon(Icons.medical_services_outlined),
                        ),
                        ButtonSegment(
                          value: 'pathology_lab',
                          label: Text('Labs'),
                          icon: Icon(Icons.science_outlined),
                        ),
                      ],
                      selected: {draft.filterType},
                      onSelectionChanged: (selection) {
                        ref
                            .read(clinicFilterDraftProvider.notifier)
                            .setFilterType(selection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Specialty & Test Selection Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Specialty / Test (Multi-select)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to select all specialties or diagnostic tests needed',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSpecialties.map((specialty) {
                        final isSelected =
                            draft.selectedSpecialties.contains(specialty);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(specialty),
                          avatar: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 18,
                          ),
                          onSelected: (_) {
                            ref
                                .read(clinicFilterDraftProvider.notifier)
                                .toggleSpecialty(specialty);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Optional Consultation Note / Test Name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Specific Symptom or Test Needed (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText:
                            'e.g. Skin rash check, CBC blood test & Thyroid profile',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        ref.read(clinicFilterDraftProvider.notifier).setNote(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Button: Find & Rank Clinics
            ElevatedButton.icon(
              onPressed: () {
                context.push('/patient/clinics/results');
              },
              icon: const Icon(Icons.search_rounded, size: 28),
              label: const Text('Find & Rank Nearby Clinics & Labs'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(68),
                backgroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
