import 'package:flutter/material.dart';
import 'app.config.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await appConfig();
  await dotenv.load(fileName: ".env");
  runApp(const App());
}
