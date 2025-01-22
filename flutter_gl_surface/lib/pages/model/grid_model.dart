import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';

class GridModel with ChangeNotifier {
  List<HistoryRecord> history = [];

  void setHistory(List<HistoryRecord> v) {
    if (history != v) {
      history = [];
      history.addAll(v);
      notifyListeners();
    }
  }
}
