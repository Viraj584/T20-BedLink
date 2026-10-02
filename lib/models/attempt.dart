import 'package:cloud_firestore/cloud_firestore.dart';

class Attempt {
  final String hospitalId;
  final String hospitalName;
  final String result; // 'pending' | 'accepted' | 'rejected' | 'timeout'
  final String? reason;
  final DateTime? at;

  const Attempt({
    required this.hospitalId,
    required this.hospitalName,
    required this.result,
    this.reason,
    this.at,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    DateTime? timestamp;
    if (json['at'] != null) {
      if (json['at'] is Timestamp) {
        timestamp = (json['at'] as Timestamp).toDate();
      } else if (json['at'] is String) {
        timestamp = DateTime.tryParse(json['at']);
      }
    }

    return Attempt(
      hospitalId: json['hospitalId'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? 'Hospital',
      result: json['result'] as String? ?? 'pending',
      reason: json['reason'] as String?,
      at: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'result': result,
        'reason': reason,
        'at': at != null ? Timestamp.fromDate(at!) : FieldValue.serverTimestamp(),
      };
}
