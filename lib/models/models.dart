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

    List<int> sessionIds = [];
    _listOfSessions.forEach((element) {
      sessionIds.add(element.id);
    });
    _resultsBySessionId =
        await DBHelper.instance.queryMapOfResultsBySessionIds(sessionIds);
    return true;
  }

  Future<int?> createSession() async {
    int? lastSessionIdIfEmpty = await DBHelper.instance.isLastSessionEmpty();
    print(lastSessionIdIfEmpty);
    String? address = '...';
    String? name = '...';
    DateTime dateStamp = DateTime.now();
    if (lastSessionIdIfEmpty != null) {
      updateSession(lastSessionIdIfEmpty, null, address, name, null, null);
      return lastSessionIdIfEmpty;
    } else {
      int? sessionId = await DBHelper.instance.insertSession({
        DBHelper.sessionName: name,
        DBHelper.address: address,
        DBHelper.dateStampSession: dateStamp.toIso8601String()
      });
      if (sessionId != null) {
        _listOfSessions.insert(
            0,
            SessionModel(
                id: sessionId,
                dateStamp: dateStamp,
                sessionName: name,
                address: address));
        return sessionId;
      }
    }
    return null;
  }

  void updateSession(int sessionId, DateTime? dateStamp, String sessionName,
      String? address, double? latitude, double? longitude) async {
    dateStamp ??= DateTime.now();

    final index =
        _listOfSessions.indexWhere((element) => element.id == sessionId);
    address ??= _listOfSessions[index].address;
    if (index != -1) {
      _listOfSessions[index].sessionName = sessionName;
      _listOfSessions[index].address = address;
      _listOfSessions[index].latitude = latitude;
      _listOfSessions[index].longitude = longitude;
      DBHelper.instance.updateSession(sessionId, dateStamp.toIso8601String(),
          sessionName, address, latitude, longitude);
      notifyListeners();
    }
  }

  Future<bool> addResult(
    String expression,
    double resultOfExp,
    String? address,
    int sessionId,
  ) async {
    DateTime dateStamp = DateTime.now();

    int? newResultId = await DBHelper.instance.insertResult({
      DBHelper.dateStampResult: dateStamp.toIso8601String(),
      DBHelper.address: address,
      DBHelper.expression: expression,
      DBHelper.result: resultOfExp,
      DBHelper.sessionId: sessionId
    });
    if (newResultId != null) {
      ResultModel result = ResultModel(
          id: newResultId,
          address: address,
          expression: expression,
          result: resultOfExp,
          dateStamp: dateStamp,
          sessionId: sessionId);

      List<ResultModel>? results = _resultsBySessionId[sessionId] ?? [];
      results.add(result);

      _resultsBySessionId[sessionId] = results;
    }
    notifyListeners();
    return true;
  }

  List<ResultModel> getResultsModelsBySessionId(String sessionId) {
    return results[sessionId]!;
  }

  void updateResult(int sessionId, int resultId, String resultName,
      String? address, String? note) async {
    results[sessionId]?.forEach((element) {
      if (element.id == resultId) {
        element.name = resultName;
        note == null ? note = element.note : element.note = note;
        address == null ? address = element.address : element.address = address;
      }
    });
    DBHelper.instance.updateResult(resultId, resultName, address, note);
    notifyListeners();
  }

  void updateAddressesOnResults(int sessionId, String address) async {
    Map<int, List<ResultModel>> mapOfResults =
        await DBHelper.instance.queryMapOfResultsBySessionIds([sessionId]);
    if (mapOfResults != null) {
      List<ResultModel> listOfResults = mapOfResults[sessionId]!;
      List<ResultModel> newListOfResults = [];
      for (var result in listOfResults) {
        await DBHelper.instance
            .updateResult(result.id, result.name!, address, result.note);
        newListOfResults.add(ResultModel(
            id: result.id,
            expression: result.expression,
            result: result.result,
            dateStamp: result.dateStamp,
            sessionId: result.sessionId,
            address: result.address));
      }
      mapOfResults[sessionId] = newListOfResults;
      notifyListeners();
    }
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
    print(id);
    id = 4;
    print(_listOfSessions.length);

    return _listOfSessions.firstWhere((element) => element.id == id);
  }
}
