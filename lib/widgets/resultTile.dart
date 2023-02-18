import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultTile extends StatelessWidget {
  final String name;
  final String id;
  final String expression;
  final String result;
  final double textSize;
  final Color backgroundColor;
  final Color resultTextColor;
  final Color? nameTextColor;
  final void Function(String result) onResultTap;
  final void Function(String id) onNameTap;

  ResultTile(
      {required this.name,
      required this.expression,
      required this.result,
      required this.textSize,
      required this.backgroundColor,
      required this.resultTextColor,
      required this.onResultTap,
      this.nameTextColor,
      required this.onNameTap,
      required this.id});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = GoogleFonts.saira(
        fontSize: textSize, color: nameTextColor, fontWeight: FontWeight.w500);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => onNameTap(id),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Text(name,
                style: TextStyle(fontSize: textSize, color: resultTextColor)),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: textSize * 1.5,
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            child: SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Text(
                expression,
                style: GoogleFonts.saira(
                    fontSize: textSize * 1.2,
                    color: resultTextColor,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onResultTap(result),
          child: Container(
            height: textSize * 1.5,
            decoration: BoxDecoration(color: backgroundColor),
            child: Text(
              ' =  $result',
              style: GoogleFonts.saira(
                  fontSize: textSize * 1.2,
                  color: resultTextColor,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
