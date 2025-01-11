import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

enum ScreenType { minimum, full }

extension DurationFormat on Duration {
  String format() => '$this'.split('.')[0].padLeft(8, '0');
}

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

  DateTime parseFileNameToDate(String name) {
    try {
      return DateFormat('yyyy-MM-dd kk-mm-sss').parse(name);
    } catch (_) {}
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String formatDateInt(int timestampMicro) {
    var dateTimeStr = '';
    var curDate = DateTime.now();
    var dateTime = DateTime.fromMicrosecondsSinceEpoch(timestampMicro);
    if (Jiffy.parseFromDateTime(dateTime).dayOfYear ==
        Jiffy.parseFromDateTime(curDate).dayOfYear) {
      dateTimeStr = DateFormat('hh:mm a').format(dateTime);
    } else if (Jiffy.parseFromDateTime(dateTime).dayOfYear ==
        Jiffy.parseFromDateTime(curDate).dayOfYear - 1) {
      dateTimeStr = 'Yesterday';
    } else {
      dateTimeStr = DateFormat('dd-MM-yyyy').format(dateTime);
    }
    return dateTimeStr;
  }

  String dayOfWeekString(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
    }
    return 'Unknown';
  }

  String monthString(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
    }
    return 'Unknown';
  }
}
