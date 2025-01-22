import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';

class ClickDetector extends StatefulWidget {
  const ClickDetector(
      {super.key,
      required this.onClick,
      required this.onLongClick,
      required this.child});
  final Widget child;

  final Function() onLongClick;
  final Function() onClick;

  @override
  State<ClickDetector> createState() => ClickDetectorState();
}

class ClickDetectorState extends State<ClickDetector>
    with TickerProviderStateMixin {
  Timer? _clickTm;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) {
          _clickTm?.cancel();
          _clickTm = Timer(const Duration(milliseconds: 200), () async {
            logDebug('BTEST_onTapDown-timer fired');
            _clickTm = null;
            widget.onLongClick();
          });
          logDebug('BTEST_onTapDown');
        }, // Start long press when the card is pressed
        onTapUp: (_) {
          _clickTm?.cancel();
          if (_clickTm != null) {
            logDebug('BTEST_onTapUp - just a click');
            widget.onClick();
          }
          logDebug('BTEST_onTapUp');
        }, // End long press when tap is released
        onTapCancel: () {
          logDebug('BTEST_onTapCancel');
        }, // Reset if the tap is canceled
        child: widget.child);
  }
}
