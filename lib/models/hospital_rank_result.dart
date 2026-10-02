import 'hospital.dart';

class HospitalRankResult {
  final Hospital hospital;
  final int rank;
  final double totalScore;
  final int travelMinutes;
  final double distanceKm;
  final bool isPartialMatch;
  final Map<String, int> bedAvailableMap;
  final Map<String, double> scoreBreakdown;

  const HospitalRankResult({
    required this.hospital,
    required this.rank,
    required this.totalScore,
    required this.travelMinutes,
    required this.distanceKm,
    required this.isPartialMatch,
    required this.bedAvailableMap,
    required this.scoreBreakdown,
  });

  HospitalRankResult copyWithRank(int newRank) {
    return HospitalRankResult(
      hospital: hospital,
      rank: newRank,
      totalScore: totalScore,
      travelMinutes: travelMinutes,
      distanceKm: distanceKm,
      isPartialMatch: isPartialMatch,
      bedAvailableMap: bedAvailableMap,
      scoreBreakdown: scoreBreakdown,
    );
  }
}
