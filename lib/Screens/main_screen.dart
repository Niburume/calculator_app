import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:calculator_app/Screens/search_screen.dart';
import 'package:calculator_app/Screens/settings_screen.dart';
import 'package:calculator_app/helpers/db_helper.dart';
import 'package:calculator_app/widgets/controlBarButton.dart';
import 'package:calculator_app/widgets/number_button.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helpers/geolocation.dart';
import '../models/models.dart';
import '../models/settings_provider.dart';

import '../widgets/dialogs.dart';
import '../widgets/resultTile.dart';

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp>
    with WidgetsBindingObserver {
  // region Initials
  GeoLocation geoLocation = GeoLocation();
  int cursorPosition = 0;
  double textFieldFontSize = 0;
  bool wheelIsSelected = false;
  double referenceDx = 0;
  double widthOfScreen = 0;
  double heightOfScreen = 0;
  double buttonSize = 0;
  double appBarHeight = 35;
  String resultString = '';
  double resultDouble = 0.0;

  List<SessionModel> _listOfSessions = [];
  Map<int, List<ResultModel>?> _resultsBySessionId = {};

  bool totalIsWrong = false;
  int decimals = 2;
  final String resultPlaceHolder = '... ...';
  var sessionIsValid = false;

  int? currentSessionId;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _resultsController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  // endregion
  // region BUTTON PRESSED
  Future<void> buttonPressed(String symbol) async {
    // region ON 'AC'
    if (symbol == 'AC') {
      _textEditingController.clear();
      cursorPosition = 0;
      resultString = '';
      setState(() {});
      return;
    }
    // endregion
    //region ON BACKSPACE
    else if (symbol == '\u{232B}') {
      if (_textEditingController.text.isEmpty) {
        return;
      }

      _textEditingController.text = _textEditingController.text
              .substring(0, cursorPosition - 1) +
          _textEditingController.text
              .substring(cursorPosition, _textEditingController.text.length);
      cursorPosition -= 1;
      _textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      );

      setState(() {
        calculateTotal(_textEditingController.text);
      });
      return;
    } //endregion

    //region SQRT of
    else if (symbol == '\u{221A}') {
      symbol = '\u{221A}()';
      addSymbolToCursorPosition(symbol, offSetCursor: -1);
      return;
    }
    // endregion
    //region on '=' mark
    else if (symbol == '=') {
      calculateTotal(_textEditingController.text);
      if (resultString == resultPlaceHolder) {
        setState(() {
          resultString = 'wrong expression';
          totalIsWrong = true;
        });
        return;
      }

      addResult();

      setState(() {
        _resultsController.animateTo(
            _resultsController.position.minScrollExtent,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.linear);
      });
      buttonPressed('AC');

      return;
    }
// endregion
    // region On '('
    if (symbol == '(') {
      symbol = '()';
      addSymbolToCursorPosition(symbol, offSetCursor: -1);
      return;
    }
    // endregion
    // region On G pressed
    if (symbol == 'G') {
      updateUI();
    }
    // endregion
    //region on '?' Mark
    if (symbol == '?') {
      currentSessionId = await DBHelper.instance.insertSession({
        DBHelper.sessionName: 'first session',
        DBHelper.dateStampSession: DateTime.now().toIso8601String(),
      });
    }
    // endregion
    // region on 'M+' Mark
    if (symbol == 'M+') {
      await DBHelper.instance
          .queryMapOfResultsBySessionIds([currentSessionId!]);
    }
    // endregion
    addSymbolToCursorPosition(symbol);

    calculateTotal(_textEditingController.text);
    setState(() {});
  }

  // endregion
  // region CATCH POSITION

  void setCurrentPosition(int sessionId) async {
    BuildContext oldContext = context;
    Map<String, dynamic> geoData = await geoLocation.getCurrentPosition();

    Provider.of<Results>(oldContext, listen: false).updateSession(
        currentSessionId!,
        null,
        geoData['address'],
        geoData['address'],
        geoData['latitude'],
        geoData['longitude']);

    setState(() {});
  }
  // endregion

  // region ADD SYMBOL TO CURSOR POSITION
  void addSymbolToCursorPosition(String value, {int offSetCursor = 0}) {
    _focusNode.requestFocus();
    _textEditingController.text =
        _textEditingController.text.substring(0, cursorPosition) +
            value +
            _textEditingController.text
                .substring(cursorPosition, _textEditingController.text.length);

    cursorPosition += value.length + offSetCursor;

    _scrollController.position.maxScrollExtent > 0 &&
            cursorPosition == _textEditingController.text.length
        ? _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent +
                textFieldFontSize * 0.7,
          )
        : null;
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition),
    );
  }

