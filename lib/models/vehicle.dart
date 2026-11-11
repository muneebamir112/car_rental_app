enum VehicleStatus { available, currentlyRented, underMaintenance, unavailable }

class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int manufacturingYear;
  final String registrationNumber;
  final String color;
  final String transmission; // Automatic, Manual
  final String fuelType; // Petrol, Diesel, Hybrid, Electric
  final int seatingCapacity;
  final String description;
  final double dailyPrice;
  final double hourlyPrice;
  final double securityDeposit;
  final List<String> imageUrls;
  VehicleStatus status;
  bool isArchived;

  Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.registrationNumber,
    required this.color,
    required this.transmission,
    required this.fuelType,
    required this.seatingCapacity,
    required this.description,
    required this.dailyPrice,
    this.hourlyPrice = 0.0,
    this.securityDeposit = 0.0,
    required this.imageUrls,
    this.status = VehicleStatus.available,
    this.isArchived = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'model': model,
    'manufacturingYear': manufacturingYear,
    'registrationNumber': registrationNumber,
    'color': color,
    'transmission': transmission,
    'fuelType': fuelType,
    'seatingCapacity': seatingCapacity,
    'description': description,
    'dailyPrice': dailyPrice,
    'hourlyPrice': hourlyPrice,
    'securityDeposit': securityDeposit,
    'imageUrls': imageUrls,
    'status': status.name,
    'isArchived': isArchived,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    model: json['model'],
    manufacturingYear: json['manufacturingYear'],
    registrationNumber: json['registrationNumber'],
    color: json['color'] ?? 'Black',
    transmission: json['transmission'],
    fuelType: json['fuelType'],
    seatingCapacity: json['seatingCapacity'],
    description: json['description'],
    dailyPrice: (json['dailyPrice'] as num).toDouble(),
    hourlyPrice: (json['hourlyPrice'] as num?)?.toDouble() ?? 0.0,
    securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0.0,
    imageUrls: List<String>.from(json['imageUrls']),
    status: VehicleStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => VehicleStatus.available,
    ),
    isArchived: json['isArchived'] ?? false,
  );
}
