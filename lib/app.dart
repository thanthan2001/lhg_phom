import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'app_binding.dart';
import 'core/configs/app_colors.dart';
import 'core/lang/translation_service.dart';
import 'core/routes/pages.dart';
import 'core/utils/behavior.dart';
import 'core/utils/app_snackbar.dart';

class App extends StatelessWidget {
  const App({super.key});

  Future<Locale> _getSavedLocale() async {
    String? savedLanguage = await Prefs.preferences.getLanguage();
    return Locale(savedLanguage ?? 'en');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Locale>(
      future: _getSavedLocale(),
      builder: (context, snapshot) {
        final locale = snapshot.data ?? const Locale('en');
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: Pages.initial,
          scrollBehavior: MyBehavior(),
          getPages: Pages.routes,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          initialBinding: AppBinding(),
          theme: ThemeData(
            appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary),
            scaffoldBackgroundColor: AppColors.white,
          ),
          translations: TranslationService(),
          locale: locale,
          fallbackLocale: const Locale('en'),
        );
      },
    );
  }
}
