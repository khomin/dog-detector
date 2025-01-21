import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/components/navigation_observer.dart';
import 'package:flutter_demo/components/splash.dart';
import 'package:flutter_demo/pages/main_page.dart';
import 'package:flutter_demo/pages/model/camera_model.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/pages/model/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:flutter_demo/utils/log_printer.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late AppModel _appModel;

  @override
  void initState() {
    super.initState();
    _appModel = AppModel();

    NavigatorRep().routeBlocPrimary.observer =
        NavigatorObserverCustom(onDidPop: () {
      NavigatorRep().routeBlocPrimary.onDidPop();
    }, onChanged: (name, arg) {
      NavigatorRep().routeBlocPrimary.onChanged(name, arg);
    });

    () async {
      Jiffy.setLocale('uk');
      await FileUtils.init();
      Loggy.initLoggy(logPrinter: LogPrinter());
      _appModel.setReady(true);
      _appModel.setHistory(await MyRep().getHistory());

      NavigatorRep()
          .routeBlocPrimary
          .navKey
          .currentState
          ?.pushNamed(PageTypePrimary.main.name);
    }();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppModel>.value(value: _appModel),
          ChangeNotifierProvider<RecordModel>(
              create: (context) => RecordModel()),
          ChangeNotifierProvider<CameraModel>(
              create: (context) => CameraModel())
        ],
        builder: (context, child) {
          return PopScope(
              canPop: Platform.isIOS,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                var k = NavigatorRep().routeBlocPrimary.onCurrent.valueOrNull;
                if (k?.type == PageTypePrimary.main) {
                  SystemNavigator.pop();
                  return;
                }
                var navKey = NavigatorRep().routeBlocPrimary.navKey;
                if (navKey.currentState?.canPop() == true) {
                  // optional handler (to stop selection etc)
                  var popHandle = NavigatorRep().onCheckPopAllowed;
                  var pop = await popHandle?.call() ?? true;
                  if (pop) {
                    navKey.currentState?.pop();
                    // when no items notify RouteNavigator that no active panels in view
                    if (navKey.currentState?.canPop() == false) {
                      NavigatorRep().routeBlocPrimary.fullPop();
                    }
                  }
                } else {
                  SystemNavigator.pop();
                }
              },
              child: Navigator(
                  key: NavigatorRep().routeBlocPrimary.navKey,
                  initialRoute: PageTypePrimary.logo.name,
                  observers: [NavigatorRep().routeBlocPrimary.observer],
                  onGenerateRoute: (RouteSettings settings) {
                    final route = NavigatorRep()
                        .routeBlocPrimary
                        .routeNameToType(settings.name);
                    switch (route) {
                      case PageTypePrimary.logo:
                        return PageRouteBuilder(
                            settings: settings,
                            pageBuilder: (_, __, ___) {
                              return const Splash();
                            });
                      case PageTypePrimary.main:
                        return CupertinoPageRoute(
                            settings: settings,
                            builder: (context) {
                              return const MainPage();
                            });
                      default:
                        throw Exception('Invalid route: ${settings.name}');
                    }
                  }));
        });
  }
}
