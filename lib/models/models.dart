import 'package:calculator_app/helpers/db_helper.dart';
import 'package:flutter/cupertino.dart';

class SessionModel {
  final int id;
  String? sessionName;
  String? address;
  double? latitude;
  double? longitude;

  final DateTime dateStamp;

  SessionModel(
      {required this.id,
      required this.dateStamp,
      this.sessionName,
      this.address,
      this.longitude,
      this.latitude});
}

class ResultModel {
  final int id;
  String? name;
  String expression;
  double result;
  final DateTime dateStamp;
  String? address;
  String? note;
  int sessionId;

  ResultModel(
      {required this.id,
      this.name,
      required this.expression,
      required this.result,
      required this.dateStamp,
      this.address,
      this.note,
      required this.sessionId});
}

class Results extends ChangeNotifier {
  List<SessionModel> _listOfSessions = [];
  Map<int, List<ResultModel>?> _resultsBySessionId = {};

  List<SessionModel> get sessionModels {
    return [..._listOfSessions];
  }

  Map<int, List<ResultModel>?> get results {
    return _resultsBySessionId;
  }

  Future<bool> getHistory() async {
    _listOfSessions.clear();
    _listOfSessions = await DBHelper.instance.queryAllSessions() ?? [];
    print(_listOfSessions.length);
    List<int> sessionIds = [];
    _listOfSessions.forEach((element) {
      sessionIds.add(element.id);
    });
    _resultsBySessionId =
        await DBHelper.instance.queryMapOfResultsBySessionIds(sessionIds);
    return true;
  }

  Future<int?> createSession() async {
    int? currentSessionId = await DBHelper.instance.insertSession({
      DBHelper.sessionName: '...',
      DBHelper.dateStampSession: DateTime.now().toIso8601String(),
      DBHelper.address: '',
    });
    if (currentSessionId != null) {
      return currentSessionId;
    }
    return null;
  }

  void updateSession(int sessionId, String sessionName, String? address) async {
    print('success');
    final index =
        _listOfSessions.indexWhere((element) => element.id == sessionId);
    address ??= _listOfSessions[index].address;
    if (index != -1) {
      _listOfSessions[index].sessionName = sessionName;
      _listOfSessions[index].address = address;
      DBHelper.instance.updateSession(sessionId, sessionName, address);
      notifyListeners();
    }
  }

  void addResult(
    String expression,
    double resultOfExp,
    int sessionId,
  ) async {
    DateTime dateNow = DateTime.now();

    int? newResultId = await DBHelper.instance.insertResult({
      DBHelper.dateStampResult: dateNow.toIso8601String(),
      DBHelper.expression: expression,
      DBHelper.result: resultOfExp,
      DBHelper.sessionId: sessionId
    });
    if (newResultId != null) {
      ResultModel result = ResultModel(
          id: newResultId,
          expression: expression,
          result: resultOfExp,
          dateStamp: dateNow,
          sessionId: sessionId);

      List<ResultModel>? results = _resultsBySessionId[sessionId];
      results?.add(result);
      _resultsBySessionId[sessionId] = results;
    }
    notifyListeners();
  }

  List<ResultModel> getResultsModelsBySessionId(String sessionId) {
    return results[sessionId]!;
  }

  void updateResult(
      int sessionId, int resultId, String resultName, String? note) async {
    print('sended note: $note');
    results[sessionId]?.forEach((element) {
      if (element.id == resultId) {
        element.name = resultName;
        note == null ? note = element.note : element.note = note;
        print('note models: $note');
      }
    });
    DBHelper.instance.updateResult(resultId, resultName, note);
    notifyListeners();
  }

  ResultModel? fetchResultModelById(int sessionId, int id) {
    return results[sessionId]?.firstWhere((element) => element.id == id);
  }

  String fetchSessionNameById(id) {
    SessionModel? session =
        _listOfSessions.firstWhere((element) => element.id == id);
    if (session != null) {
      return session.sessionName!;
    } else {
      return 'No name';
    }
  }

  SessionModel fetchSessionModelById(id) {
    return _listOfSessions.firstWhere((element) => element.id == id);
  }
}
