import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';

import 'app_binding.dart';
import 'core/configs/app_colors.dart';
import 'core/lang/translation_service.dart';
import 'core/routes/pages.dart';
import 'core/utils/behavior.dart';

class App extends StatelessWidget {
  const App({super.key});

  Future<Locale> _getSavedLocale() async {
    String? savedLanguage = await Prefs.preferences.getLanguage();
    return Locale(savedLanguage ?? 'vi');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Locale>(
      future: _getSavedLocale(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // Hiển thị loading khi đang lấy dữ liệu
        }

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: Pages.initial,
          scrollBehavior: MyBehavior(),
          getPages: Pages.routes,
          initialBinding: AppBinding(),
          theme: ThemeData(
            appBarTheme: const AppBarTheme(backgroundColor: AppColors.white),
            scaffoldBackgroundColor: AppColors.white,
          ),
          translations: TranslationService(),
          locale: snapshot.data, // Dữ liệu từ FutureBuilder
          fallbackLocale: const Locale('vi'),
        );
      },
    );
  }
}