// endregion

  // region CALCULATE TOTAL
  void calculateTotal(String expression) {
    expression = expression.replaceAll(RegExp('×'), '*');
    expression = expression.replaceAll(RegExp('\u{00F7}'), '/');
    //  region Divide with ZERO error
    if (expression.contains('/0+') ||
        expression.contains('/0-') ||
        expression.contains('/0*') ||
        expression.contains('/0/')) {
      resultString = '\u{221E}';
      return;
    }
    // endregion
    List<String> letters = expression.split('');
    Map<int, String> mapExpression = letters.asMap();
    String newExpression = '';
    mapExpression.forEach((index, value) {
      //region Replace square root symbol
      if (value == '\u{221A}') {
        value = 'sqrt';
      }
      //endregion
      //region Convert procent symbol
      if (value == '%') {
        var numb = '';
        var i = index - 1;
        String sign = '';
        for (i; i != 0; i--) {
          var exp = mapExpression[i];
          if (exp == '+' || exp == '-' || exp == '*' || exp == '/') {
            exp == '+' ? sign = '+' : '';
            exp == '-' ? sign = '-' : '';
            exp == '/' ? sign = '/' : '';
            exp == '*' ? sign = '*' : '';
            break;
          } else {
            numb += exp!;
          }
        }
        // reverse the number before '%'
        numb = numb.split('').reversed.join();
        switch (sign) {
          case '+':
            value = '*($numb/100+1)';

            break;

          case '-':
            value = '*(1-$numb/100)';
            break;

          case '/':
            value = '*($numb)';
            break;

          case '*':
            value = '/($numb)';
            break;
        }

        newExpression = newExpression.substring(
            0, newExpression.length - (numb.length + 1));
      }
      newExpression += value;
      // endregion
    });
    try {
      if (newExpression.interpret().toString() == 'Infinity') {
        resultString = '\u{221E}';
      } else {
        setState(() {
          resultDouble = newExpression.interpret().toDouble();
          resultString = newExpression.interpret().toString();

          totalIsWrong = false;
        });
      }
    } catch (e) {
      resultString = resultPlaceHolder;
    }
  }

// endregion
  // region removeZeros
  String removeZeros(double value) {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return value.toStringAsFixed(decimals).replaceAll(regex, '');
  }

// endregion
  // region MOVE CURSOR
  void moveCursor(double newPositionX) {
    int textLength = _textEditingController.text.length;
    double speedScrolling = 1 / textLength.toDouble() * 100;
    speedScrolling < 4 ? speedScrolling = 0 : 1 / textLength.toDouble() * 100;

    if (newPositionX + speedScrolling < referenceDx && cursorPosition != 0) {
      cursorPosition -= 1;
      referenceDx = newPositionX;
      _textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      );
      return;
    } else if (newPositionX - speedScrolling > referenceDx &&
        cursorPosition != textLength) {
      cursorPosition += 1;
      referenceDx = newPositionX;
      _textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      );
      return;
    } else if ((newPositionX - referenceDx).abs() > speedScrolling) {
      referenceDx = newPositionX;
      return;
    }
  }
  // endregion

  Future<int?> createSession() async {
    int? currentId =
        await Provider.of<Results>(context, listen: false).createSession();
    setCurrentPosition(currentId!);
    return currentId;
  }

  void getHistory() async {
    bool historyIsLoaded =
        await Provider.of<Results>(context, listen: false).getHistory();
    if (historyIsLoaded) {
      int? currentId = await createSession();
      sessionIsValid = true;
      currentSessionId = currentId;
      setState(() {});
    }
  }

  // region ResultText Methods
  void onResultTap(String result) {
    addSymbolToCursorPosition(result);
    calculateTotal(_textEditingController.text);

    setState(() {});
  }

  // endregion

  // region Dialog Function
  void updateUI() {
    setState(() {});
  }

// region ADD RESULT
  void addResult() async {
    String? address;
    SessionModel currentSession =
        _listOfSessions.firstWhere((element) => element.id == currentSessionId);
    if (currentSession.address != null) address = currentSession.address;
    await Provider.of<Results>(context, listen: false)
        .addResult(_textEditingController.text, resultDouble, address,
            currentSessionId!)
        .then((value) => setState(() {}));
  }

