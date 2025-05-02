import 'dart:convert';

import '../../../../../configs/prefs_contants.dart';
import '../../../../../data/pref/prefs.dart';
import '../../model/auth_model.dart';
import '../../model/user_model.dart';


class GetuserUseCase {
  final Prefs _prefs;

  GetuserUseCase(this._prefs);

  Future<UserModel?> getUser() async {
    final tokenJson = await _prefs.getObject(PrefsConstants.user);
    if (tokenJson.isEmpty) {
      return null;
    }
    return UserModel.fromJson(json.decode(tokenJson));
  }

  Future<AuthenticationModel?> getToken() async {
    final authJson = await _prefs.getObject(PrefsConstants.auth);
    if (authJson.isEmpty) {
      return null;
    }
    return AuthenticationModel.fromJson(json.decode(authJson));
  }

  Future<void> logout() async {
    await _prefs.logout();
  }
}