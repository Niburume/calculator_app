import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalcButton extends StatelessWidget {
  final double buttonSize;
  final String symbol;
  final Function(String symbol) onPressed;
  final buttonColor;
  final textColor;

  CalcButton({
    required this.buttonSize,
    required this.symbol,
    required this.onPressed,
    required this.buttonColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 100),
      child: GestureDetector(
        onTap: () {
          onPressed(symbol);
        },
        child: Container(
          margin: EdgeInsets.all(2),
          width: buttonSize * 0.9,
          height: buttonSize * 0.6,
          decoration: BoxDecoration(
            color: buttonColor,
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                color: buttonColor,
                offset: Offset(2, 2),
                blurRadius: 5.0,
              ),
            ],
          ),
          child: Center(
              child: Text(
            symbol,
            style: GoogleFonts.chonburi(
                fontSize: buttonSize * 0.3,
                color: textColor,
                fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }
}
