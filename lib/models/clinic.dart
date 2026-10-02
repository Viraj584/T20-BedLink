class Clinic {
  final String id;
  final String name;
  final String type; // 'clinic' | 'pathology_lab' | 'diagnostic_center'
  final double lat;
  final double lng;
  final String phone;
  final String address;
  final double rating;
  final bool isOpen;
  final String operatingHours;
  final List<String> specialties;
  final List<String> testsAvailable;

  const Clinic({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.phone,
    required this.address,
    required this.rating,
    required this.isOpen,
    required this.operatingHours,
    required this.specialties,
    required this.testsAvailable,
  });

  factory Clinic.fromJson(Map<String, dynamic> json, String docId) {
    return Clinic(
      id: docId,
      name: json['name'] as String? ?? 'Clinic & Lab',
      type: json['type'] as String? ?? 'clinic',
      lat: (json['lat'] as num?)?.toDouble() ?? 19.0760,
      lng: (json['lng'] as num?)?.toDouble() ?? 72.8777,
      phone: json['phone'] as String? ?? '+91 22 0000 0000',
      address: json['address'] as String? ?? 'Mumbai',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      isOpen: json['isOpen'] as bool? ?? true,
      operatingHours: json['operatingHours'] as String? ?? '8:00 AM - 8:00 PM',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      testsAvailable: (json['testsAvailable'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'address': address,
      'rating': rating,
      'isOpen': isOpen,
      'operatingHours': operatingHours,
      'specialties': specialties,
      'testsAvailable': testsAvailable,
    };
  }
}

class ClinicRankResult {
  final Clinic clinic;
  final double distanceKm;
  final int travelMinutes;
  final double totalScore;
  final int matchedSpecialtiesCount;
  final int rank;

  const ClinicRankResult({
    required this.clinic,
    required this.distanceKm,
    required this.travelMinutes,
    required this.totalScore,
    required this.matchedSpecialtiesCount,
    required this.rank,
  });
}
