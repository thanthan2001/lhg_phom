import 'package:flutter/material.dart';
import 'app.config.dart';
import 'app.dart';

void main() async {
  await appConfig();
  runApp(const App());
}
