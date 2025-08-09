import 'dart:ui';
import 'package:get/get.dart';
import 'en.dart';
import 'vi.dart';
import 'zh.dart';
import 'my.dart';

class TranslationService extends Translations {
  static final locale = Get.deviceLocale;
  static const fallbackLocale = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
    'en': en,
    'vi': vi,
    'zh': zh,
    'my': my,
  };
}
