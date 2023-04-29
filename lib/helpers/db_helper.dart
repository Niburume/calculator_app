//Database return a list of Maps: {'_id':12, 'namme':'SomeName'}

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/models.dart';

class DBHelper {
  static const _dbName = 'calcData.db';
  static const _dbVersion = 1;
  static const _sessionTable = 'Sessions';
  static const _resultTable = 'Results';

  // sessions
  static const columnSessionId = 'id';
  static const sessionName = 'sessionName';
  static const dateStampSession = 'dateStamp';
  static const address = 'address';
  static const latitude = 'latitude';
  static const longitude = 'longitude';

  // results
  static const columnResultId = 'id';
  static const resultName = 'name';
  static const expression = 'expression';
  static const result = 'result';
  static const dateStampResult = 'dateStamp';

  static const note = 'note';
  static const sessionId = 'sessionId';

  // making it a singleton class
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE $_sessionTable (
      $columnSessionId INTEGER PRIMARY KEY,
      $sessionName TEXT NOT NULL,
      $dateStampSession TEXT NOT NULL,
      $address TEXT,
      $latitude REAL,
      $longitude REAL
      )
      
       ''');
    db.execute('''
    CREATE TABLE $_resultTable (
    $columnResultId INTEGER PRIMARY KEY,
    $resultName TEXT,
    $expression TEXT NOT NULL,
    $result REAL NOT NULL,
    $address TEXT,
    $dateStampResult TEXT NOT NULL,
    $sessionId INTEGER,
    $note TEXT,
    FOREIGN KEY($sessionId) REFERENCES $_sessionTable($columnSessionId) ON DELETE CASCADE
    )
    ''');
  }

  Future<int?> insertSession(Map<String, dynamic> session) async {
    Database? db = await instance.database;
    if (db != null) return await db.insert(_sessionTable, session);
    return null;
  }

  Future<int?> insertResult(Map<String, dynamic> result) async {
    Database? db = await instance.database;
    if (db != null) return await db.insert(_resultTable, result);
    return null;
  }

  Future<int?> isLastSessionEmpty() async {
    Database? db = await instance.database;
    int? sessionId;
    if (db != null) {
      List<Map<String, dynamic>> session = await db.rawQuery(
          'SELECT * FROM $_sessionTable ORDER BY $columnSessionId DESC LIMIT 1');
      if (session.isEmpty) return null;
      if (session.isNotEmpty) {
        sessionId = session.first['id'] as int?;
      }

      var listOfResults = await db.rawQuery(
        'SELECT * FROM $_resultTable WHERE sessionId = ?',
        [sessionId],
      );
      if (listOfResults.isEmpty) {
        return sessionId;
      }
    }
    return null;
  }

  Future<List<SessionModel>?> queryAllSessions() async {
    List<SessionModel> _listOfSessions = [];
    Database? db = await instance.database;
    if (db != null) {
      var sessions = await db.query(_sessionTable);
      // try to query results if null, delete

      for (var sessionRow in sessions) {
        int sessionId = sessionRow[DBHelper.columnSessionId] as int;
        String sessionName = sessionRow[DBHelper.sessionName] as String;
        String dateStampSession =
            sessionRow[DBHelper.dateStampSession] as String;
        String address = sessionRow[DBHelper.address] as String;
        double? latitude = sessionRow[DBHelper.latitude] as double?;
        double? longitude = sessionRow[DBHelper.longitude] as double?;
        SessionModel session = SessionModel(
            id: sessionId,
            sessionName: sessionName,
            dateStamp: DateTime.parse(dateStampSession),
            address: address,
            latitude: latitude,
            longitude: longitude);
        _listOfSessions.add(session);
      }
      return _listOfSessions.reversed.toList();
    }
    return null;
  }

  Future<Map<int, List<ResultModel>>> queryMapOfResultsBySessionIds(
      List<int> sessionIds) async {
    Map<int, List<ResultModel>> results = {};
    Database? db = await instance.database;
    if (db != null) {
      for (int sessionId in sessionIds) {
        var resultRows = await db.rawQuery('''
         SELECT * FROM $_resultTable 
         WHERE $_resultTable.${DBHelper.sessionId} = ?
       ''', [sessionId]);

        List<ResultModel> resultList = [];
        for (var resultRow in resultRows) {
          if (resultRow.isEmpty) continue;

          int sessionId = resultRow[DBHelper.sessionId] as int;
          int resultId = resultRow[DBHelper.columnResultId] as int;
          String? resultName = resultRow[DBHelper.resultName] as String?;
          String expression = resultRow[DBHelper.expression] as String;
          double resultValue = resultRow[DBHelper.result] as double;
          String dateStampResult =
              resultRow[DBHelper.dateStampResult] as String;

          String? note = resultRow[DBHelper.note] as String?;
          ResultModel result = ResultModel(
              id: resultId,
              name: resultName,
              expression: expression,
              result: resultValue,
              dateStamp: DateTime.parse(dateStampResult),
              note: note,
              sessionId: sessionId);
          resultList.add(result);
        }
        // if (resultList.isEmpty) {
        //   continue;
        // }
        results[sessionId] = resultList;
      }
    }
    return results;
  }

  Future<int?> updateSession(int id, String dateStamp, String? sessionName,
      String? address, double? latitude, double? longitude) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.update(
          _sessionTable,
          {
            DBHelper.dateStampSession: dateStamp,
            DBHelper.sessionName: sessionName,
            DBHelper.address: address,
            DBHelper.latitude: latitude,
            DBHelper.longitude: longitude
          },
          where: '$columnSessionId = ?',
          whereArgs: [id]);
    }
    return null;
  }

  Future<int?> updateResult(int resultId, String resultName, String? address,
      String? resultNote) async {
    Database? db = await instance.database;

    if (db != null) {
      return await db.update(
          _resultTable,
          {
            DBHelper.resultName: resultName,
            DBHelper.note: resultNote,
            DBHelper.address: address
          },
          where: '$columnResultId = ?',
          whereArgs: [resultId]);
    }
    return null;
  }

  Future<int?> deleteSession(int id) async {
    Database? db = await instance.database;
    if (db != null) {
      return await db.delete(_sessionTable,
          where: '$columnSessionId = ?', whereArgs: [id]);
    }
    return null;
  }
}
