class Customer {
  final String id;
  final String fullName;
  final String fatherName;
  final String cnicNumber;
  final String mobileNumber;
  final String residentialAddress;
  final String city;
  final String emergencyContactNumber;
  final String? drivingLicenceNumber; // OPTIONAL as per prompt!
  final String? cnicFrontPath; // CNIC Front Image
  final String? cnicBackPath; // CNIC Back Image
  final String? selfiePath; // Live Selfie Image
  final String? otherDocPath; // Other Verification Image
  final String? photoUrl;
  final DateTime registrationDate;

  Customer({
    required this.id,
    required this.fullName,
    required this.fatherName,
    required this.cnicNumber,
    required this.mobileNumber,
    required this.residentialAddress,
    required this.city,
    this.emergencyContactNumber = '',
    this.drivingLicenceNumber,
    this.cnicFrontPath,
    this.cnicBackPath,
    this.selfiePath,
    this.otherDocPath,
    this.photoUrl,
    required this.registrationDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'fatherName': fatherName,
    'cnicNumber': cnicNumber,
    'mobileNumber': mobileNumber,
    'residentialAddress': residentialAddress,
    'city': city,
    'emergencyContactNumber': emergencyContactNumber,
    'drivingLicenceNumber': drivingLicenceNumber,
    'cnicFrontPath': cnicFrontPath,
    'cnicBackPath': cnicBackPath,
    'selfiePath': selfiePath,
    'otherDocPath': otherDocPath,
    'photoUrl': photoUrl,
    'registrationDate': registrationDate.toIso8601String(),
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    fullName: json['fullName'],
    fatherName: json['fatherName'],
    cnicNumber: json['cnicNumber'],
    mobileNumber: json['mobileNumber'],
    residentialAddress: json['residentialAddress'],
    city: json['city'],
    emergencyContactNumber: json['emergencyContactNumber'] ?? '',
    drivingLicenceNumber: json['drivingLicenceNumber'],
    cnicFrontPath: json['cnicFrontPath'],
    cnicBackPath: json['cnicBackPath'],
    selfiePath: json['selfiePath'],
    otherDocPath: json['otherDocPath'],
    photoUrl: json['photoUrl'],
    registrationDate: DateTime.parse(json['registrationDate']),
  );
}
