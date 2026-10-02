import 'package:cloud_firestore/cloud_firestore.dart';
import 'attempt.dart';

class EmergencyRequest {
  final String id;
  final double patientLat;
  final double patientLng;
  final List<String> needs;
  final String severity; // 'critical' | 'serious' | 'stable'
  final String? note;
  final String status; // 'searching' | 'offered' | 'accepted' | 'cancelled' | 'failed' | 'arrived'
  final List<String> rankedHospitalIds;
  final int currentIndex;
  final String currentHospitalId;
  final DateTime? offerExpiresAt;
  final DateTime? createdAt;
  final List<Attempt> attempts;
  final String? rejectReason;

  const EmergencyRequest({
    required this.id,
    required this.patientLat,
    required this.patientLng,
    required this.needs,
    required this.severity,
    this.note,
    required this.status,
    required this.rankedHospitalIds,
    required this.currentIndex,
    required this.currentHospitalId,
    this.offerExpiresAt,
    this.createdAt,
    required this.attempts,
    this.rejectReason,
  });

  factory EmergencyRequest.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawAttempts = json['attempts'] as List<dynamic>? ?? [];
    final parsedAttempts = rawAttempts
        .map((a) => Attempt.fromJson(Map<String, dynamic>.from(a)))
        .toList();

    return EmergencyRequest(
      id: id,
      patientLat: (json['patientLat'] as num?)?.toDouble() ?? 0.0,
      patientLng: (json['patientLng'] as num?)?.toDouble() ?? 0.0,
      needs: List<String>.from(json['needs'] as List<dynamic>? ?? []),
      severity: json['severity'] as String? ?? 'serious',
      note: json['note'] as String?,
      status: json['status'] as String? ?? 'searching',
      rankedHospitalIds:
          List<String>.from(json['rankedHospitalIds'] as List<dynamic>? ?? []),
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      currentHospitalId: json['currentHospitalId'] as String? ?? '',
      offerExpiresAt: parseDate(json['offerExpiresAt']),
      createdAt: parseDate(json['createdAt']),
      attempts: parsedAttempts,
      rejectReason: json['rejectReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'patientLat': patientLat,
        'patientLng': patientLng,
        'needs': needs,
        'severity': severity,
        'note': note,
        'status': status,
        'rankedHospitalIds': rankedHospitalIds,
        'currentIndex': currentIndex,
        'currentHospitalId': currentHospitalId,
        'offerExpiresAt': offerExpiresAt != null
            ? Timestamp.fromDate(offerExpiresAt!)
            : null,
        'createdAt':
            createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
        'attempts': attempts.map((a) => a.toJson()).toList(),
        'rejectReason': rejectReason,
      };

  EmergencyRequest copyWith({
    String? id,
    double? patientLat,
    double? patientLng,
    List<String>? needs,
    String? severity,
    String? note,
    String? status,
    List<String>? rankedHospitalIds,
    int? currentIndex,
    String? currentHospitalId,
    DateTime? offerExpiresAt,
    DateTime? createdAt,
    List<Attempt>? attempts,
    String? rejectReason,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      patientLat: patientLat ?? this.patientLat,
      patientLng: patientLng ?? this.patientLng,
      needs: needs ?? this.needs,
      severity: severity ?? this.severity,
      note: note ?? this.note,
      status: status ?? this.status,
      rankedHospitalIds: rankedHospitalIds ?? this.rankedHospitalIds,
      currentIndex: currentIndex ?? this.currentIndex,
      currentHospitalId: currentHospitalId ?? this.currentHospitalId,
      offerExpiresAt: offerExpiresAt ?? this.offerExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }
}
