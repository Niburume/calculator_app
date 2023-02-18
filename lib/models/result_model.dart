import 'package:flutter/cupertino.dart';

class ResultModel {
  String id;
  String? name;
  String expression;
  double result;
  DateTime dateStamp;
  String? address;
  String? note;

  ResultModel(
      {required this.id,
      this.name,
      required this.expression,
      required this.result,
      required this.dateStamp,
      this.address,
      this.note});

  // ResultModel model =
  //     ResultModel(id: '123', expression: '3+4+5+6', result: '35');

}

class Results extends ChangeNotifier {
  List<ResultModel> get resultModels {
    return [..._dummyModels];
  }

  void addResult(ResultModel result) {
    _dummyModels.add(result);
  }

  void changeNameById(String id, String name) {
    resultModels.forEach((element) {
      if (element.id == id) {
        element.name = name;
        return;
      }
      notifyListeners();
    });
  }

  changeNoteById(String id, String note) {
    resultModels.forEach((element) {
      if (element.id == id) {
        element.note = note;
        return;
      }
      notifyListeners();
    });
  }

  ResultModel fetchResultModelById(String id) {
    print(resultModels[0].id);
    return resultModels.firstWhere((element) => element.id == id);
  }
}

final List<ResultModel> _dummyModels = [];
