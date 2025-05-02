class User {
  String? userID;
  String? password;
  String? userName;
  String? departmentID;

  User({this.userID, this.password, this.userName, this.departmentID});

  User.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    password = json['password'];
    userName = json['userName'];
    departmentID = json['departmentID'];
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'password': password,
      'userName': userName,
      'departmentID': departmentID,
    };
  }
}
