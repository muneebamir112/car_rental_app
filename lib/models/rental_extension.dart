class RentalExtension {
  final String extensionId;
  final String rentalId;
  final DateTime previousReturnDate;
  final DateTime newReturnDate;
  final int additionalDays;
  final double extensionCharges;
  final DateTime extensionDate;
  final String notes;

  RentalExtension({
    required this.extensionId,
    required this.rentalId,
    required this.previousReturnDate,
    required this.newReturnDate,
    required this.additionalDays,
    required this.extensionCharges,
    required this.extensionDate,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'extensionId': extensionId,
    'rentalId': rentalId,
    'previousReturnDate': previousReturnDate.toIso8601String(),
    'newReturnDate': newReturnDate.toIso8601String(),
    'additionalDays': additionalDays,
    'extensionCharges': extensionCharges,
    'extensionDate': extensionDate.toIso8601String(),
    'notes': notes,
  };

  factory RentalExtension.fromJson(Map<String, dynamic> json) => RentalExtension(
    extensionId: json['extensionId'],
    rentalId: json['rentalId'],
    previousReturnDate: DateTime.parse(json['previousReturnDate']),
    newReturnDate: DateTime.parse(json['newReturnDate']),
    additionalDays: json['additionalDays'],
    extensionCharges: (json['extensionCharges'] as num).toDouble(),
    extensionDate: DateTime.parse(json['extensionDate']),
    notes: json['notes'] ?? '',
  );
}
