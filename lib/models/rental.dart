import 'rental_extension.dart';

enum RentalStatus { active, completed, extended, overdue, cancelled }

class Rental {
  final String rentalId;
  final String customerId;
  final String customerName;
  final String customerCnic;
  final String customerMobile;
  final String vehicleId;
  final String vehicleName;
  final String vehicleRegistrationNumber;

  final DateTime startDate;
  final DateTime originalReturnDate;
  DateTime currentReturnDate;
  DateTime? actualReturnDate;

  final int durationDays;
  final double dailyRate;
  double totalRentalCharges;
  final double securityDeposit;
  double advancePayment;
  double remainingBalance;

  final String pickupLocation;
  final String returnLocation;
  double additionalCharges;
  double lateCharges;
  double damageCharges;
  String notes;

  // Verification Documents & Signatures
  final String? cnicFrontPath;
  final String? cnicBackPath;
  final String? selfiePath;
  final String? otherDocPath;
  final String? signatureImagePath; // Customer Signature
  final String? thumbImpressionPath; // Customer Thumb Impression
  final String? ownerSignatureImagePath; // Owner Signature

  RentalStatus status;
  final DateTime creationDate;
  final List<RentalExtension> extensions;

  Rental({
    required this.rentalId,
    required this.customerId,
    required this.customerName,
    required this.customerCnic,
    required this.customerMobile,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleRegistrationNumber,
    required this.startDate,
    required this.originalReturnDate,
    required this.currentReturnDate,
    this.actualReturnDate,
    required this.durationDays,
    required this.dailyRate,
    required this.totalRentalCharges,
    required this.securityDeposit,
    required this.advancePayment,
    required this.remainingBalance,
    required this.pickupLocation,
    required this.returnLocation,
    this.additionalCharges = 0.0,
    this.lateCharges = 0.0,
    this.damageCharges = 0.0,
    this.notes = '',
    this.cnicFrontPath,
    this.cnicBackPath,
    this.selfiePath,
    this.otherDocPath,
    this.signatureImagePath,
    this.thumbImpressionPath,
    this.ownerSignatureImagePath,
    this.status = RentalStatus.active,
    required this.creationDate,
    List<RentalExtension>? extensions,
  }) : extensions = extensions ?? [];

  bool get isOverdue =>
      status == RentalStatus.active && DateTime.now().isAfter(currentReturnDate);

  Map<String, dynamic> toJson() => {
    'rentalId': rentalId,
    'customerId': customerId,
    'customerName': customerName,
    'customerCnic': customerCnic,
    'customerMobile': customerMobile,
    'vehicleId': vehicleId,
    'vehicleName': vehicleName,
    'vehicleRegistrationNumber': vehicleRegistrationNumber,
    'startDate': startDate.toIso8601String(),
    'originalReturnDate': originalReturnDate.toIso8601String(),
    'currentReturnDate': currentReturnDate.toIso8601String(),
    'actualReturnDate': actualReturnDate?.toIso8601String(),
    'durationDays': durationDays,
    'dailyRate': dailyRate,
    'totalRentalCharges': totalRentalCharges,
    'securityDeposit': securityDeposit,
    'advancePayment': advancePayment,
    'remainingBalance': remainingBalance,
    'pickupLocation': pickupLocation,
    'returnLocation': returnLocation,
    'additionalCharges': additionalCharges,
    'lateCharges': lateCharges,
    'damageCharges': damageCharges,
    'notes': notes,
    'cnicFrontPath': cnicFrontPath,
    'cnicBackPath': cnicBackPath,
    'selfiePath': selfiePath,
    'otherDocPath': otherDocPath,
    'signatureImagePath': signatureImagePath,
    'thumbImpressionPath': thumbImpressionPath,
    'ownerSignatureImagePath': ownerSignatureImagePath,
    'status': status.name,
    'creationDate': creationDate.toIso8601String(),
    'extensions': extensions.map((e) => e.toJson()).toList(),
  };

  factory Rental.fromJson(Map<String, dynamic> json) => Rental(
    rentalId: json['rentalId'],
    customerId: json['customerId'],
    customerName: json['customerName'],
    customerCnic: json['customerCnic'],
    customerMobile: json['customerMobile'],
    vehicleId: json['vehicleId'],
    vehicleName: json['vehicleName'],
    vehicleRegistrationNumber: json['vehicleRegistrationNumber'],
    startDate: DateTime.parse(json['startDate']),
    originalReturnDate: DateTime.parse(json['originalReturnDate']),
    currentReturnDate: DateTime.parse(json['currentReturnDate']),
    actualReturnDate: json['actualReturnDate'] != null ? DateTime.parse(json['actualReturnDate']) : null,
    durationDays: json['durationDays'],
    dailyRate: (json['dailyRate'] as num).toDouble(),
    totalRentalCharges: (json['totalRentalCharges'] as num).toDouble(),
    securityDeposit: (json['securityDeposit'] as num).toDouble(),
    advancePayment: (json['advancePayment'] as num).toDouble(),
    remainingBalance: (json['remainingBalance'] as num).toDouble(),
    pickupLocation: json['pickupLocation'],
    returnLocation: json['returnLocation'],
    additionalCharges: (json['additionalCharges'] as num?)?.toDouble() ?? 0.0,
    lateCharges: (json['lateCharges'] as num?)?.toDouble() ?? 0.0,
    damageCharges: (json['damageCharges'] as num?)?.toDouble() ?? 0.0,
    notes: json['notes'] ?? '',
    cnicFrontPath: json['cnicFrontPath'],
    cnicBackPath: json['cnicBackPath'],
    selfiePath: json['selfiePath'],
    otherDocPath: json['otherDocPath'],
    signatureImagePath: json['signatureImagePath'],
    thumbImpressionPath: json['thumbImpressionPath'],
    ownerSignatureImagePath: json['ownerSignatureImagePath'],
    status: RentalStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => RentalStatus.active),
    creationDate: DateTime.parse(json['creationDate']),
    extensions: (json['extensions'] as List?)?.map((e) => RentalExtension.fromJson(e)).toList(),
  );
}
