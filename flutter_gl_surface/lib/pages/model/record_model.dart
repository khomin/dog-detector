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

  // int rotation = 0;
  // int ratio = 0;

  // var camera =
  //                                     context.select<RecordModel, Camera?>(
  //                                         (v) => v.camera);
  //                                 var size = camera?.size ?? const Size(0, 0);
  //                                 var ratio = 1.0;
  //                                 if (size.width > 0 && size.height > 0) {
  //                                   switch (rotation) {
  //                                     case 0: // hor
  //                                       size = size.flipped;
  //                                       break;
  //                                     case 1: // vert
  //                                       // size = size.flipped;
  //                                       break;
  //                                     case 2: // hor
  //                                       size = size.flipped;
  //                                       break;
  //                                     case 3:
  //                                       break;
  //                                     case 4:
  //                                       break;
  //                                   }
  //                                   if (size.width > size.height) {
  //                                     ratio = size.width / size.height;
  //                                   } else {
  //                                     ratio = size.height / size.width;
  //                                   }
  //                                   // if (rotation == 0) {
  //                                   //   if (size.width > 0 && size.height > 0) {
  //                                   //     ratio = size.width / size.height;
  //                                   //   }
  //                                   // } else {
  //                                   //   if (size.width > 0 && size.height > 0) {
  //                                   //     ratio = size.width / size.height;
  //                                   //   }
  //                                   // }
  //                                 }
  //                                 logDebug('BTEST ratio=$ratio');

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

  // void setRotation(int v) {
  //   if (rotation != v) {
  //     rotation = v;
  //     notifyListeners();
  //   }
  // }

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
