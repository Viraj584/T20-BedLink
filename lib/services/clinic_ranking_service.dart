import '../models/clinic.dart';
import 'routing_service.dart';

class ClinicRankingService {
  final RoutingService _routingService;

  ClinicRankingService({RoutingService? routingService})
      : _routingService = routingService ?? RoutingService();

  Future<List<ClinicRankResult>> rankClinics({
    required List<Clinic> clinics,
    required double patientLat,
    required double patientLng,
    required List<String> selectedSpecialties,
    required String filterType, // 'all' | 'clinic' | 'pathology_lab'
  }) async {
    final List<ClinicRankResult> results = [];

    // Filter by type if specified
    final eligible = clinics.where((c) {
      if (filterType == 'all') return true;
      if (filterType == 'clinic') return c.type == 'clinic';
      if (filterType == 'pathology_lab') return c.type == 'pathology_lab' || c.type == 'diagnostic_center';
      return true;
    }).toList();

    for (final clinic in eligible) {
      final eta = await _routingService.getDrivingEta(
        startLat: patientLat,
        startLng: patientLng,
        endLat: clinic.lat,
        endLng: clinic.lng,
      );

      final distanceKm = eta.distanceKm;
      final travelMins = eta.travelMinutes;

      // Calculate matched specialties using tokenized matching
      int matchedCount = 0;
      if (selectedSpecialties.isNotEmpty) {
        for (final s in selectedSpecialties) {
          final tokens = s
              .toLowerCase()
              .replaceAll(RegExp(r'[^\w\s]'), ' ')
              .split(RegExp(r'\s+'))
              .where((t) => t.length > 2)
              .toList();

          bool hasMatch = false;
          for (final token in tokens) {
            final inSpecs = clinic.specialties
                .any((spec) => spec.toLowerCase().contains(token));
            final inTests = clinic.testsAvailable
                .any((test) => test.toLowerCase().contains(token));
            if (inSpecs || inTests) {
              hasMatch = true;
              break;
            }
          }
          if (hasMatch) {
            matchedCount++;
          }
        }
      }

      // Scoring: Lower score is better
      // Travel score: 1.5 pts per minute
      double score = travelMins * 1.5;

      // Match bonus/penalty
      if (selectedSpecialties.isNotEmpty && matchedCount == 0) {
        score += 25.0; // Penalty if no match
      } else if (matchedCount > 0) {
        score -= (matchedCount * 15.0); // Reward matching specialties
      }

      // Rating bonus: up to -5 pts for 5-star rating
      score -= (clinic.rating * 1.0);

      // Open status bonus: -10 pts if open
      if (!clinic.isOpen) {
        score += 30.0;
      }

      results.add(ClinicRankResult(
        clinic: clinic,
        distanceKm: distanceKm,
        travelMinutes: travelMins,
        totalScore: score,
        matchedSpecialtiesCount: matchedCount,
        rank: 0,
      ));
    }

    // Sort by totalScore ascending (best match first)
    results.sort((a, b) => a.totalScore.compareTo(b.totalScore));

    // Assign 1-based ranks
    final List<ClinicRankResult> ranked = [];
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      ranked.add(ClinicRankResult(
        clinic: r.clinic,
        distanceKm: r.distanceKm,
        travelMinutes: r.travelMinutes,
        totalScore: r.totalScore,
        matchedSpecialtiesCount: r.matchedSpecialtiesCount,
        rank: i + 1,
      ));
    }

    return ranked;
  }
}
