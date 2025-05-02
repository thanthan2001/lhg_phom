import 'package:lhg_phom/core/configs/prefs_contants.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/models/user/model/auth_model.dart';

import '../../model/user_model.dart';

class SaveUserUseCase {
  final Prefs _prefs;

  SaveUserUseCase(this._prefs);

  Future saveUser(UserModel user) async {
    await _prefs.set(PrefsConstants.user, user);
  }

  Future userSave(UserModel user) async {
    await _prefs.set(PrefsConstants.user, user);
  }

  Future saveToken(AuthenticationModel auth) async {
    await _prefs.set(PrefsConstants.auth, auth);
  }
}
