import 'dart:math';
import '../constants.dart';

/// Calculates the Haversine straight-line distance in kilometers between two GPS coordinates.
double calculateHaversineDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadiusKm = 6371.0;

  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

/// Estimates driving travel time in minutes based on straight-line distance times a city speed factor.
int estimateDrivingTimeMinutes(
  double distanceKm, {
  double citySpeedKmH = AppConstants.cityAverageSpeedKmH,
}) {
  // Apply a 1.4x road curvature & traffic factor over straight line distance
  final double estimatedRoadKm = distanceKm * 1.4;
  final double travelHours = estimatedRoadKm / citySpeedKmH;
  final int minutes = (travelHours * 60).round();
  return max(1, minutes); // Minimum 1 minute
}

double _toRadians(double degree) {
  return degree * pi / 180.0;
}
