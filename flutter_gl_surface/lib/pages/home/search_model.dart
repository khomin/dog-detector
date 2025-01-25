import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:intl/intl.dart';

class SearchModel with ChangeNotifier {
  bool searchBusy = false;
  List<HistoryRecord> result = [];
  String? search;
  Timer? _searchThrottleTm;

  @override
  void dispose() {
    super.dispose();
    _searchThrottleTm?.cancel();
  }

  void setSearchBusy(bool v) {
    if (searchBusy != v) {
      searchBusy = v;
      notifyListeners();
    }
  }

  void setHistory(List<HistoryRecord> v) {
    if (result != v) {
      result = [];
      result.addAll(v);
      notifyListeners();
    }
  }

  void setSearch(String? v) {
    _searchThrottleTm?.cancel();
    _searchThrottleTm = Timer(const Duration(milliseconds: 100), () {
      result = [];
      if (search != v) {
        search = v;
        if (v != null && v.isNotEmpty) {
          try {
            var date = DateFormat('dd.MM.yyyy').parse(v);
            var history = MyRep().historyCache;
            for (var it in history) {
              if (it.date.year == date.year &&
                  it.date.month == date.month &&
                  it.date.day == date.day) {
                result.add(it);
              }
            }
          } catch (_) {}
        }
        notifyListeners();
      }
    });
  }
}
