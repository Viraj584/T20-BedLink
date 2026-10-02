class BedCount {
  final int available;
  final int total;

  const BedCount({
    required this.available,
    required this.total,
  });

  factory BedCount.fromJson(Map<String, dynamic> json) {
    return BedCount(
      available: (json['available'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'available': available,
        'total': total,
      };

  BedCount copyWith({int? available, int? total}) {
    return BedCount(
      available: available ?? this.available,
      total: total ?? this.total,
    );
  }
}

class BedInventory {
  final BedCount icu;
  final BedCount ventilator;
  final BedCount oxygen;
  final BedCount cardiac;
  final BedCount burns;
  final BedCount general;

  const BedInventory({
    required this.icu,
    required this.ventilator,
    required this.oxygen,
    required this.cardiac,
    required this.burns,
    required this.general,
  });

  factory BedInventory.initial() {
    return const BedInventory(
      icu: BedCount(available: 0, total: 10),
      ventilator: BedCount(available: 0, total: 5),
      oxygen: BedCount(available: 0, total: 20),
      cardiac: BedCount(available: 0, total: 8),
      burns: BedCount(available: 0, total: 4),
      general: BedCount(available: 0, total: 30),
    );
  }

  BedCount getForType(String bedType) {
    switch (bedType.toLowerCase()) {
      case 'icu':
        return icu;
      case 'ventilator':
        return ventilator;
      case 'oxygen':
        return oxygen;
      case 'cardiac':
        return cardiac;
      case 'burns':
        return burns;
      case 'general':
      default:
        return general;
    }
  }

  BedInventory updateForType(String bedType, BedCount newCount) {
    switch (bedType.toLowerCase()) {
      case 'icu':
        return copyWith(icu: newCount);
      case 'ventilator':
        return copyWith(ventilator: newCount);
      case 'oxygen':
        return copyWith(oxygen: newCount);
      case 'cardiac':
        return copyWith(cardiac: newCount);
      case 'burns':
        return copyWith(burns: newCount);
      case 'general':
      default:
        return copyWith(general: newCount);
    }
  }

  factory BedInventory.fromJson(Map<String, dynamic> json) {
    return BedInventory(
      icu: json['icu'] != null
          ? BedCount.fromJson(Map<String, dynamic>.from(json['icu']))
          : const BedCount(available: 0, total: 0),
      ventilator: json['ventilator'] != null
          ? BedCount.fromJson(Map<String, dynamic>.from(json['ventilator']))
          : const BedCount(available: 0, total: 0),
      oxygen: json['oxygen'] != null
          ? BedCount.fromJson(Map<String, dynamic>.from(json['oxygen']))
          : const BedCount(available: 0, total: 0),
      cardiac: json['cardiac'] != null
          ? BedCount.fromJson(Map<String, dynamic>.from(json['cardiac']))
          : const BedCount(available: 0, total: 0),
      burns: json['burns'] != null
          ? BedCount.fromJson(Map<String, dynamic>.from(json['burns']))
          : const BedCount(available: 0, total: 0),
      general: json['general'] != null
          ? BedCount.fromJson(Map<String, dynamic>.from(json['general']))
          : const BedCount(available: 0, total: 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'icu': icu.toJson(),
        'ventilator': ventilator.toJson(),
        'oxygen': oxygen.toJson(),
        'cardiac': cardiac.toJson(),
        'burns': burns.toJson(),
        'general': general.toJson(),
      };

  BedInventory copyWith({
    BedCount? icu,
    BedCount? ventilator,
    BedCount? oxygen,
    BedCount? cardiac,
    BedCount? burns,
    BedCount? general,
  }) {
    return BedInventory(
      icu: icu ?? this.icu,
      ventilator: ventilator ?? this.ventilator,
      oxygen: oxygen ?? this.oxygen,
      cardiac: cardiac ?? this.cardiac,
      burns: burns ?? this.burns,
      general: general ?? this.general,
    );
  }
}
