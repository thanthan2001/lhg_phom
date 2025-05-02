import 'package:lhg_phom/core/services/models/size_infor_model.dart' show SizeInfoModel;

import 'user/model/user_model.dart';

class LendItemModel {
  final String? idMuon;
  final UserModel? idNguoiMuon;
  final String? donVi;
  final String? maPhom;
  final String? tenPhom;
  final String? soThe;
  final String? ngayMuon;
  final String? ngayTra;
  final String? trangThai;
  final List<SizeInfoModel> sizes;

  LendItemModel({
    this.idMuon,
    this.idNguoiMuon,
    this.donVi,
    this.maPhom,
    this.tenPhom,
    this.soThe,
    this.ngayMuon,
    this.ngayTra,
    this.trangThai,
    this.sizes = const [],
  });

  factory LendItemModel.fromJson(Map<String, dynamic> json) {
    return LendItemModel(
      idMuon: json['idMuon'] ?? '',
      idNguoiMuon: json['idNguoiMuon'] != null
        ? UserModel.fromJson(json['idNguoiMuon'])
        : null,
      donVi: json['donVi'] ?? '',
      maPhom: json['maPhom']  ?? '',
      tenPhom: json['tenPhom'] ?? '',
      soThe: json['soThe'] ?? '',
      ngayMuon: json['ngayMuon'] ?? '',
      ngayTra: json['ngayTra'] ?? '',
      trangThai: json['trangThai'] ?? '',
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => SizeInfoModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMuon': idMuon,
      'idnguoiMuon': idNguoiMuon,
      'donVi': donVi,
      'maPhom': maPhom,
      'tenPhom': tenPhom,
      'soThe': soThe,
      'ngayMuon': ngayMuon,
      'ngayTra': ngayTra,
      'trangThai': trangThai,
      'sizes': sizes.map((e) => e.toJson()).toList(),
    };
  }
}

