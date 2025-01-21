import 'dart:io';
import 'package:flutter/cupertino.dart';

enum Mode { canUseSwipeBack, none }

enum Option { slide, none }

class PageTransition {
  static Route<dynamic> buildTransition(
      {required RouteSettings settings,
      required Mode mode,
      required Widget child,
      Option option = Option.none}) {
    switch (mode) {
      case Mode.canUseSwipeBack:
        if (Platform.isIOS) {
          return CupertinoPageRoute(
              settings: settings,
              builder: (context) {
                return child;
              });
        }
        return PageRouteBuilder(
            settings: settings,
            transitionDuration: option == Option.slide
                ? pageTransitionDuration()
                : Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: transitionHorizontal,
            pageBuilder: (context, animation, secondaryAnimation) {
              return child;
            });
      case Mode.none:
        return PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              return child;
            });
    }
  }

  static SlideTransition transitionHorizontal(
      context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );
    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }

  static SlideTransition transitionVertical(
      context, animation, secondaryAnimation, child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );
    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }

  static Duration pageTransitionDuration() {
    return const Duration(milliseconds: 200);
  }
}
