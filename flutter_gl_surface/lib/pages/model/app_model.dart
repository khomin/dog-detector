import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';

enum ThemeType { light, dark, system }

class AppModel with ChangeNotifier {
  AppModel();

  bool ready = false;
  bool collapse = false;
  List<HistoryRecord> history = [];

  void setReady(bool v) {
    if (v != ready) {
      ready = v;
      notifyListeners();
    }
  }

  void setHistory(List<HistoryRecord> v) {
    if (history != v) {
      history = v;
      notifyListeners();
    }
  }

  void setCollapse(bool v) {
    if (v != collapse) {
      collapse = v;
      notifyListeners();
    }
  }
}