final exampleLendItems = <LendItemModel>[
  LendItemModel(
    idMuon: 'a1',
    idNguoiMuon: UserModel(
      userId: 'u1',
      password: '123456',
      userName: 'Nguyễn Văn A',
      department: 'D01',
    ),
    donVi: 'Xưởng A',
    maPhom: 'MP001',
    tenPhom: 'Phôm A',
    soThe: 'ST001',
    ngayMuon: '01/04/2025',
    ngayTra: '10/04/2025',
    trangThai: 'đăng ký mượn',
    sizes: [
      SizeInfoModel(size: '39', soLuong: 120, trai: 60, phai: 60, daTra: 25, chuaTra: 35),
      SizeInfoModel(size: '40', soLuong: 160, trai: 80, phai: 80, daTra: 50, chuaTra: 30),
      SizeInfoModel(size: '41', soLuong: 180, trai: 90, phai: 90, daTra: 70, chuaTra: 20),
    ],
  ),
  LendItemModel(
    idMuon: 'b2',
    idNguoiMuon: UserModel(
      userId: 'u2',
      password: 'abcdef',
      userName: 'Trần Thị B',
      department: 'D02',
    ),
    donVi: 'Xưởng B',
    maPhom: 'MP002',
    tenPhom: 'Phôm B',
    soThe: 'ST002',
    ngayMuon: '03/04/2025',
    ngayTra: '13/04/2025',
    trangThai: 'đăng ký mượn',
    sizes: [
      SizeInfoModel(size: '38', soLuong: 80, trai: 40, phai: 40, daTra: 30, chuaTra: 10),
      SizeInfoModel(size: '39', soLuong: 100, trai: 50, phai: 50, daTra: 40, chuaTra: 10),
      SizeInfoModel(size: '40', soLuong: 120, trai: 60, phai: 60, daTra: 45, chuaTra: 15),
    ],
  ),
  LendItemModel(
    idMuon: 'c3',
    idNguoiMuon: UserModel(
      userId: 'u3',
      password: '123abc',
      userName: 'Lê Văn C',
      department: 'D03',
    ),
    donVi: 'Xưởng C',
    maPhom: 'MP003',
    tenPhom: 'Phôm C',
    soThe: 'ST003',
    ngayMuon: '05/04/2025',
    ngayTra: '15/04/2025',
    trangThai: 'đang mượn',
    sizes: [
      SizeInfoModel(size: '41', soLuong: 200, trai: 100, phai: 100, daTra: 60, chuaTra: 40),
      SizeInfoModel(size: '42', soLuong: 180, trai: 90, phai: 90, daTra: 70, chuaTra: 20),
    ],
  ),
  LendItemModel(
    idMuon: 'a4',
    idNguoiMuon: UserModel(
      userId: 'u4',
      password: 'xyz123',
      userName: 'Phạm Thị D',
      department: 'D04',
    ),
    donVi: 'Xưởng D',
    maPhom: 'MP004',
    tenPhom: 'Phôm D',
    soThe: 'ST004',
    ngayMuon: '06/04/2025',
    ngayTra: '16/04/2025',
    trangThai: 'đang mượn',
    sizes: [
      SizeInfoModel(size: '37', soLuong: 90, trai: 45, phai: 45, daTra: 20, chuaTra: 25),
      SizeInfoModel(size: '38', soLuong: 120, trai: 60, phai: 60, daTra: 35, chuaTra: 25),
    ],
  ),
  LendItemModel(
    idMuon: 'd5',
    idNguoiMuon: UserModel(
      userId: 'u5',
      password: 'qwerty',
      userName: 'Đỗ Văn E',
      department: 'D01',
    ),
    donVi: 'Xưởng A',
    maPhom: 'MP005',
    tenPhom: 'Phôm E',
    soThe: 'ST005',
    ngayMuon: '07/04/2025',
    ngayTra: '17/04/2025',
    trangThai: 'đã trả',
    sizes: [
      SizeInfoModel(size: '43', soLuong: 150, trai: 75, phai: 75, daTra: 75, chuaTra: 0),
      SizeInfoModel(size: '44', soLuong: 100, trai: 50, phai: 50, daTra: 50, chuaTra: 0),
    ],
  ),
  LendItemModel(
    idMuon: 'd6',
    idNguoiMuon: UserModel(
      userId: 'u6',
      password: '654321',
      userName: 'Nguyễn Thị F',
      department: 'D02',
    ),
    donVi: 'Xưởng B',
    maPhom: 'MP006',
    tenPhom: 'Phôm F',
    soThe: 'ST006',
    ngayMuon: '08/04/2025',
    ngayTra: '18/04/2025',
    trangThai: 'đã trả',
    sizes: [
      SizeInfoModel(size: '36', soLuong: 60, trai: 30, phai: 30, daTra: 30, chuaTra: 0),
      SizeInfoModel(size: '37', soLuong: 80, trai: 40, phai: 40, daTra: 40, chuaTra: 0),
    ],
  ),
  LendItemModel(
    idMuon: 's7',
    idNguoiMuon: UserModel(
      userId: 'u7',
      password: 'mypass',
      userName: 'Trần Văn G',
      department: 'D03',
    ),
    donVi: 'Xưởng C',
    maPhom: 'MP007',
    tenPhom: 'Phôm G',
    soThe: 'ST007',
    ngayMuon: '09/04/2025',
    ngayTra: '19/04/2025',
    trangThai: 'trả chưa đủ',
    sizes: [
      SizeInfoModel(size: '40', soLuong: 120, trai: 60, phai: 60, daTra: 50, chuaTra: 10),
      SizeInfoModel(size: '41', soLuong: 140, trai: 70, phai: 70, daTra: 65, chuaTra: 5),
    ],
  ),
  LendItemModel(
    idMuon: 'a8',
    idNguoiMuon: UserModel(
      userId: 'u8',
      password: '321321',
      userName: 'Lê Thị H',
      department: 'D04',
    ),
    donVi: 'Xưởng D',
    maPhom: 'MP008',
    tenPhom: 'Phôm H',
    soThe: 'ST008',
    ngayMuon: '10/04/2025',
    ngayTra: '20/04/2025',
    trangThai: 'trả chưa đủ',
    sizes: [
      SizeInfoModel(size: '38', soLuong: 100, trai: 50, phai: 50, daTra: 48, chuaTra: 2),
      SizeInfoModel(size: '39', soLuong: 120, trai: 60, phai: 60, daTra: 55, chuaTra: 5),
    ],
  ),
  LendItemModel(
    idMuon: 'b9',
    idNguoiMuon: UserModel(
      userId: 'u9',
      password: 'zxcvbn',
      userName: 'Phan Văn I',
      department: 'D01',
    ),
    donVi: 'Xưởng A',
    maPhom: 'MP009',
    tenPhom: 'Phôm I',
    soThe: 'ST009',
    ngayMuon: '11/04/2025',
    ngayTra: '21/04/2025',
    trangThai: 'đăng ký mượn',
    sizes: [
      SizeInfoModel(size: '42', soLuong: 160, trai: 80, phai: 80, daTra: 60, chuaTra: 20),
      SizeInfoModel(size: '43', soLuong: 180, trai: 90, phai: 90, daTra: 85, chuaTra: 5),
    ],
  ),
  LendItemModel(
    idMuon: 'q10',
    idNguoiMuon: UserModel(
      userId: 'u10',
      password: 'hello123',
      userName: 'Đặng Thị J',
      department: 'D02',
    ),
    donVi: 'Xưởng B',
    maPhom: 'MP010',
    tenPhom: 'Phôm J',
    soThe: 'ST010',
    ngayMuon: '12/04/2025',
    ngayTra: '22/04/2025',
    trangThai: 'chưa trả',
    sizes: [
      SizeInfoModel(size: '37', soLuong: 100, trai: 50, phai: 50, daTra: 0, chuaTra: 50),
      SizeInfoModel(size: '38', soLuong: 120, trai: 60, phai: 60, daTra: 0, chuaTra: 60),
    ],
  ),
];
