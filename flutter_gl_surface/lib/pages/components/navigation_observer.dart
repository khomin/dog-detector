import 'package:flutter/cupertino.dart';

class NavigatorObserverCustom extends NavigatorObserver {
  NavigatorObserverCustom({required this.onDidPop, required this.onChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRouteBuilder || route is CupertinoPageRoute) {
      _parse(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRouteBuilder || route is CupertinoPageRoute) {
      _parse(previousRoute);
      onDidPop();
    }
  }

  void _parse(Route? route) {
    onChanged(route?.settings.name ?? '', route?.settings.arguments);
  }

  final Function(String routeName, dynamic arg) onChanged;
  final Function() onDidPop;
}
