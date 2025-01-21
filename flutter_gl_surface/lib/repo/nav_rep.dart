import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/navigation_observer.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:rxdart/rxdart.dart';

enum PageTypePrimary { logo, main }

enum PageTypeSecondary { home, capture, alert, settings, search }

class PanelPrimary {
  PanelPrimary(
      {required this.type,
      this.arg,
      this.fullPop = false,
      this.replace = false,
      this.onePop = false});
  final PageTypePrimary type;
  final dynamic arg;
  final bool fullPop;
  final bool replace;
  final bool onePop;
}

class PanelSecondary {
  PanelSecondary(
      {required this.type,
      this.arg,
      this.fullPop = false,
      this.replace = false,
      this.onePop = false});
  final PageTypeSecondary type;
  final dynamic arg;
  final bool fullPop;
  final bool replace;
  final bool onePop;
}

class NavigatorRep {
  final routeBlocPrimary = PanelRouterBlocPrimary();
  final routeBlocSecondary = PanelRouterBlocSecondary();
  final onLayoutChanged = BehaviorSubject<ScreenType>();
  var size = const Size(0, 0);

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

class PanelRouterBlocPrimary {
  final onGoto = PublishSubject<PanelPrimary?>();
  final onCurrent = BehaviorSubject<PanelPrimary?>();
  final navKey = GlobalKey<NavigatorState>();
  late NavigatorObserverCustom observer;

  void goto(PanelPrimary panel) {
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

  bool _checkPaneTheSameAsCurrent(PanelPrimary panel, PanelPrimary? current) {
    return false;
  }

  void onChanged(String name, dynamic arg) {
    var route = routeNameToType(name);
    onCurrent.add(PanelPrimary(type: route, arg: arg));
    NavigatorRep().onCheckPopAllowed = null;
  }

  void onDidPop() {
    if (navKey.currentState?.canPop() == false) {
      onCurrent.add(null);
    }
  }

  PageTypePrimary routeNameToType(String? name) {
    for (var it in PageTypePrimary.values) {
      if (it.name == name) {
        return it;
      }
    }
    return PageTypePrimary.main;
  }
}

class PanelRouterBlocSecondary {
  final onGoto = PublishSubject<PanelSecondary?>();
  final onCurrent = BehaviorSubject<PanelSecondary?>();
  final navKey = GlobalKey<NavigatorState>();
  late NavigatorObserverCustom observer;

  void goto(PanelSecondary panel) {
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

  bool _checkPaneTheSameAsCurrent(
      PanelSecondary panel, PanelSecondary? current) {
    return false;
  }

  void onChanged(String name, dynamic arg) {
    var route = routeNameToType(name);
    onCurrent.add(PanelSecondary(type: route, arg: arg));
    NavigatorRep().onCheckPopAllowed = null;
  }

  void onDidPop() {
    if (navKey.currentState?.canPop() == false) {
      onCurrent.add(null);
    }
  }

  PageTypeSecondary routeNameToType(String? name) {
    for (var it in PageTypeSecondary.values) {
      if (it.name == name) {
        return it;
      }
    }
    return PageTypeSecondary.home;
  }
}
