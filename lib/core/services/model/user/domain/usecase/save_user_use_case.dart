import 'package:lhg_phom/core/configs/prefs_contants.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/model/user/models/auth_model.dart';
import 'package:lhg_phom/core/services/model/user/models/user_model.dart';

import '../../models/user.dart';

class SaveUserUseCase {
  final Prefs _prefs;

  SaveUserUseCase(this._prefs);

  Future saveUser(UserModel user) async {
    await _prefs.set(PrefsConstants.user, user);
  }

  Future userSave(User user) async {
    await _prefs.set(PrefsConstants.user, user);
  }

  Future saveToken(AuthenticationModel auth) async {
    await _prefs.set(PrefsConstants.auth, auth);
  }
}
