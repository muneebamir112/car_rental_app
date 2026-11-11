enum UserRole { admin, customer }

class User {
  final String id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final UserRole role;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.role,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'mobileNumber': mobileNumber,
    'role': role.name,
    'profileImageUrl': profileImageUrl,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    fullName: json['fullName'],
    email: json['email'],
    mobileNumber: json['mobileNumber'],
    role: json['role'] == 'admin' ? UserRole.admin : UserRole.customer,
    profileImageUrl: json['profileImageUrl'],
  );
}
