import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:calculator_app/Screens/settings_screen.dart';
import 'package:calculator_app/widgets/controlBarButton.dart';
import 'package:calculator_app/widgets/number_button.dart';
import 'package:calculator_app/widgets/resultTile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:function_tree/function_tree.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/result_model.dart';
import '../models/settings_provider.dart';
import '../widgets/dialog_screen_tile.dart';

//TODO add formuls before textfield for expressions

class CalculatorApp extends StatefulWidget {
  CalculatorApp({Key? key}) : super(key: key);

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  int cursorPosition = 0;
  double textFieldFontSize = 0;
  bool wheelIsSelected = false;
  double referenceDx = 0;
  double widthOfScreen = 0;
  double buttonSize = 0;
  String resultString = '';
  double resultDouble = 0.0;
  Results calcResults = Results();
  bool totalIsWrong = false;
  int decimals = 2;
  String resultPlaceHolder = '... ...';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void buttonPressed(String symbol) {
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
      calcResults.addResult(ResultModel(
          id: DateTime.now().toString(),
          dateStamp: DateTime.now(),
          expression: _textEditingController.text,
          result: resultDouble));
      setState(() {});
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
    addSymbolToCursorPosition(symbol);

    calculateTotal(_textEditingController.text);
    setState(() {});
  }

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

