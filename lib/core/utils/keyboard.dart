import 'package:flutter/material.dart';

class KeyboardUtlis {
    static dimissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}