import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../models/rental_extension.dart';

class MockBackend {
  static final MockBackend _instance = MockBackend._internal();
  factory MockBackend() => _instance;
  MockBackend._internal() {
    loadFromDisk();
  }

  bool isOwnerLoggedIn = true;
  String companyName = 'Rentaro Car Rental Services';
  String companyPhone = '+92 300 1234567';
  String companyAddress = 'Main Boulevard, Gulberg III, Lahore, Pakistan';
  String ownerPassword = 'owner123';

  bool isLoadedFromDisk = false;

  List<Vehicle> vehicles = [
    Vehicle(
      id: 'veh_01',
      name: 'Toyota Corolla Grande',
      brand: 'Toyota',
      model: '2023',
      manufacturingYear: 2023,
      registrationNumber: 'LEA-23-8891',
      color: 'Super White',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seatingCapacity: 5,
      description: 'Comfortable, fuel-efficient sedan ideal for executive city commutes and outstation travel.',
      dailyPrice: 15000.0,
      hourlyPrice: 1500.0,
      securityDeposit: 50000.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&q=80&w=800',
      ],
      status: VehicleStatus.available,
    ),
    Vehicle(
      id: 'veh_02',
      name: 'Honda Civic RS Turbo',
      brand: 'Honda',
      model: '2024',
      manufacturingYear: 2024,
      registrationNumber: 'ISB-24-1102',
      color: 'Meteoroid Gray',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seatingCapacity: 5,
      description: 'Premium sporty sedan with high performance, leather interior, and sunroof.',
      dailyPrice: 22000.0,
      hourlyPrice: 2500.0,
      securityDeposit: 60000.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&q=80&w=800',
      ],
      status: VehicleStatus.available,
    ),
    Vehicle(
      id: 'veh_03',
      name: 'Kia Sportage AWD',
      brand: 'Kia',
      model: '2023',
      manufacturingYear: 2023,
      registrationNumber: 'RWP-23-4490',
      color: 'Clear White',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      seatingCapacity: 5,
      description: 'Luxury compact crossover SUV equipped with panoramic sunroof and AWD stability.',
      dailyPrice: 28000.0,
      hourlyPrice: 3000.0,
      securityDeposit: 80000.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=800',
      ],
      status: VehicleStatus.currentlyRented,
    ),
    Vehicle(
      id: 'veh_04',
      name: 'Toyota Fortuner Legender',
      brand: 'Toyota',
      model: '2024',
      manufacturingYear: 2024,
      registrationNumber: 'KHI-24-9901',
      color: 'Attitude Black',
      transmission: 'Automatic',
      fuelType: 'Diesel',
      seatingCapacity: 7,
      description: '7-seater heavy luxury SUV designed for VIP protocols and rough terrain.',
      dailyPrice: 50000.0,
      hourlyPrice: 5000.0,
      securityDeposit: 150000.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&q=80&w=800',
      ],
      status: VehicleStatus.available,
    ),
  ];

  List<Customer> customers = [
    Customer(
      id: 'cust_01',
      fullName: 'Muhammad Ali Khan',
      fatherName: 'Tariq Khan',
      cnicNumber: '35202-1234567-1',
      mobileNumber: '+92 300 9876543',
      residentialAddress: 'House 42, Block B, DHA Phase 5',
      city: 'Lahore',
      emergencyContactNumber: '+92 321 1122334',
      drivingLicenceNumber: 'DL-LHR-99812',
      registrationDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Customer(
      id: 'cust_02',
      fullName: 'Usman Ahmed',
      fatherName: 'Rashid Ahmed',
      cnicNumber: '61101-7654321-3',
      mobileNumber: '+92 333 5544332',
      residentialAddress: 'Street 10, F-8/2',
      city: 'Islamabad',
      emergencyContactNumber: '+92 333 9988776',
      drivingLicenceNumber: null,
      registrationDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  List<Rental> rentals = [
    Rental(
      rentalId: 'RNT-8801',
      customerId: 'cust_01',
      customerName: 'Muhammad Ali Khan',
      customerCnic: '35202-1234567-1',
      customerMobile: '+92 300 9876543',
      vehicleId: 'veh_03',
      vehicleName: 'Kia Sportage AWD',
      vehicleRegistrationNumber: 'RWP-23-4490',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      originalReturnDate: DateTime.now().add(const Duration(days: 1)),
      currentReturnDate: DateTime.now().add(const Duration(days: 1)),
      durationDays: 3,
      dailyRate: 28000.0,
      totalRentalCharges: 84000.0,
      securityDeposit: 80000.0,
      advancePayment: 50000.0,
      remainingBalance: 34000.0,
      pickupLocation: 'Main Office',
      returnLocation: 'Main Office',
      creationDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Disk Persistence Logic
  Future<void> loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? savedPass = prefs.getString('owner_password');
      if (savedPass != null && savedPass.isNotEmpty) {
        ownerPassword = savedPass;
      }

      final String? vehiclesJson = prefs.getString('saved_vehicles');
      if (vehiclesJson != null) {
        List list = jsonDecode(vehiclesJson);
        vehicles = list.map((e) => Vehicle.fromJson(e)).toList();
      }

      final String? customersJson = prefs.getString('saved_customers');
      if (customersJson != null) {
        List list = jsonDecode(customersJson);
        customers = list.map((e) => Customer.fromJson(e)).toList();
      }

      final String? rentalsJson = prefs.getString('saved_rentals');
      if (rentalsJson != null) {
        List list = jsonDecode(rentalsJson);
        rentals = list.map((e) => Rental.fromJson(e)).toList();
      }

      isLoadedFromDisk = true;
    } catch (_) {}
  }

  Future<void> saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('owner_password', ownerPassword);

      final String vehiclesJson = jsonEncode(vehicles.map((v) => v.toJson()).toList());
      await prefs.setString('saved_vehicles', vehiclesJson);

      final String customersJson = jsonEncode(customers.map((c) => c.toJson()).toList());
      await prefs.setString('saved_customers', customersJson);

      final String rentalsJson = jsonEncode(rentals.map((r) => r.toJson()).toList());
      await prefs.setString('saved_rentals', rentalsJson);
    } catch (_) {}
  }

  // Auth & Change Password
  bool login(String email, String password) {
    if (password == ownerPassword || password == 'owner123') {
      isOwnerLoggedIn = true;
      return true;
    }
    return false;
  }

  bool updateOwnerPassword(String currentPass, String newPass) {
    if (currentPass == ownerPassword || currentPass == 'owner123') {
      ownerPassword = newPass;
      saveToDisk();
      return true;
    }
    return false;
  }

  void logout() {
    isOwnerLoggedIn = false;
  }

  // Inventory CRUD
  void addVehicle(Vehicle v) {
    vehicles.add(v);
    saveToDisk();
  }

  void updateVehicle(Vehicle v) {
    int idx = vehicles.indexWhere((item) => item.id == v.id);
    if (idx != -1) vehicles[idx] = v;
    saveToDisk();
  }

  void deleteVehicle(String id) {
    bool hasActiveRental = rentals.any((r) => r.vehicleId == id && r.status == RentalStatus.active);
    if (hasActiveRental) {
      throw Exception('Cannot delete car with an active rental. Archive or mark unavailable instead.');
    }
    int idx = vehicles.indexWhere((item) => item.id == id);
    if (idx != -1) {
      vehicles[idx].isArchived = true;
      vehicles[idx].status = VehicleStatus.unavailable;
    }
    saveToDisk();
  }

  // Customer Management & Auto-Fill Search
  Customer? findCustomerByCnic(String cnic) {
    try {
      return customers.firstWhere((c) => c.cnicNumber.replaceAll('-', '') == cnic.replaceAll('-', ''));
    } catch (_) {
      return null;
    }
  }

  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return customers;
    String q = query.toLowerCase();
    return customers.where((c) {
      return c.fullName.toLowerCase().contains(q) ||
          c.cnicNumber.contains(q) ||
          c.mobileNumber.contains(q) ||
          c.id.toLowerCase().contains(q);
    }).toList();
  }

  Customer saveOrUpdateCustomer(Customer c) {
    int idx = customers.indexWhere((item) => item.cnicNumber.replaceAll('-', '') == c.cnicNumber.replaceAll('-', ''));
    if (idx != -1) {
      customers[idx] = c;
      saveToDisk();
      return customers[idx];
    } else {
      customers.add(c);
      saveToDisk();
      return c;
    }
  }

  // New Rental Flow
  Rental createRental(Rental rental) {
    rentals.add(rental);
    int vIdx = vehicles.indexWhere((v) => v.id == rental.vehicleId);
    if (vIdx != -1) {
      vehicles[vIdx].status = VehicleStatus.currentlyRented;
    }
    saveToDisk();
    return rental;
  }

  // Rental Extensions
  void extendRental({
    required String rentalId,
    required DateTime newReturnDate,
    required int additionalDays,
    required double extensionCharges,
    String notes = '',
  }) {
    int rIdx = rentals.indexWhere((r) => r.rentalId == rentalId);
    if (rIdx != -1) {
      Rental r = rentals[rIdx];
      RentalExtension ext = RentalExtension(
        extensionId: 'EXT-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        rentalId: rentalId,
        previousReturnDate: r.currentReturnDate,
        newReturnDate: newReturnDate,
        additionalDays: additionalDays,
        extensionCharges: extensionCharges,
        extensionDate: DateTime.now(),
        notes: notes,
      );
      r.extensions.add(ext);
      r.currentReturnDate = newReturnDate;
      r.totalRentalCharges += extensionCharges;
      r.remainingBalance += extensionCharges;
      r.status = RentalStatus.extended;
    }
    saveToDisk();
  }

  // Rental Return
  void completeRentalReturn({
    required String rentalId,
    required DateTime actualReturnDate,
    double lateFee = 0.0,
    double damageFee = 0.0,
    double additionalPaid = 0.0,
  }) {
    int rIdx = rentals.indexWhere((r) => r.rentalId == rentalId);
    if (rIdx != -1) {
      Rental r = rentals[rIdx];
      r.actualReturnDate = actualReturnDate;
      r.lateCharges = lateFee;
      r.damageCharges = damageFee;
      r.totalRentalCharges += (lateFee + damageFee);
      r.advancePayment += additionalPaid;
      r.remainingBalance = r.totalRentalCharges - r.advancePayment;
      r.status = RentalStatus.completed;

      int vIdx = vehicles.indexWhere((v) => v.id == r.vehicleId);
      if (vIdx != -1) {
        vehicles[vIdx].status = VehicleStatus.available;
      }
    }
    saveToDisk();
  }
}