// endregion
  void _scaleDialog(int currentSessionId, int? expressionId, bool isSession) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: RenameDialog(
              context: context,
              isSession: isSession,
              currentSessionId: currentSessionId,
              expressionId: expressionId,
              callback: updateUI),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  // endregion

  @override
  void didChangeDependencies() {
    setState(() {
      widthOfScreen = MediaQuery.of(context).size.width;
      heightOfScreen = MediaQuery.of(context).size.height;
      buttonSize = (widthOfScreen - 15 * 2) / 4;
      textFieldFontSize = buttonSize / 2.5;
    });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    geoLocation.determinePosition();
    super.initState();
    sessionIsValid = false;
    getHistory();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!sessionIsValid) {
        print('resumed');
        getHistory();
      }
    } else if (state == AppLifecycleState.paused) {
      Timer(const Duration(minutes: 60), () {
        sessionIsValid = false;
        currentSessionId = null;
        print('paused');
        // Reverse the boolean value
      });
    }
  }

  //MARK: ======== BUILD METHOD ========

  @override
  Widget build(BuildContext context) {
    ColorTheme theme =
        Provider.of<SettingsProvider>(context, listen: true).providerTheme;
    bool isLightTheme =
        Provider.of<SettingsProvider>(context, listen: true).isLightTheme;

    _listOfSessions = Provider.of<Results>(context, listen: true).sessionModels;
    _resultsBySessionId = Provider.of<Results>(context, listen: true).results;

    decimals = Provider.of<SettingsProvider>(context, listen: true).decimals;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          title: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: AnimatedTextKit(
                key: ValueKey<bool>(isLightTheme),
                pause: const Duration(milliseconds: 1000),
                totalRepeatCount: 1,
                animatedTexts: [
                  RotateAnimatedText(
                    'Calculate it',
                    rotateOut: false,
                    textStyle: isLightTheme
                        ? TextStyle(color: theme.resultText)
                        : TextStyle(color: theme.resultText),
                  ),
                ],
              )),
          leading: Container(
            margin: const EdgeInsets.all(0),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: theme.equalButton,
              ),
              onPressed: () {
                Navigator.pushNamed(context, SettingsScreen.routeName)
                    .then((_) => setState(() {}));
              },
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, SearchScreen.routeName);
                },
                icon: const Icon(Icons.search))
          ],
        ),
      ),
      backgroundColor: theme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView(shrinkWrap: true, reverse: true, children: [
                ListView.builder(
                  controller: _resultsController,
                  itemCount: _listOfSessions.length,
                  reverse: true,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (BuildContext context, int sessionIndex) {
                    int sessionId = _listOfSessions[sessionIndex].id;

                    return Column(
                      children: [
                        !sessionIsValid
                            ? Column(
                                children: [
                                  const Text('Loading history...'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CircularProgressIndicator(
                                    color: theme.equalButton,
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _scaleDialog(sessionId, null, true);
                                    },
                                    child: SizedBox(
                                      height: 15,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${_listOfSessions[sessionIndex].sessionName} $sessionIndex',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: theme.historyText,
                                              fontFamily: 'ShareTech'),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: Text(
                                        DateFormat('yyyy/MM/dd HH:mm')
                                            .format(
                                                _listOfSessions[sessionIndex]
                                                    .dateStamp)
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: theme.historyText,
                                            fontFamily: 'ShareTech'),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                        const Divider(
                          height: 1,
                          thickness: 2,
                        ),
                        // const Divider(),
                        Container(
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(bottom: 10),
                              reverse: true,
                              itemCount:
                                  _resultsBySessionId[sessionId]?.length ?? 0,
                              itemBuilder: (context, index) {
                                var i = _resultsBySessionId[sessionId]!.length -
                                    index -
                                    1;
                                List<ResultModel> results =
                                    _resultsBySessionId[sessionId] ?? [];
                                return ResultTile(
                                  sessionId: sessionId,
                                  expressionId: results[i].id,
                                  name: results[i].name == null
                                      ? '...'
                                      : results[i].name!,
                                  expression: results[i].expression ?? '',
                                  result: results[i]
                                          .result
                                          .toStringAsFixed(decimals) ??
                                      '',
                                  textSize: textFieldFontSize * 0.4,
                                  backgroundColor: theme.background,
                                  resultTextColor: theme.historyText,
                                  onResultTap: onResultTap,
                                  nameTextColor: results[i].name == null
                                      ? theme.resultText
                                      : null,
                                  onNameTap: _scaleDialog,
                                );
                              }),
                        )
                      ],
                    );
                  },
                ),
              ]),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:',
                    style: GoogleFonts.saira(
                        color: theme.resultText,
                        fontSize: buttonSize * 0.2,
                        fontWeight: FontWeight.w500)),
                resultString == resultPlaceHolder ||
                        resultString == 'wrong expression'
                    ? DefaultTextStyle(
                        style: GoogleFonts.saira(
                            color: totalIsWrong
                                ? theme.errorColor
                                : theme.resultText,
                            fontSize: buttonSize * 0.2,
                            fontWeight: FontWeight.w500),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(resultString,
                                speed: const Duration(milliseconds: 150),
                                cursor: '|'),
                          ],
                          repeatForever: true,
                        ),
                      )
                    : Text(resultString,
                        style: GoogleFonts.saira(
                            color: theme.resultText,
                            fontSize: buttonSize * 0.2,
                            fontWeight: FontWeight.w500)),
              ],
            ), // region Expression
            TextField(
              style: GoogleFonts.saira(
                  fontSize: textFieldFontSize,
                  color: theme.resultText,
                  fontWeight: FontWeight.w500),
              keyboardType: TextInputType.none,
              decoration: null,
              cursorColor: theme.resultText,
              cursorHeight: textFieldFontSize,
              controller: _textEditingController,
              scrollController: _scrollController,
              focusNode: _focusNode,
              textAlign: TextAlign.end,
            ),
            // endregion

            //region ControlBar
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ControlBarButton(
                      buttonSize: !wheelIsSelected ? buttonSize : 0,
                      buttonColor: theme.operationButton,
                      textColor: theme.resultText,
                      symbol: 'G',
                      isWheelSelected: wheelIsSelected,
                      onPressed: buttonPressed,
                    ),
                    ControlBarButton(
                      buttonSize: !wheelIsSelected ? buttonSize : 0,
                      buttonColor: theme.operationButton,
                      textColor: theme.resultText,
                      symbol: 'M+',
                      isWheelSelected: wheelIsSelected,
                      onPressed: buttonPressed,
                    ),
                    ControlBarButton(
                      buttonSize: !wheelIsSelected ? buttonSize : 0,
                      buttonColor: theme.operationButton,
                      textColor: theme.resultText,
                      symbol: 'M-',
                      isWheelSelected: wheelIsSelected,
                      onPressed: buttonPressed,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          cursorPosition = _textEditingController.text.length;
                          _textEditingController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: cursorPosition),
                          );
                        });
                      },
                      onHorizontalDragStart: (DragStartDetails details) {
                        setState(() {
                          if (_textEditingController.text.isEmpty) {
                            return;
                          }
                          _focusNode.requestFocus();

                          // cursorPosition = _textEditingController.text.length;
                          _textEditingController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: cursorPosition),
                          );
                          referenceDx = widthOfScreen / 2;
                          wheelIsSelected = !wheelIsSelected;
                        });
                      },
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        moveCursor(details.globalPosition.dx);
                      },
                      onHorizontalDragEnd: (detail) {
                        setState(() {
                          wheelIsSelected = false;
                        });
                      },
                      child: AnimatedContainer(
                        width: !wheelIsSelected
                            ? widthOfScreen / 8
                            : widthOfScreen * 0.6,
                        height: 50,
                        decoration: BoxDecoration(
                            color: theme.operationButton,
                            borderRadius: BorderRadius.circular(20)),
                        duration: const Duration(milliseconds: 100),
                        child: const Center(child: Text('<>')),
                      ),
                    ),
                    ControlBarButton(
                      buttonSize: !wheelIsSelected ? buttonSize : 1,
                      buttonColor: theme.operationButton,
                      textColor: theme.resultText,
                      symbol: '(',
                      isWheelSelected: wheelIsSelected,
                      onPressed: buttonPressed,
                    ),
                    ControlBarButton(
                      buttonSize: !wheelIsSelected ? buttonSize : 0,
                      buttonColor: theme.operationButton,
                      textColor: theme.resultText,
                      symbol: ')',
                      isWheelSelected: wheelIsSelected,
                      onPressed: buttonPressed,
                    ),
                  ],
                )),
            // endregion
            // region CalcButtons
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "AC",
                          onPressed: buttonPressed,
                          buttonColor: theme.clearButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "\u{221A}",
                          onPressed: buttonPressed,
                          buttonColor: theme.helperButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "%",
                          onPressed: buttonPressed,
                          buttonColor: theme.helperButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "\u{00F7}",
                          onPressed: buttonPressed,
                          buttonColor: theme.operationButton,
                          textColor: theme.resultText),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "1",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "2",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "3",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "×",
                          onPressed: buttonPressed,
                          buttonColor: theme.operationButton,
                          textColor: theme.resultText),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "4",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "5",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "6",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "-",
                          onPressed: buttonPressed,
                          buttonColor: theme.operationButton,
                          textColor: theme.resultText),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "7",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "8",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "9",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "+",
                          onPressed: buttonPressed,
                          buttonColor: theme.operationButton,
                          textColor: theme.resultText),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "0",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: ".",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "\u{232B}",
                          onPressed: buttonPressed,
                          buttonColor: theme.numberButton,
                          textColor: theme.resultText),
                      CalcButton(
                          buttonSize: buttonSize,
                          symbol: "=",
                          onPressed: buttonPressed,
                          buttonColor: theme.operationButton,
                          textColor: theme.resultText),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            )
            // endregion
          ],
        ),
      ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
}
