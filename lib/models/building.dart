// models/building.dart

import 'unit.dart';

class Building {
  final String id;
  final String name;
  final String location;
  final int totalFloors;
  final int unitsPerFloor;
  List<Unit> units;

  Building({
    required this.id,
    required this.name,
    required this.location,
    required this.totalFloors,
    required this.unitsPerFloor,
    this.units = const [],
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      totalFloors: json['totalFloors'] ?? 0,
      unitsPerFloor: json['unitsPerFloor'] ?? 0,
      units: (json['units'] as List<dynamic>?)
              ?.map((unit) => Unit.fromJson(unit))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'name': name,
      'location': location,
      'totalFloors': totalFloors,
      'unitsPerFloor': unitsPerFloor,
      // 'units': units.map((unit) => unit.toJson()).toList(),
    };
  }
}