  // region MOVE CURSOR
  void moveCursor(double newPositionX) {
    int textLength = _textEditingController.text.length;
    double speedScrolling = 1 / textLength.toDouble() * 100;
    speedScrolling < 4 ? speedScrolling = 0 : 1 / textLength.toDouble() * 100;
    print(speedScrolling);
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

  // region ResultText Methods
  void onResultTap(String result) {
    print('tapped: $result');
    addSymbolToCursorPosition(result);
    calculateTotal(_textEditingController.text);

    setState(() {});
  }

  void onNameTap(String id) {
    bool isNameNull = false;
    final TextEditingController nameControllerTextField =
        TextEditingController();
    final TextEditingController noteControllerTextField =
        TextEditingController();
    final theme =
        Provider.of<SettingsProvider>(context, listen: false).providerTheme;
    final resultModel =
        Provider.of<Results>(context, listen: false).fetchResultModelById(id);
    isNameNull = resultModel.name == null ? true : false;

    // region SHOW DIALOG
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: theme.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)), //this right here
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxHeight: 400),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DialogTile(
                        label: 'Date:',
                        value: DateFormat.yMd()
                            .add_jm()
                            .format(resultModel.dateStamp)
                            .toString(),
                        labelColor: theme.historyText,
                        valueColor: theme.resultText,
                      ),
                      DialogTile(
                        label: 'Adress:',
                        value: 'Lillhagsvägen 8, 124 71 Bandhagen',
                        labelColor: theme.historyText,
                        valueColor: theme.resultText,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Name: ',
                            style: TextStyle(color: theme.historyText),
                          ),
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: theme.resultText),
                              controller: nameControllerTextField,
                              textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: resultModel.name == null
                                          ? theme.historyText
                                          : theme.resultText),
                                  border: InputBorder.none,
                                  hintText: resultModel.name ??
                                      'type a name here...'),
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      DialogTile(
                        label: 'Expression:',
                        value: resultModel.expression,
                        labelColor: theme.historyText,
                        valueColor: theme.resultText,
                      ),
                      DialogTile(
                        label: 'RESULT:',
                        value: resultModel.result.toString(),
                        labelColor: theme.historyText,
                        valueColor: theme.resultText,
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme.historyText,
                          border: Border.all(color: theme.historyText),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: TextField(
                            style: TextStyle(color: theme.resultText),
                            maxLines: 3,
                            controller: noteControllerTextField,
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: resultModel.note == null
                                        ? theme.historyText
                                        : theme.resultText),
                                border: InputBorder.none,
                                hintText:
                                    resultModel.note ?? 'type a note here...'),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.resultText,
                                backgroundColor:
                                    theme.clearButton, // foreground
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.resultText,
                                backgroundColor:
                                    theme.operationButton, // foreground
                              ),
                              onPressed: () {
                                if (nameControllerTextField.text.isNotEmpty) {
                                  Provider.of<Results>(context, listen: false)
                                      .changeNameById(resultModel.id,
                                          nameControllerTextField.text);
                                }
                                if (noteControllerTextField.text.isNotEmpty) {
                                  if (noteControllerTextField.text.isNotEmpty) {
                                    Provider.of<Results>(context, listen: false)
                                        .changeNoteById(resultModel.id,
                                            noteControllerTextField.text);
                                  }
                                }
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Save'),
                            ),
                          )
                        ],
                      )
                      // SizedBox(
                      //   width: 320.0,
                      //   child: TextButton(
                      //     onPressed: () {
                      //       Provider.of<Results>(context, listen: false)
                      //           .changeNameById(
                      //               id, nameControllerTextField.text);
                      //       Navigator.pop(context);
                      //     },
                      //     child: Text(
                      //       "Save",
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
    print('nameTapped');
    // endregion
  }

  String removeZeros(double value) {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return value.toStringAsFixed(decimals).replaceAll(regex, '');
  }

  // endregion

  @override
  void didChangeDependencies() {
    setState(() {
      widthOfScreen = MediaQuery.of(context).size.width;
      buttonSize = (widthOfScreen - 15 * 2) / 4;
      textFieldFontSize = buttonSize / 2.5;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  //MARK: ======== BUILD METHOD ========

  @override
  Widget build(BuildContext context) {
    ColorTheme theme =
        Provider.of<SettingsProvider>(context, listen: true).providerTheme;
    bool isLightTheme =
        Provider.of<SettingsProvider>(context, listen: true).isLightTheme;
    decimals = Provider.of<SettingsProvider>(context, listen: true).decimals;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35.0),
        child: AppBar(
          title: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: AnimatedTextKit(
                key: ValueKey<bool>(isLightTheme),
                pause: Duration(milliseconds: 1000),
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
            margin: EdgeInsets.all(0),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: theme.equalButton,
              ),
              onPressed: () {
                Navigator.pushNamed(context, SettingsScreen.routeName)
                    .then((_) => setState(() {
                          print('setted');
                        }));
              },
            ),
          ),
        ),
      ),
      backgroundColor: theme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                // margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: theme.background),
                          child: ListView.builder(
                              padding: EdgeInsets.only(bottom: 10),
                              reverse: true,
                              itemCount: calcResults.resultModels.length,
                              itemBuilder: (context, index) {
                                var i =
                                    calcResults.resultModels.length - index - 1;
                                return ResultTile(
                                  id: calcResults.resultModels[i].id,
                                  name: calcResults.resultModels[i].name == null
                                      ? '...'
                                      : calcResults.resultModels[i].name!,
                                  expression:
                                      calcResults.resultModels[i].expression,
                                  result: calcResults.resultModels[i].result
                                      .toStringAsFixed(decimals),
                                  textSize: textFieldFontSize * 0.4,
                                  backgroundColor: theme.background,
                                  resultTextColor: theme.historyText,
                                  onResultTap: onResultTap,
                                  nameTextColor:
                                      calcResults.resultModels[i].name == null
                                          ? theme.resultText
                                          : null,
                                  onNameTap: onNameTap,
                                );
                              }),
                        ),
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
                                          speed:
                                              const Duration(milliseconds: 150),
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
                      ),
                      const Divider(
                        height: 1,
                        thickness: 2,
                      )
                    ]),
                // height: height * 0.4,
              ),
            ),
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
                        child: Center(child: Text('<>')),
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
                    ControlBarButton(
                      buttonSize: !wheelIsSelected ? buttonSize : 0,
                      buttonColor: theme.operationButton,
                      textColor: theme.resultText,
                      symbol: '\u{232B}',
                      isWheelSelected: wheelIsSelected,
                      onPressed: buttonPressed,
                    ),
                  ],
                )),
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
                          symbol: "?",
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
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
