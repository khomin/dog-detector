import 'package:flutter/material.dart';

class HistoryModel with ChangeNotifier {
  HistoryModel();

  bool ready = false;

  void setReady(bool v) {
    if (v != ready) {
      ready = v;
      notifyListeners();
    }
  }
}
