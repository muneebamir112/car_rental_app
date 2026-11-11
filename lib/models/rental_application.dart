class RentalApplication {
  final String applicationId;
  final String customerId;
  final String customerName;
  final String vehicleId;
  final String vehicleName;
  final String vehicleRegistrationNumber;

  // Step 1: Personal Info (All Compulsory)
  final String fullName;
  final String fatherName;
  final String cnicNumber;
  final String dateOfBirth;
  final String mobileNumber;
  final String email;
  final String residentialAddress;
  final String city;
  final String emergencyContactName;
  final String emergencyContactNumber;

  // Step 2: Driving Licence Info (All Compulsory)
  final String licenceNumber;
  final String licenceIssuingAuthority;
  final String licenceIssueDate;
  final String licenceExpiryDate;
  final String licenceCategory;

  // Step 3: Mandatory Document Uploads
  final String cnicFrontImagePath;
  final String cnicBackImagePath;
  final String licenceFrontImagePath;
  final String licenceBackImagePath;

  // Step 4: Mandatory Live Front-Camera Selfie
  final String selfieImagePath;

  // Step 5: Digital Signature
  final String signatureImagePath;

  // Step 6: Mandatory Thumb Impression
  final String thumbImpressionPath;

  // Step 7 & 8: Rental Information & Agreement
  final DateTime pickupDateTime;
  final DateTime returnDateTime;
  final String pickupLocation;
  final String dropOffLocation;
  final int rentalDurationDays;
  final double dailyRate;
  final double securityDeposit;
  final double totalEstimatedCharges;
  final bool agreementAccepted;

  // Status & Metadata
  String status; // Pending Approval, Approved, Rejected, Under Review, Active, Completed, Cancelled
  final DateTime submissionDate;
  String? rejectionReason;

  RentalApplication({
    required this.applicationId,
    required this.customerId,
    required this.customerName,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleRegistrationNumber,
    required this.fullName,
    required this.fatherName,
    required this.cnicNumber,
    required this.dateOfBirth,
    required this.mobileNumber,
    required this.email,
    required this.residentialAddress,
    required this.city,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
    required this.licenceNumber,
    required this.licenceIssuingAuthority,
    required this.licenceIssueDate,
    required this.licenceExpiryDate,
    required this.licenceCategory,
    required this.cnicFrontImagePath,
    required this.cnicBackImagePath,
    required this.licenceFrontImagePath,
    required this.licenceBackImagePath,
    required this.selfieImagePath,
    required this.signatureImagePath,
    required this.thumbImpressionPath,
    required this.pickupDateTime,
    required this.returnDateTime,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.rentalDurationDays,
    required this.dailyRate,
    required this.securityDeposit,
    required this.totalEstimatedCharges,
    required this.agreementAccepted,
    this.status = 'Pending Approval',
    required this.submissionDate,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() => {
    'applicationId': applicationId,
    'customerId': customerId,
    'customerName': customerName,
    'vehicleId': vehicleId,
    'vehicleName': vehicleName,
    'vehicleRegistrationNumber': vehicleRegistrationNumber,
    'fullName': fullName,
    'fatherName': fatherName,
    'cnicNumber': cnicNumber,
    'dateOfBirth': dateOfBirth,
    'mobileNumber': mobileNumber,
    'email': email,
    'residentialAddress': residentialAddress,
    'city': city,
    'emergencyContactName': emergencyContactName,
    'emergencyContactNumber': emergencyContactNumber,
    'licenceNumber': licenceNumber,
    'licenceIssuingAuthority': licenceIssuingAuthority,
    'licenceIssueDate': licenceIssueDate,
    'licenceExpiryDate': licenceExpiryDate,
    'licenceCategory': licenceCategory,
    'cnicFrontImagePath': cnicFrontImagePath,
    'cnicBackImagePath': cnicBackImagePath,
    'licenceFrontImagePath': licenceFrontImagePath,
    'licenceBackImagePath': licenceBackImagePath,
    'selfieImagePath': selfieImagePath,
    'signatureImagePath': signatureImagePath,
    'thumbImpressionPath': thumbImpressionPath,
    'pickupDateTime': pickupDateTime.toIso8601String(),
    'returnDateTime': returnDateTime.toIso8601String(),
    'pickupLocation': pickupLocation,
    'dropOffLocation': dropOffLocation,
    'rentalDurationDays': rentalDurationDays,
    'dailyRate': dailyRate,
    'securityDeposit': securityDeposit,
    'totalEstimatedCharges': totalEstimatedCharges,
    'agreementAccepted': agreementAccepted,
    'status': status,
    'submissionDate': submissionDate.toIso8601String(),
    'rejectionReason': rejectionReason,
  };

  factory RentalApplication.fromJson(Map<String, dynamic> json) => RentalApplication(
    applicationId: json['applicationId'],
    customerId: json['customerId'],
    customerName: json['customerName'],
    vehicleId: json['vehicleId'],
    vehicleName: json['vehicleName'],
    vehicleRegistrationNumber: json['vehicleRegistrationNumber'],
    fullName: json['fullName'],
    fatherName: json['fatherName'],
    cnicNumber: json['cnicNumber'],
    dateOfBirth: json['dateOfBirth'],
    mobileNumber: json['mobileNumber'],
    email: json['email'],
    residentialAddress: json['residentialAddress'],
    city: json['city'],
    emergencyContactName: json['emergencyContactName'],
    emergencyContactNumber: json['emergencyContactNumber'],
    licenceNumber: json['licenceNumber'],
    licenceIssuingAuthority: json['licenceIssuingAuthority'],
    licenceIssueDate: json['licenceIssueDate'],
    licenceExpiryDate: json['licenceExpiryDate'],
    licenceCategory: json['licenceCategory'],
    cnicFrontImagePath: json['cnicFrontImagePath'],
    cnicBackImagePath: json['cnicBackImagePath'],
    licenceFrontImagePath: json['licenceFrontImagePath'],
    licenceBackImagePath: json['licenceBackImagePath'],
    selfieImagePath: json['selfieImagePath'],
    signatureImagePath: json['signatureImagePath'],
    thumbImpressionPath: json['thumbImpressionPath'],
    pickupDateTime: DateTime.parse(json['pickupDateTime']),
    returnDateTime: DateTime.parse(json['returnDateTime']),
    pickupLocation: json['pickupLocation'],
    dropOffLocation: json['dropOffLocation'],
    rentalDurationDays: json['rentalDurationDays'],
    dailyRate: (json['dailyRate'] as num).toDouble(),
    securityDeposit: (json['securityDeposit'] as num).toDouble(),
    totalEstimatedCharges: (json['totalEstimatedCharges'] as num).toDouble(),
    agreementAccepted: json['agreementAccepted'],
    status: json['status'],
    submissionDate: DateTime.parse(json['submissionDate']),
    rejectionReason: json['rejectionReason'],
  );
}
