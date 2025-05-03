class UserModel {
  String? userId;
  String? password;
  String? userName;
  String? phoneNumbers;
  String? department;
  String? address;
  String? cccd;
  DateTime? dateOfBirth;
  String? role;
  String? isActive;

  UserModel({
    this.userId,
    this.password,
    this.userName,
    this.phoneNumbers,
    this.department,
    this.address,
    this.cccd,
    this.dateOfBirth,
    this.role,
    this.isActive ,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['USERID'] ?? '',
      password: json['PWD'] ?? '',
      userName: json['USERNAME'] ?? '',
      phoneNumbers: json['phoneNumbers'] ?? '',
      department: json['department'] ?? '',
      address: json['address'] ?? '',
      cccd: json['CCCD'] ?? '',
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : null,
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'USERID': userId ?? '',
      'PWD': password ?? '',
      'USERNAME': userName ?? '',
      'phoneNumbers': phoneNumbers ?? '',
      'department': department ?? '',
      'address': address ?? '',
      'CCCD': cccd ?? '',
      'dateOfBirth': dateOfBirth?.toIso8601String() ?? '',
      'role': role ?? 'user',
      'isActive': isActive ?? '',
    };
  }
}
