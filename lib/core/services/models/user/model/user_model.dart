class UserModel {
  String? userId;
  String? password;
  String? userName;
  String? phoneNumbers;
  String? department;
  String? address;
  String? cccd;
  String? role;
  String? isActive;
  String? companyName;

  UserModel({
    this.userId,
    this.password,
    this.userName,
    this.phoneNumbers,
    this.department,
    this.address,
    this.cccd,
    this.role,
    this.isActive,
    this.companyName,
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
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? '',
      companyName: json['companyName'] ?? '',
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
      'role': role ?? 'user',
      'isActive': isActive ?? '',
      'companyName': companyName ?? '',
    };
  }
}
