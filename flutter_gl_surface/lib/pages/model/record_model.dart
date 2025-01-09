import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';

class SurfaceLayout {
  SurfaceLayout({required this.rotation, required this.ratio});
  int rotation;
  double ratio;
}

class RecordModel with ChangeNotifier {
  RecordModel();

  bool run = false;
  bool flipWait = false;
  bool orientationpWait = false;
  bool modeMenuVisible = false;
  double flipTurns = 0.0;

  Camera? camera;
  SurfaceLayout surfaceLayout = SurfaceLayout(rotation: 0, ratio: 1);

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

  void setSurfaceLayout(SurfaceLayout v) {
    if (surfaceLayout.ratio != v.ratio ||
        surfaceLayout.rotation != v.rotation) {
      surfaceLayout = v;
      notifyListeners();
    }
  }

  void setOrientationWait(bool v) {
    if (orientationpWait != v) {
      orientationpWait = v;
      notifyListeners();
    }
  }

  void setModeMenuVisible(bool v) {
    if (modeMenuVisible != v) {
      modeMenuVisible = v;
      notifyListeners();
    }
  }
}
