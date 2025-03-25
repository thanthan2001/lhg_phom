
class UserModel {
  final String idUser;
  final String email;
  final String? userName;
  final String? phoneNumbers;
   String? avatar;
  final String? address;
  final String? cccd;
  final List<String>? cccdImg;
  final String? gender;
  final DateTime? dateOfBirth;
  final int coins;
  final String role; 
  final bool isActive;

  UserModel({
    required this.idUser,
    required this.email,
    this.userName,
    this.phoneNumbers,
    this.avatar,
    this.address,
    this.cccd,
    this.cccdImg,
    this.gender,
    this.dateOfBirth,
    this.coins = 0,
    this.role = 'user',
    this.isActive = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['idUser'],
      email: json['email'],
      userName: json['userName'],
      phoneNumbers: json['phoneNumbers'],
      avatar: json['avatar'],
      address: json['address'],
      cccd: json['CCCD'],
      cccdImg:
          json['CCCD_img'] != null ? List<String>.from(json['CCCD_img']) : null,
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      coins: json['coins'] ?? 0,
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'email': email,
      'userName': userName,
      'phoneNumbers': phoneNumbers,
      'avatar': avatar,
      'address': address,
      'CCCD': cccd,
      'CCCD_img': cccdImg,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'coins': coins,
      'role': role,
      'isActive': isActive,
    };
  }
}