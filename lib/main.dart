import 'package:calculator_app/Screens/settings_screen.dart';
import 'package:calculator_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Screens/main_screen.dart';
import 'models/settings_provider.dart';

void main() {
  ColorTheme theme;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<Results>(create: (_) => Results())
      ],
      child:
          Consumer<SettingsProvider>(builder: (context, themeProvider, child) {
        ColorTheme theme = Provider.of<SettingsProvider>(context).providerTheme;
        return MaterialApp(
          theme: ThemeData(
              backgroundColor: theme.background,
              canvasColor: theme.background,
              textTheme: TextTheme(
                  bodyText2: TextStyle(color: theme.resultText),
                  bodyText1: TextStyle(color: theme.resultText)),
              appBarTheme: AppBarTheme(
                backgroundColor: theme.background,
                iconTheme: IconThemeData(color: theme.equalButton),
              ),
              fontFamily: 'Saira'),
          initialRoute: '/',
          routes: {
            //TODO login is the first screen should be here

            '/': (context) => CalculatorApp(),
            // AddPlaceScreen.routeName: (ctx) => AddPlaceScreen(),

            SettingsScreen.routeName: (context) => SettingsScreen(),
          },
        );
      }),
    ),
  );
}
