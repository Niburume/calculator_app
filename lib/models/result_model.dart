import 'package:flutter/cupertino.dart';

class ResultModel {
  final String id;
  String? name;
  String expression;
  double result;
  final DateTime dateStamp;
  String? address;
  String? note;
  String sessionId;

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

class SessionModel {
  String id;
  String? sessionName;
  List<String> resultsId;
  final DateTime dateStamp;

  SessionModel(
      {required this.id,
      required this.dateStamp,
      this.sessionName,
      required this.resultsId});
}

class Results extends ChangeNotifier {
  final Map<String, List<ResultModel>> _sessionsExpressions = {};
  final List<SessionModel> _sessions = [];

  List<SessionModel> get sessionModels {
    return [..._sessions];
  }

  Map<String, List<ResultModel>> get expressions {
    return _sessionsExpressions;
  }

  void addResult(String sessionId, ResultModel result) {
    if (!_sessionsExpressions.containsKey(sessionId)) {
      _sessionsExpressions[sessionId] = [];
    }
    _sessionsExpressions[sessionId]!.add(result);
    _sessions.forEach((element) {
      if (element.id == sessionId) {
        element.resultsId.add(result.id);
        return;
      }
    });

    notifyListeners();
  }

  List<ResultModel> getResultsModelsBySessionId(String sessionId) {
    return expressions[sessionId]!;
  }

  void changeExpressionNameById(String sessionId, String id, String name) {
    expressions[sessionId]?.forEach((element) {
      if (element.id == id) {
        element.name = name;
        return;
      }
      notifyListeners();
    });
  }

  changeNoteById(String sessionId, String id, String note) {
    expressions[sessionId]?.forEach((element) {
      if (element.id == id) {
        element.note = note;
        return;
      }
      notifyListeners();
    });
  }

  ResultModel? fetchResultModelById(String sessionId, String id) {
    return expressions[sessionId]?.firstWhere((element) => element.id == id);
  }

// Sessions
  String createSession() {
    String sessionId = DateTime.now().toString();
    _sessions.insert(
        0,
        SessionModel(
            dateStamp: DateTime.now(),
            id: sessionId,
            sessionName: sessionId,
            resultsId: []));
    return sessionId;
  }

  void updateSessionName(String id, String name) {
    _sessions.forEach((element) {
      if (element.id == id) {
        element.sessionName = name;
        return;
      }
    });
    notifyListeners();
  }

  String fetchSessionNameById(id) {
    SessionModel? session = _sessions.firstWhere((element) => element.id == id);
    if (session != null) {
      return session.sessionName!;
    } else {
      return 'No name';
    }
  }

  // void addResult(String sessionId, String resultId) {
  //   _sessions.forEach((element) {
  //     print('session id is: ${element.id}');
  //     if (element.id == sessionId) {
  //       element.resultsId?.add(resultId);
  //     }
  //   });
  //
  //   notifyListeners();
  // }
}
