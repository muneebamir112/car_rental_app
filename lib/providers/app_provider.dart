import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../services/mock_backend.dart';

class AppProvider extends ChangeNotifier {
  final MockBackend _backend = MockBackend();

  AppProvider() {
    _initPersistence();
  }

  void _initPersistence() async {
    await _backend.loadFromDisk();
    notifyListeners();
  }

  bool get isOwnerLoggedIn => _backend.isOwnerLoggedIn;
  String get companyName => _backend.companyName;
  String get companyPhone => _backend.companyPhone;
  String get companyAddress => _backend.companyAddress;

  List<Vehicle> get vehicles => _backend.vehicles.where((v) => !v.isArchived).toList();
  List<Customer> get customers => _backend.customers;
  List<Rental> get rentals => _backend.rentals;

  // Stats
  int get totalCars => vehicles.length;
  int get availableCars => vehicles.where((v) => v.status == VehicleStatus.available).toList().length;
  int get currentlyRentedCars => vehicles.where((v) => v.status == VehicleStatus.currentlyRented).toList().length;
  int get totalCustomers => customers.length;
  int get activeRentalsCount => rentals.where((r) => r.status == RentalStatus.active || r.status == RentalStatus.extended).toList().length;
  int get overdueRentalsCount => rentals.where((r) => r.isOverdue).toList().length;

  double get totalRevenue {
    double sum = 0.0;
    for (var r in rentals) {
      sum += r.advancePayment;
    }
    return sum;
  }

  double get totalSecurityDepositsHeld {
    double sum = 0.0;
    for (var r in rentals) {
      if (r.status == RentalStatus.active || r.status == RentalStatus.extended) {
        sum += r.securityDeposit;
      }
    }
    return sum;
  }

  // Auth & Change Password
  bool login(String email, String password) {
    bool ok = _backend.login(email, password);
    notifyListeners();
    return ok;
  }

  bool updateOwnerPassword(String currentPass, String newPass) {
    bool ok = _backend.updateOwnerPassword(currentPass, newPass);
    notifyListeners();
    return ok;
  }

  void logout() {
    _backend.logout();
    notifyListeners();
  }

  // Inventory
  void addVehicle(Vehicle v) {
    _backend.addVehicle(v);
    notifyListeners();
  }

  void updateVehicle(Vehicle v) {
    _backend.updateVehicle(v);
    notifyListeners();
  }

  void deleteVehicle(String id) {
    _backend.deleteVehicle(id);
    notifyListeners();
  }

  // Customer Management
  Customer? findCustomerByCnic(String cnic) {
    return _backend.findCustomerByCnic(cnic);
  }

  List<Customer> searchCustomers(String query) {
    return _backend.searchCustomers(query);
  }

  Customer saveOrUpdateCustomer(Customer c) {
    Customer saved = _backend.saveOrUpdateCustomer(c);
    notifyListeners();
    return saved;
  }

  // Rentals
  Rental createRental(Rental r) {
    Rental created = _backend.createRental(r);
    notifyListeners();
    return created;
  }

  void extendRental({
    required String rentalId,
    required DateTime newReturnDate,
    required int additionalDays,
    required double extensionCharges,
    String notes = '',
  }) {
    _backend.extendRental(
      rentalId: rentalId,
      newReturnDate: newReturnDate,
      additionalDays: additionalDays,
      extensionCharges: extensionCharges,
      notes: notes,
    );
    notifyListeners();
  }

  void completeRentalReturn({
    required String rentalId,
    required DateTime actualReturnDate,
    double lateFee = 0.0,
    double damageFee = 0.0,
    double additionalPaid = 0.0,
  }) {
    _backend.completeRentalReturn(
      rentalId: rentalId,
      actualReturnDate: actualReturnDate,
      lateFee: lateFee,
      damageFee: damageFee,
      additionalPaid: additionalPaid,
    );
    notifyListeners();
  }
}
