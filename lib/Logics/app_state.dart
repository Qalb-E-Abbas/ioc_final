import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum StateStatus { IsBusy, IsFree, IsError }


class AppState with ChangeNotifier {

  StateStatus _status = StateStatus.IsFree;

  void stateStatus(StateStatus status) {
    _status = status;
    notifyListeners();
  }

  getStateStatus() => _status;

}
