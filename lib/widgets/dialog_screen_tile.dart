import 'package:flutter/material.dart';

class DialogTile extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  const DialogTile(
      {required this.label,
      required this.value,
      required this.labelColor,
      required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: labelColor),
        ),
        Expanded(
          child: SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: TextStyle(color: valueColor),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
