import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/navigation_observer.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:rxdart/rxdart.dart';

enum PageType {
  main,
  capture,
// alert,
  settings
}

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
  final onLayoutChanged = BehaviorSubject<ScreenType>();

  final routeBloc = PanelRouterBloc();
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

class PanelRouterBloc {
  final onGoto = PublishSubject<Panel?>();
  final onCurrent = BehaviorSubject<Panel?>();

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
    if (current?.type == panel.type) {
      // var room1 = panel.arg?['room'] as ChatRoom?;
      // var room2 = current?.arg?['room'] as ChatRoom?;
      // if (room1 == room2) {
      //   return true;
      // }
    }
    return false;
  }
}

class NavigationService {
  NavigationService({required this.routeBloc, required this.observer});
  final PanelRouterBloc routeBloc;
  late NavigatorObserverCustom observer;
  Function()? onPopCleanUp;
  final navKey = GlobalKey<NavigatorState>();

  void handleOnGo(Panel? panel) async {
    if (panel == null) {
      navKey.currentState?.popUntil((route) => route.isFirst);
      return;
    }
    if (panel.replace) {
      navKey.currentState
          ?.pushReplacementNamed(panel.type.name, arguments: panel.arg);
    } else {
      navKey.currentState?.pushNamed(panel.type.name, arguments: panel.arg);
    }
  }

  void onChanged(String name, dynamic arg) {
    var route = routeNameToType(name);
    routeBloc.onCurrent
        .add(route == PageType.main ? null : Panel(type: route, arg: arg));
    NavigatorRep().onCheckPopAllowed = null;
  }

  void onDidPop() {
    if (navKey.currentState?.canPop() == false) {
      routeBloc.onCurrent.add(null);
    }
    onPopCleanUp?.call();
    onPopCleanUp = null;
  }

  PageType routeNameToType(String? name) {
    for (var it in PageType.values) {
      if (it.name == name) {
        return it;
      }
    }
    return PageType.main;
  }
}
