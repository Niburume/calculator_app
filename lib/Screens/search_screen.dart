import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:calculator_app/models/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../widgets/dialogs.dart';
import '../widgets/resultTile.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = 'search_screen';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final double buttonHeight = 30;

  var isFilterOn = false;

  List<SessionModel> _listOfSessions = [];
  List<SessionModel> _filteredListOfSessions = [];
  Map<int, List<ResultModel>?> _resultsBySessionId = {};
  Map<int, List<ResultModel>?> _filteredResultsBySessionId = {};

  final ScrollController _scrollController = ScrollController();
  final ScrollController _resultsController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

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

  void onResultTap(String result) {
    // addSymbolToCursorPosition(result);
    // calculateTotal(_textEditingController.text);

    setState(() {});
  }

  void filterValues(String searchText) {
    // print(searchText);
    _filteredListOfSessions = [];
    for (var session in _listOfSessions) {
      if (session.address != null &&
              session.address!.toUpperCase().contains(searchText) ||
          session.sessionName != null &&
              session.address!.toUpperCase().contains(searchText) ||
          DateFormat('dd MMMM yyyy HH:mm')
              .format(session.dateStamp)
              .toUpperCase()
              .contains(searchText)) {
        _filteredListOfSessions.add(session);
      }
    }

    _resultsBySessionId.forEach((sessionId, results) {
      List<ResultModel> listOfResults = [];
      if (results != null) {
        for (var result in results) {
          String name = result.name?.toUpperCase() ?? '';
          String address = result.address?.toUpperCase() ?? '';
          String expression = result.expression.toUpperCase();
          String resultString = result.result.toString().toUpperCase();
          String dateStamp = DateFormat('dd MMMM yyyy HH:mm')
              .format(result.dateStamp)
              .toUpperCase();
          String note = result.note?.toUpperCase() ?? '';

          if (name.contains(searchText) ||
              address.contains(searchText) ||
              expression.contains(searchText) ||
              resultString.contains(searchText) ||
              dateStamp.contains(searchText) ||
              note.contains(searchText)) {
            listOfResults.add(result);
            print(result.name);
          }
        }
        if (listOfResults.isNotEmpty) {
          _filteredResultsBySessionId[sessionId] = listOfResults;
          SessionModel session =
              _listOfSessions.firstWhere((element) => element.id == sessionId);
          _filteredListOfSessions.add(session);
        }
      }
    });
    isFilterOn = true;
    updateUI();
  }

  @override
  void didChangeDependencies() {
    _listOfSessions = Provider.of<Results>(context, listen: false)
        .sessionModels
        .reversed
        .toList();
    _resultsBySessionId = Provider.of<Results>(context, listen: true).results;
    super.didChangeDependencies();
  }

  void updateUI() {
    if (_searchController.text == '') isFilterOn = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var isLightTheme =
        Provider.of<SettingsProvider>(context, listen: true).isLightTheme;
    ColorTheme theme =
        Provider.of<SettingsProvider>(context, listen: true).providerTheme;
    int decimals =
        Provider.of<SettingsProvider>(context, listen: true).decimals;
    List<SessionModel> listOfSessionsToShow = [];
    Map<int, List<ResultModel>?> resultsToShow = {};
    listOfSessionsToShow =
        isFilterOn ? _filteredListOfSessions : _listOfSessions;
    resultsToShow =
        isFilterOn ? _filteredResultsBySessionId : _resultsBySessionId;

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
          title: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: AnimatedTextKit(
              key: ValueKey<bool>(isLightTheme),
              pause: Duration(milliseconds: 1000),
              totalRepeatCount: 1,
              animatedTexts: [
                RotateAnimatedText(
                  'Search',
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
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.resultText,
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  filterValues(value.toUpperCase());
                },
                textAlignVertical: TextAlignVertical.bottom,
                style: const TextStyle(
                  fontSize: 14,
                ),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.resultText,
                  ),
                  hintText: 'Search...',
                  hintStyle: const TextStyle(
                    fontSize: 14, // Set the same font size as TextField style
                    height:
                        1.5, // Set the line height to 1.5 times the font size
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.text = '';
                      isFilterOn = false;
                      updateUI();
                    },
                    icon: Icon(
                      Icons.clear,
                      color: theme.resultText,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 12), // Set top padding for hint text
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView(shrinkWrap: true, reverse: false, children: [
                ListView.builder(
                  controller: _resultsController,
                  itemCount: listOfSessionsToShow.length,
                  reverse: true,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (BuildContext context, int sessionIndex) {
                    int sessionId = listOfSessionsToShow[sessionIndex].id;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // _scaleDialog(sessionId, null, true);
                              },
                              child: SizedBox(
                                height: 15,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${listOfSessionsToShow[sessionIndex].sessionName} $sessionIndex',
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
                                      .format(listOfSessionsToShow[sessionIndex]
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
                              itemCount: resultsToShow[sessionId]?.length ?? 0,
                              itemBuilder: (context, index) {
                                var i = resultsToShow[sessionId]!.length -
                                    index -
                                    1;
                                List<ResultModel> results =
                                    resultsToShow[sessionId] ?? [];
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
                                  // textSize: textFieldFontSize * 0.4,
                                  textSize: 80 * 0.4,
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
          ],
        ),
      ),
    );
  }
}

//
