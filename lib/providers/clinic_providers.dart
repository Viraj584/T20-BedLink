import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clinic.dart';
import '../services/clinic_ranking_service.dart';
import 'hospital_providers.dart';
import 'location_providers.dart';

final clinicRankingServiceProvider = Provider<ClinicRankingService>((ref) {
  final routingService = ref.watch(routingServiceProvider);
  return ClinicRankingService(routingService: routingService);
});

final clinicsStreamProvider = StreamProvider<List<Clinic>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamClinics();
});

class ClinicFilterDraft {
  final List<String> selectedSpecialties;
  final String filterType; // 'all' | 'clinic' | 'pathology_lab'
  final String note;

  const ClinicFilterDraft({
    required this.selectedSpecialties,
    required this.filterType,
    required this.note,
  });

  ClinicFilterDraft copyWith({
    List<String>? selectedSpecialties,
    String? filterType,
    String? note,
  }) {
    return ClinicFilterDraft(
      selectedSpecialties: selectedSpecialties ?? this.selectedSpecialties,
      filterType: filterType ?? this.filterType,
      note: note ?? this.note,
    );
  }
}

class ClinicFilterDraftNotifier extends Notifier<ClinicFilterDraft> {
  @override
  ClinicFilterDraft build() {
    return const ClinicFilterDraft(
      selectedSpecialties: ['Dermatology (Skin)'],
      filterType: 'all',
      note: '',
    );
  }

  void setFilterType(String type) {
    state = state.copyWith(filterType: type);
  }

  void toggleSpecialty(String specialty) {
    final current = List<String>.from(state.selectedSpecialties);
    if (current.contains(specialty)) {
      if (current.length > 1) current.remove(specialty);
    } else {
      current.add(specialty);
    }
    state = state.copyWith(selectedSpecialties: current);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }
}

final clinicFilterDraftProvider =
    NotifierProvider<ClinicFilterDraftNotifier, ClinicFilterDraft>(
        ClinicFilterDraftNotifier.new);
