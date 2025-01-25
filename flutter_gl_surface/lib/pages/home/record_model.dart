import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:loggy/loggy.dart';

class SurfaceLayout {
  SurfaceLayout({required this.rotation, required this.ratio});
  int rotation;
  double ratio;
}

class RecordModel with ChangeNotifier {
  RecordModel();

  bool run = false;
  int devRotation = 0;
  bool flipWait = false;
  bool orientationpWait = false;
  bool modeMenuVisible = false;
  double flipTurns = 0.0;

  Camera? camera;
  // SurfaceLayout surfaceLayout = SurfaceLayout(rotation: 0, ratio: 1);

  // bool hideSurface = false;
  // bool showBlur = false;
  String? imgBlur;
  SurfaceLayout layout = SurfaceLayout(rotation: 0, ratio: 1);
  SurfaceLayout oldLayout = SurfaceLayout(rotation: 0, ratio: 1);

  void setRun(
      {required bool run, required Camera? camera, bool mounted = true}) {
    if (this.run != run || this.camera != camera) {
      this.run = run;
      this.camera = camera;
      if (mounted) notifyListeners();
    }
  }

  // void setHideSurface(bool v) {
  //   if (hideSurface != v) {
  //     hideSurface = v;
  //     notifyListeners();
  //   }
  // }

  // void setShowBlur(bool v) {
  //   if (showBlur != v) {
  //     showBlur = v;
  //     notifyListeners();
  //   }
  // }

  void setImgBlur(String? v) {
    if (imgBlur != v) {
      imgBlur = v;
      notifyListeners();
    }
  }

  void setFlipWait(bool v) {
    if (flipWait != v) {
      flipWait = v;
      notifyListeners();
    }
  }

  void setSurfaceLayout(SurfaceLayout v) {
    layout = v;
    notifyListeners();
  }

  void setBlurLayout(SurfaceLayout v) {
    oldLayout = v;
  }

  // void setOrientationWait(bool v) {
  //   if (orientationpWait != v) {
  //     orientationpWait = v;
  //     notifyListeners();
  //   }
  // }

  void setModeMenuVisible(bool v) {
    if (modeMenuVisible != v) {
      modeMenuVisible = v;
      notifyListeners();
    }
  }

  void updateRotation() {
    var sensorRotation = camera?.sensor ?? 0;
    var rotation = _adjustRotation(
        sensorRotation: sensorRotation,
        deviceRotation: devRotation,
        front: camera?.facing == 'Front');
    var size = camera?.size;
    var ratio = 1.0;
    if (size != null) {
      if (size.width > size.height) {
        ratio = size.width / size.height;
      } else {
        ratio = size.height / size.width;
      }
      // ratio = size.height / size.width;
      // ratio = size.width / size.height;
    }
    setSurfaceLayout(SurfaceLayout(rotation: rotation, ratio: ratio));
    logDebug(
        'BTEST:2 rotation=$rotation, devRotation=$devRotation, sensorRotation=$sensorRotation');
  }

  int _adjustRotation(
      {required int sensorRotation,
      required int deviceRotation,
      required bool front}) {
    // 1
    // // Calculate the rotation values in terms of quarter turns.
    // int sensorQuarterTurn = (sensorRotation ~/ 90) % 4; // 0 to 3
    // int deviceQuarterTurn = (deviceRotation ~/ 90) % 4; // 0 to 3

    // // Combine the two to get the final rotation.
    // // Since both values represent a rotation, we could just add them.
    // int adjustedTurn = (sensorQuarterTurn + deviceQuarterTurn) % 4;

    // return adjustedTurn; // Return a value between 0 and 3

    //// 2
    // Combine sensor and device rotation
    if (front) {
      int combinedRotation = (sensorRotation + deviceRotation) % 360;
      return combinedRotation ~/ 90;
    } else {
      int combinedRotation = (sensorRotation - deviceRotation + 360) % 360;
      return combinedRotation ~/ 90;
    }

    // // 3
    // // Combine sensor and device rotations
    // int combinedRotation = (sensorRotation + deviceRotation) % 360;

    // // Convert degrees to quarterTurns
    // return combinedRotation ~/ 90;
  }
}
