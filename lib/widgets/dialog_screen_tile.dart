import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings_provider.dart';

class DialogTile extends StatelessWidget {
  final String label;
  final String value;

  const DialogTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<SettingsProvider>(context, listen: false).providerTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.historyText),
        ),
        Expanded(
          child: SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: TextStyle(color: theme.resultText),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
