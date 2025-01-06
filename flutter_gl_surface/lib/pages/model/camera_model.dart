import 'package:flutter/material.dart';
import 'package:flutter_demo/resource/constants.dart';

class CameraModel with ChangeNotifier {
  CameraModel();

  int minArea = Constants.minAreaDefault;
  int captureIntervalSec = Constants.minCaptureintervalDefault;

  void setMinArea(int v) {
    if (minArea != v) {
      minArea = v;
      notifyListeners();
    }
  }

  void setCaptureImageIntVal(int v) {
    if (captureIntervalSec != v) {
      captureIntervalSec = v;
      notifyListeners();
    }
  }
}
