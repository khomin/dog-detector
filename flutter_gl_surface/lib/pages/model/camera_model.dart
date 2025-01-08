import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';

class CameraModel with ChangeNotifier {
  CameraModel();

  int minArea = Constants.minAreaDefault;
  int captureIntervalSec = Constants.minCaptIntvalDefault;
  bool showAreaOnCapture = false;

  void init(
      {required int minArea,
      required int captureIntervalSec,
      required bool showAreaOnCapture}) {
    this.minArea = minArea;
    this.captureIntervalSec = captureIntervalSec;
    this.showAreaOnCapture = showAreaOnCapture;
    notifyListeners();
  }

  void setMinArea(int v) {
    if (minArea != v) {
      minArea = v;
      SettingsRep().setCaptureMinArea(v);
      MyRep().updateConfiguration(
          minArea: minArea,
          captureIntervalSec: captureIntervalSec,
          showAreaOnCapture: showAreaOnCapture);
      notifyListeners();
    }
  }

  void setCaptureImageIntVal(int v) {
    if (captureIntervalSec != v) {
      captureIntervalSec = v;
      SettingsRep().setCaptureIntervalSec(v);
      MyRep().updateConfiguration(
          minArea: minArea,
          captureIntervalSec: captureIntervalSec,
          showAreaOnCapture: showAreaOnCapture);
      notifyListeners();
    }
  }

  void setShowArea(bool v) {
    if (showAreaOnCapture != v) {
      showAreaOnCapture = v;
      SettingsRep().setCaptureShowArea(v);
      MyRep().updateConfiguration(
          minArea: minArea,
          captureIntervalSec: captureIntervalSec,
          showAreaOnCapture: showAreaOnCapture);
      notifyListeners();
    }
  }
}
