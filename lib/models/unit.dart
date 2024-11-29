// models/unit.dart

class Unit {
  final String id;
  final String name;
  final int floorNumber;
  final String buildingId;
  final double rent;
  final int waterUnitsConsumed;
  final double costOfWater;
  final double garbageFee;
  final String status;
  final String type;

  Unit({
    required this.id,
    required this.name,
    required this.floorNumber,
    required this.buildingId,
    required this.rent,
    required this.waterUnitsConsumed,
    required this.costOfWater,
    required this.garbageFee,
    required this.status,
    required this.type,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['_id'],
      name: json['unitName'],
      floorNumber: json['floorNumber'],
      buildingId: json['building'],
      rent: json['rent'],
      waterUnitsConsumed: json['waterUnitsConsumed'],
      costOfWater: json['costOfWater'],
      garbageFee: json['garbageFee'],
      status: json['status'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'floorNumber': floorNumber,
      'buildingId': buildingId,
      'rent': rent,
      'waterUnitsConsumed': waterUnitsConsumed,
      'costOfWater': costOfWater,
      'garbageFee': garbageFee,
      'status': status,
      'type': type,
    };
  }
}
