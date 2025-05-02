class SizeInfoModel {
  final String size;
  final int soLuong;
  final int trai;
  final int phai;
  final int daTra;
  final int chuaTra;

  SizeInfoModel({
    required this.size,
    required this.soLuong,
    required this.trai,
    required this.phai,
    required this.daTra,
    required this.chuaTra,
  });

  factory SizeInfoModel.fromJson(Map<String, dynamic> json) {
    return SizeInfoModel(
      size: json['size'] ?? '',
      soLuong: json['soLuong'] ?? 0,
      trai: json['trai'] ?? 0,
      phai: json['phai'] ?? 0,
      daTra: json['daTra'] ?? 0,
      chuaTra: json['chuaTra'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'soLuong': soLuong,
      'trai': trai,
      'phai': phai,
      'daTra': daTra,
      'chuaTra': chuaTra,
    };
  }
}
