import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../configs/prefs_contants.dart';

class Prefs {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static final Prefs preferences = Prefs();

  Future<String> get(String key) async {
    final SharedPreferences prefs = await _prefs;
    return json.decode(prefs.getString(key)!) ?? '';
  }

  Future<String> getObject(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key) ?? '';
  }

  Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(key);
  }

  Future<int> getInt(String key) async {
    final SharedPreferences prefs = await _prefs;
    final int? value = prefs.getInt(key);
    return value ?? 0;
  }

  Future set(String key, dynamic value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(key, json.encode(value));
  }

  Future setBool(String key, value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(key, value);
  }

  Future setInt(String key, value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(key, value);
  }

  Future remove(String key) async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove(key);
  }

  Future clear() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }

  Future logout() async {
    final SharedPreferences prefs = await _prefs;
    prefs.getKeys().forEach((key) {});

    prefs.clear();

    prefs.getKeys().forEach((key) {});
  }

  Future<void> setLanguage(String languageCode) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(PrefsConstants.languageCode, languageCode);
  }

  Future<String?> getLanguage() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(PrefsConstants.languageCode);
  }
}
