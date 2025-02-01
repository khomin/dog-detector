import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/navigation_observer.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:rxdart/rxdart.dart';

enum PageType { home, capture, alert, settings, search }

class Panel {
  Panel(
      {required this.type,
      this.arg,
      this.fullPop = false,
      this.replace = false,
      this.onePop = false});
  final PageType type;
  final dynamic arg;
  final bool fullPop;
  final bool replace;
  final bool onePop;
}

class NavigatorRep {
  final routeBloc = PanelRouterBlocSecondary();
  final onLayoutChanged = BehaviorSubject<ScreenType>();
  // var size = const Size(0, 0);

  Future<bool> Function()? onCheckPopAllowed;

  static const tag = 'navRep';
  static NavigatorRep? _instance;

  NavigatorRep._internal();
  factory NavigatorRep() {
    _instance ??= NavigatorRep._internal();
    return _instance!;
  }

  void dispose() {}
}

class PanelRouterBlocSecondary {
  final onGoto = PublishSubject<Panel?>();
  final onCurrent = BehaviorSubject<Panel?>();
  final navKey = GlobalKey<NavigatorState>();
  late NavigatorObserverCustom observer;

  void goto(Panel panel) {
    if (_checkPaneTheSameAsCurrent(panel, onCurrent.valueOrNull)) {
      return;
    }
    if (panel.fullPop) {
      fullPop();
    }
    onGoto.add(panel);
  }

  void fullPop() {
    onGoto.add(null);
  }

  void dispose() {
    onGoto.close();
  }

  bool _checkPaneTheSameAsCurrent(Panel panel, Panel? current) {
    return false;
  }

  void onChanged(String name, dynamic arg) {
    var route = routeNameToType(name);
    onCurrent.add(Panel(type: route, arg: arg));
    NavigatorRep().onCheckPopAllowed = null;
  }

  void onDidPop() {
    if (navKey.currentState?.canPop() == false) {
      onCurrent.add(null);
    }
  }

  PageType routeNameToType(String? name) {
    for (var it in PageType.values) {
      if (it.name == name) {
        return it;
      }
    }
    return PageType.home;
  }
}
