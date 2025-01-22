import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';

class SearchModel with ChangeNotifier {
  List<HistoryRecord> result = [];
  String? search;

  void setHistory(List<HistoryRecord> v) {
    if (result != v) {
      result = [];
      result.addAll(v);
      notifyListeners();
    }
  }

  void setSearch(String? v) {
    if (search != v) {
      search = v;
      notifyListeners();
    }
  }
}
