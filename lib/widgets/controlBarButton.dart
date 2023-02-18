import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ControlBarButton extends StatelessWidget {
  final double buttonSize;
  final Color buttonColor;
  final Color textColor;
  final String symbol;
  final bool isWheelSelected;
  Function(String symbol) onPressed;
  ControlBarButton(
      {required this.buttonSize,
      required this.buttonColor,
      required this.textColor,
      required this.symbol,
      required this.isWheelSelected,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: buttonSize * 0.4,
      width: isWheelSelected ? 0 : buttonSize * 0.4,
      decoration: BoxDecoration(
          color: buttonColor, borderRadius: BorderRadius.circular(20)),
      child: TextButton(
        onPressed: () {
          onPressed(symbol);
        },
        child: Text(
          symbol,
          style: TextStyle(fontSize: buttonSize * 0.15, color: textColor),
        ),
      ),
    );
  }
}
//\u{232B}
