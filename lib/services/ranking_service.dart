import 'dart:math';
import '../core/constants.dart';
import '../core/utils/time_ago.dart';
import '../models/hospital.dart';
import '../models/hospital_rank_result.dart';
import 'routing_service.dart';

class RankingService {
  final RoutingService _routingService;

  RankingService({RoutingService? routingService})
      : _routingService = routingService ?? RoutingService();

  Future<List<HospitalRankResult>> rankHospitals({
    required List<Hospital> hospitals,
    required double patientLat,
    required double patientLng,
    required List<String> needs,
    required String severity,
  }) async {
    final List<HospitalRankResult> unrankedResults = [];

    for (final hospital in hospitals) {
      // 1. Calculate ETA
      final routeEta = await _routingService.getDrivingEta(
        startLat: patientLat,
        startLng: patientLng,
        endLat: hospital.lat,
        endLng: hospital.lng,
      );

      final int travelMin = routeEta.travelMinutes;
      final double distKm = routeEta.distanceKm;

      // 2. Travel Score based on Severity
      double severityMultiplier = 1.0;
      if (severity == 'critical') {
        severityMultiplier = 1.5;
      } else if (severity == 'stable') {
        severityMultiplier = 0.8;
      }
      final double travelScore = travelMin * severityMultiplier;

      // 3. Staleness Penalty
      final int minutesOld = TimeAgoUtil.getMinutesAgo(hospital.lastUpdated);
      double stalenessPenalty = 0.0;
      if (minutesOld > AppConstants.freshMinutesThreshold) {
        stalenessPenalty =
            min(30.0, (minutesOld - AppConstants.freshMinutesThreshold) * 0.3);
      }

      // 4. Load Penalty
      double loadPenalty = AppConstants.loadPenaltyLow;
      if (hospital.loadLevel == 'med') {
        loadPenalty = AppConstants.loadPenaltyMed;
      } else if (hospital.loadLevel == 'high') {
        loadPenalty = AppConstants.loadPenaltyHigh;
      }

      // 5. Bed Match check
      bool isPartialMatch = false;
      final Map<String, int> bedAvailableMap = {};

      for (final need in needs) {
        final count = hospital.beds.getForType(need).available;
        bedAvailableMap[need] = count;
        if (count <= 0) {
          isPartialMatch = true;
        }
      }

      final double partialPenalty = isPartialMatch ? 50.0 : 0.0;

      final double totalScore =
          travelScore + stalenessPenalty + loadPenalty + partialPenalty;

      unrankedResults.add(
        HospitalRankResult(
          hospital: hospital,
          rank: 0,
          totalScore: totalScore,
          travelMinutes: travelMin,
          distanceKm: distKm,
          isPartialMatch: isPartialMatch,
          bedAvailableMap: bedAvailableMap,
          scoreBreakdown: {
            'travelScore': travelScore,
            'stalenessPenalty': stalenessPenalty,
            'loadPenalty': loadPenalty,
            'partialPenalty': partialPenalty,
          },
        ),
      );
    }

    // Sort ascending by totalScore (lower is better rank)
    unrankedResults.sort((a, b) => a.totalScore.compareTo(b.totalScore));

    // Assign rank 1..N
    final List<HospitalRankResult> finalRanked = [];
    for (int i = 0; i < unrankedResults.length; i++) {
      finalRanked.add(unrankedResults[i].copyWithRank(i + 1));
    }

    return finalRanked;
  }
}
