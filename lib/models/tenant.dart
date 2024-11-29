/// Represents a tenant in the property management system.
class Tenant {
  /// The unique identifier for the tenant.
  final String id;

  /// The tenant's first name.
  final String firstName;

  /// The tenant's last name.
  final String lastName;

  /// The tenant's phone number.
  final String phoneNumber;

  /// The tenant's email address.
  final String email;

  /// The current status of the tenant's tenancy.
  final String tenancyStatus;

  /// A map containing details about the unit the tenant occupies.
  final Map<String, dynamic> unit;

  /// Constructs a new [Tenant] object.
  Tenant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.tenancyStatus,
    required this.unit,
  });

  /// Constructs a new [Tenant] object from a JSON map.
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      tenancyStatus: json['tenancyStatus'],
      unit: json['unit'] as Map<String, dynamic>,
    );
  }

  /// Converts the [Tenant] object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'unit': unit,
      'tenancyStatus': tenancyStatus,
    };
  }

  /// Gets the unique identifier of the unit the tenant occupies.
  String get unitId => unit['_id'];

  /// Gets the name of the unit the tenant occupies.
  String get unitName => unit['unitName'];

  /// Gets the name of the building where the tenant's unit is located.
  String get buildingName => (unit['building'] as Map<String, dynamic>)['name'];

  /// Gets the floor number of the tenant's unit.
  int get floorNumber => unit['floorNumber'];

  /// Gets the type of the tenant's unit.
  String get unitType => unit['type'];

  /// Gets the rent amount of the tenant's unit.
  double get rent => unit['rent'].toDouble();

  /// Gets the cost of water for the tenant's unit.
  double get waterCost => unit['costOfWater'].toDouble();

  /// Gets the garbage fee for the tenant's unit.
  double get garbageFee => unit['garbageFee'].toDouble();

  /// Gets the status of the tenant's unit.
  String get unitStatus => unit['status'];

  /// Gets the unique identifier of the building where the tenant's unit is located.
  String get buildingId => (unit['building'] as Map<String, dynamic>)['_id'];

  /// Prints the tenant in the form of a map.
  void printTenant() {
    print({
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'tenancyStatus': tenancyStatus,
      'unit': unit,
    });
  }
}
