import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lhg_phom/core/utils/app_snackbar.dart';

import '../../../../../../core/configs/prefs_contants.dart';
import '../../../../../../core/services/dio.api.service.dart';
import '../../../../../../core/services/models/user/domain/usecase/get_user_use_case.dart';
import '../../../../../../core/services/models/user/model/user_model.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var counter = 0.obs;
  final GetuserUseCase _getuserUseCase;
  UserModel? user;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  HomeController(this._getuserUseCase);
  String? companyName = "";
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      user = await _getuserUseCase.getUser();
      if (user?.companyName == null || user!.companyName!.isEmpty) {
        AppSnackbar.show(
          'Lỗi',
          'Không tìm thấy thông tin người dùng hoặc công ty.',
        );
        return;
      }
      companyName = user!.companyName;
      await fetchData();
      await loadLanguage();
    } catch (e) {
      AppSnackbar.show('Lỗi', 'Không thể khởi tạo dữ liệu: $e');
    } finally {
      isLoading.value = false;
    }
  }


  var expandedIndex = (-1).obs;
  var isExpanded = false.obs;

  var items = <Map<String, dynamic>>[].obs;

  void toggleExpand(int index) {
    expandedIndex.value = (expandedIndex.value == index) ? -1 : index;
    isExpanded.value = !isExpanded.value;
  }

  Future<void> loadLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString(PrefsConstants.languageCode) ?? "en";
    updateLanguage(langCode);
  }

  void updateLanguage(String langCode) {
    switch (langCode) {
      case 'vi':
        Get.updateLocale(const Locale('vi'));
        break;
      case 'en':
        Get.updateLocale(const Locale('en'));
        break;
      case 'zh':
        Get.updateLocale(const Locale('zh'));
        break;
      case 'my':
        Get.updateLocale(const Locale('my'));
        break;
    }
    Get.updateLocale(Locale(langCode));
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final data = {"companyName": companyName ?? ""};
      final response = await ApiService(
        baseUrl,
      ).post('/phom/getInforPhomBinding', data);

      if (response.data["statusCode"] == 200) {
        print("data ${response.data["data"]}");
        items.value =
            (response.data["data"] as List).map((e) {
              final map = Map<String, dynamic>.from(e as Map);

              map.updateAll(
                (key, value) => value is String ? value.trim() : value,
              );

              if (map['details'] is List) {
                map['details'] =
                    (map['details'] as List).map((detail) {
                      final detailMap = Map<String, dynamic>.from(
                        detail as Map,
                      );
                      detailMap.updateAll((k, v) => v is String ? v.trim() : v);
                      return detailMap;
                    }).toList();
              }

              return map;
            }).toList();
      } else {
        AppSnackbar.show("Error", response.data["message"] ?? "Unknown error");
      }
    } catch (e) {
      AppSnackbar.show("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
