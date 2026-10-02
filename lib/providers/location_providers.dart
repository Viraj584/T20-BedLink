import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';
import '../services/ranking_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService();
});

final rankingServiceProvider = Provider<RankingService>((ref) {
  final routingService = ref.watch(routingServiceProvider);
  return RankingService(routingService: routingService);
});

class LocationNotifier extends Notifier<LocationResult> {
  @override
  LocationResult build() {
    return const LocationResult(
      latitude: AppConstants.defaultLat,
      longitude: AppConstants.defaultLng,
      isGps: false,
    );
  }

  void updateLocation(double lat, double lng, {bool isGps = false}) {
    state = LocationResult(latitude: lat, longitude: lng, isGps: isGps);
  }
}

final currentLocationProvider =
    NotifierProvider<LocationNotifier, LocationResult>(LocationNotifier.new);

class RequestDraft {
  final List<String> needs;
  final String severity;
  final String note;

  const RequestDraft({
    required this.needs,
    required this.severity,
    required this.note,
  });

  RequestDraft copyWith({
    List<String>? needs,
    String? severity,
    String? note,
  }) {
    return RequestDraft(
      needs: needs ?? this.needs,
      severity: severity ?? this.severity,
      note: note ?? this.note,
    );
  }
}

class RequestDraftNotifier extends Notifier<RequestDraft> {
  @override
  RequestDraft build() {
    return const RequestDraft(
      needs: ['ICU'],
      severity: 'serious',
      note: '',
    );
  }

  void setNeeds(List<String> needs) {
    state = state.copyWith(needs: needs);
  }

  void toggleNeed(String need) {
    final current = List<String>.from(state.needs);
    if (current.contains(need)) {
      if (current.length > 1) current.remove(need);
    } else {
      current.add(need);
    }
    state = state.copyWith(needs: current);
  }

  void setSeverity(String severity) {
    state = state.copyWith(severity: severity);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }
}

final requestDraftProvider =
    NotifierProvider<RequestDraftNotifier, RequestDraft>(
        RequestDraftNotifier.new);
