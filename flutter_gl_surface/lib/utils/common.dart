import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/nav_rep.dart';

enum ScreenType { minimum, full }

class Common {
  ScreenType calcLayout(BuildContext context) {
    var view = View.of(context).platformDispatcher.views.first;
    NavigatorRep().size = view.physicalSize / view.devicePixelRatio;
    return rootWidgetLayout(NavigatorRep().size, view.devicePixelRatio);
  }

  static ScreenType rootWidgetLayout(Size size, double devicePixelRatio) {
    ScreenType layout;
    var lastValue = NavigatorRep().onLayoutChanged.valueOrNull;

    if (Platform.isAndroid) {
      // final diagonal = (size.width * size.width + size.height * size.height);

      // const pixelsPerInch = 150; // Approximation for average devices
      // final diagonalInInches = diagonal / devicePixelRatio;

      // // Minimum diagonal size for tablets
      // if (diagonalInInches >= 7.0) {
      //   layout = ScreenType.large;
      // } else {
      //   layout = ScreenType.minimum;
      // }
      // final smallestWidth = size.shortestSide / devicePixelRatio;
      // if (smallestWidth >= 600) {
      //   layout = ScreenType.large;
      // } else {
      //   layout = ScreenType.minimum;
      // }
      if (size.width >= 600 && size.height > 600) {
        layout = ScreenType.full;
      } else {
        layout = ScreenType.minimum;
      }
    } else {
      if (size.width >= 600 && size.height > 600) {
        layout = ScreenType.full;
      } else {
        layout = ScreenType.minimum;
      }
    }
    if (layout != lastValue) {
      NavigatorRep().onLayoutChanged.add(layout);
      // logDebug('layout changed: ${size.width}: layout=$layout');
    }
    // logDebug('layout size: ${size.width}');
    return layout;
  }
}
