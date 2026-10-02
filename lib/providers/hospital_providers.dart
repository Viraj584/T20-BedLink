import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hospital.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final hospitalsStreamProvider = StreamProvider<List<Hospital>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamHospitals();
});

class SelectedHospitalIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedHospitalIdProvider =
    NotifierProvider<SelectedHospitalIdNotifier, String?>(
        SelectedHospitalIdNotifier.new);

final selectedHospitalProvider = Provider<Hospital?>((ref) {
  final selectedId = ref.watch(selectedHospitalIdProvider);
  final hospitalsAsync = ref.watch(hospitalsStreamProvider);

  if (selectedId == null) return null;
  return hospitalsAsync.when(
    data: (hospitals) {
      try {
        return hospitals.firstWhere((h) => h.id == selectedId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (err, stackTrace) => null,
  );
});
