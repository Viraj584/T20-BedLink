import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final bool isGps;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.isGps,
  });
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled, using default Mumbai coords.');
        return const LocationResult(
          latitude: AppConstants.defaultLat,
          longitude: AppConstants.defaultLng,
          isGps: false,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied, using default Mumbai coords.');
          return const LocationResult(
            latitude: AppConstants.defaultLat,
            longitude: AppConstants.defaultLng,
            isGps: false,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied.');
        return const LocationResult(
          latitude: AppConstants.defaultLat,
          longitude: AppConstants.defaultLng,
          isGps: false,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isGps: true,
      );
    } catch (e) {
      debugPrint('Error getting GPS location ($e), falling back to default.');
      return const LocationResult(
        latitude: AppConstants.defaultLat,
        longitude: AppConstants.defaultLng,
        isGps: false,
      );
    }
  }
}
