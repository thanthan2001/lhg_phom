class LendItemModel {
  final String maPhom;
  final String tenPhom;
  final String soThe;
  final String ngayMuon;
  final String ngayTra;

  LendItemModel({
    required this.maPhom,
    required this.tenPhom,
    required this.soThe,
    required this.ngayMuon,
    required this.ngayTra,
  });

  factory LendItemModel.fromJson(Map<String, dynamic> json) {
    return LendItemModel(
      maPhom: json['maPhom'],
      tenPhom: json['tenPhom'],
      soThe: json['soThe'],
      ngayMuon: json['ngayMuon'],
      ngayTra: json['ngayTra'],
    );
  }
}
