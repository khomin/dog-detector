import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';

class RecordModel with ChangeNotifier {
  RecordModel();

  bool run = false;
  bool flipWait = false;
  double flipTurns = 0.0;

  Camera? camera;

  int rotation = 0;

  void setRun(
      {required bool run, required Camera? camera, bool mounted = true}) {
    if (this.run != run || this.camera != camera) {
      this.run = run;
      this.camera = camera;
      if (mounted) notifyListeners();
    }
  }

  void setFlipWait(bool v) {
    if (flipWait != v) {
      flipWait = v;
      notifyListeners();
    }
  }

  void setRotation(int v) {
    if (rotation != v) {
      rotation = v;
      notifyListeners();
    }
  }
}
