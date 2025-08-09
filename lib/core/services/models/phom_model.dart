class PhomBindingItem {
  final String? rfid;
  final String? lastMatNo;
  final String? lastName;
  final String? lastno;
  final String? lastType;
  final String? material;
  final String? lastSize;
  final String? lastSide;
  final String? dateIn;
  final String? userID;
  final String? shelfName;
  final String? rfidShortcut;

  final String? companyName;

  PhomBindingItem({
    this.rfid,
    this.lastMatNo,
    this.lastName,
    this.lastno,
    this.lastType,
    this.material,
    this.lastSize,
    this.lastSide,
    this.dateIn,
    this.userID,
    this.shelfName,
    this.rfidShortcut,
    this.companyName,
  });

  Map<String, dynamic> toJson() {
    return {
      "RFID": rfid,
      "LastMatNo": lastMatNo,
      "LastName": lastName,
      "LastNo": lastno,
      "LastType": lastType,
      "Material": material,
      "LastSize": lastSize,
      "LastSide": lastSide,
      "DateIn": dateIn,
      "UserID": userID,
      "ShelfName": shelfName,
      "RFIDShortcut": rfidShortcut,
      "companyName": companyName,
    };
  }
}
