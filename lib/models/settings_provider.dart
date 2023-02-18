import 'package:flutter/material.dart';

class ColorTheme {
  Color background;
  Color clearButton;
  Color operationButton;
  Color equalButton;
  Color numberButton;
  Color helperButton;
  Color resultText;
  Color historyText;
  Color? errorColor;
  Color? detailsColor;

  ColorTheme(
      {required this.background,
      required this.clearButton,
      required this.operationButton,
      required this.equalButton,
      required this.numberButton,
      required this.helperButton,
      required this.resultText,
      required this.historyText,
      this.errorColor,
      this.detailsColor});
}

class UserTheme {
  final lightTheme = ColorTheme(
      background: Color.fromRGBO(254, 254, 254, 1.0),
      clearButton: Color.fromRGBO(250, 170, 36, 1.0),
      operationButton: Color.fromRGBO(217, 200, 226, 1),
      equalButton: Color.fromRGBO(124, 0, 217, 0.5),
      helperButton: Color.fromRGBO(244, 238, 222, 1),
      numberButton: Color.fromRGBO(243, 243, 243, 1.0),
      resultText: Color.fromRGBO(76, 87, 97, 1.0),
      historyText: Color.fromRGBO(76, 87, 97, 0.5),
      errorColor: Color.fromRGBO(152, 53, 57, 1),
      detailsColor: Colors.blueGrey[500]);

  final darkTheme = ColorTheme(
      background: Color.fromRGBO(60, 60, 60, 1.0),
      clearButton: Color.fromRGBO(250, 170, 36, 1.0),
      helperButton: Color.fromRGBO(60, 53, 46, 1),
      equalButton: Color.fromRGBO(124, 0, 217, 1),
      operationButton: Color.fromRGBO(57, 38, 75, 1),
      numberButton: Color.fromRGBO(44, 46, 49, 1.0),
      resultText: Colors.white,
      historyText: Color.fromRGBO(151, 159, 158, 0.5),
      errorColor: Color.fromRGBO(152, 53, 57, 1),
      detailsColor: Colors.blueGrey[500]);
}

class SettingsProvider extends ChangeNotifier {
  ColorTheme providerTheme = UserTheme().lightTheme;

  var isLightTheme = false;
  var decimals = 2;

  void switchTheme() {
    isLightTheme = !isLightTheme;
    isLightTheme
        ? providerTheme = UserTheme().darkTheme
        : providerTheme = UserTheme().lightTheme;
    notifyListeners();
  }

  void increaseDecimals() {
    decimals >= 6 ? decimals = 6 : decimals += 1;
    notifyListeners();
  }

  void decreaseDecimals() {
    decimals <= 1 ? decimals = 1 : decimals -= 1;
    notifyListeners();
  }
}
