import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:calculator_app/models/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings_screen';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final double buttonHeight = 30;

  @override
  Widget build(BuildContext context) {
    var isLightTheme =
        Provider.of<SettingsProvider>(context, listen: true).isLightTheme;
    ColorTheme theme =
        Provider.of<SettingsProvider>(context, listen: true).providerTheme;
    var decimals =
        Provider.of<SettingsProvider>(context, listen: true).decimals;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35.0),
        child: AppBar(
          leading: Container(
            width: 20,
            margin: EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          centerTitle: true,
          actions: [
            Icon(Icons.logout),
            SizedBox(
              width: 15,
            )
          ],
          title: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: AnimatedTextKit(
              key: ValueKey<bool>(isLightTheme),
              pause: Duration(milliseconds: 1000),
              totalRepeatCount: 1,
              animatedTexts: [
                RotateAnimatedText(
                  'Settings',
                  rotateOut: false,
                  textStyle: TextStyle(color: theme.resultText),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Container(
                      height: buttonHeight,
                      // width: double.infinity,
                      child: Text('Decimals')),
                  Expanded(child: Container()),
                  Container(
                    width: buttonHeight,
                    height: buttonHeight,
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<SettingsProvider>(context, listen: false)
                            .decreaseDecimals();
                      },
                      child: DetailText(
                          text: '  -  ',
                          textSize: 20,
                          textColor: theme.resultText),
                    ),
                  ),
                  Container(
                    width: buttonHeight * 2,
                    height: buttonHeight,
                    child: Center(
                      child: DetailText(
                          text: '$decimals',
                          textSize: 20,
                          textColor: theme.resultText),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Provider.of<SettingsProvider>(context, listen: false)
                          .increaseDecimals();
                    },
                    child: Container(
                      width: buttonHeight,
                      height: buttonHeight,
                      child: DetailText(
                          text: '  +  ',
                          textSize: 20,
                          textColor: theme.resultText),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 50,
              thickness: 1,
              color: theme.detailsColor,
              indent: 10,
              endIndent: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Theme'),
                  Row(
                    children: [
                      Container(
                        height: buttonHeight,
                        width: buttonHeight,
                        child: Icon(
                          Icons.wb_sunny_outlined,
                          color: theme.resultText,
                        ),
                      ),
                      Container(
                        height: buttonHeight,
                        width: buttonHeight * 2,
                        child: Center(
                          child: Switch(
                              value: isLightTheme,
                              activeColor: theme.detailsColor,
                              onChanged: (value) {
                                Provider.of<SettingsProvider>(context,
                                        listen: false)
                                    .switchTheme();
                                setState(() {});
                              }),
                        ),
                      ),
                      Container(
                        height: buttonHeight,
                        width: buttonHeight,
                        child: Icon(
                          Icons.dark_mode_outlined,
                          color: theme.resultText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DetailText extends StatelessWidget {
  String text;
  double textSize;
  Color textColor;

  DetailText(
      {required this.text, required this.textSize, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: textSize,
        color: textColor,
      ),
    );
  }
}
