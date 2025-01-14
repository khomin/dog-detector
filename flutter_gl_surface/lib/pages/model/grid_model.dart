import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';

class GridModel with ChangeNotifier {
  var transition = false;
  List<HistoryRecord> history = [];

  void setTransition(bool v) {
    if (transition != v) {
      transition = v;
      notifyListeners();
    }
  }

  void setHistory(List<HistoryRecord> v) {
    if (history != v) {
      history = [];
      history.addAll(v);
      notifyListeners();
    }
  }
}
