import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';

class RecordModel with ChangeNotifier {
  RecordModel();

  bool run = false;
  Camera? camera;

  void setRun(bool v, Camera camera) {
    if (v != run) {
      run = v;
      this.camera = camera;
      notifyListeners();
    }
  }
}
