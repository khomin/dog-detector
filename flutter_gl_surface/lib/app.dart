import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/model/camera_model.dart';
import 'package:flutter_demo/pages/settings_page.dart';
import 'package:flutter_demo/pages/camera_settings_page.dart';
import 'package:flutter_demo/pages/components/hover_click.dart';
import 'package:flutter_demo/pages/alert_page.dart';
import 'package:flutter_demo/pages/home_page.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/pages/capture_page.dart';
import 'package:flutter_demo/pages/model/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:flutter_demo/utils/log_printer.dart';
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

    () async {
      await FileUtils.init();
      Loggy.initLoggy(logPrinter: LogPrinter());
      _appModel.setReady(true);
      // Timer(const Duration(milliseconds: 100), () async {
      //   await MyRep().getCameras();
      // });
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
          if (!context.select<AppModel, bool>((v) => v.ready)) {
            return const SizedBox();
          }
          return LayoutBuilder(builder: (context, constraints) {
            Common().calcLayout(context);
            var collapse = context.select<AppModel, bool>((v) => v.collapse);
            return RepaintBoundary(
                child: Container(
                    color: Constants.colorBar,
                    child: SafeArea(
                        child: Stack(children: [
                      const CameraSettingsPage(),
                      AnimatedPositioned(
                          duration: Constants.durationPanel,
                          curve: Curves.easeIn,
                          top: collapse ? NavigatorRep().size.height / 3 : 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Stack(children: [
                            Scaffold(
                                backgroundColor: Constants.colorBgUnderCard,
                                body: Stack(children: [
                                  StreamBuilder(
                                      stream: NavigatorRep().routeBloc.onGoto,
                                      builder: (context, snapshot) {
                                        var page = snapshot.data?.type;
                                        // var arg = snapshot.data?.arg;
                                        switch (page) {
                                          case PageType.main:
                                            return const MainPage();
                                          case PageType.capture:
                                            return const CapturePage();
                                          // case PageType.alert:
                                          //   return AlertPage(arg: arg);
                                          case PageType.settings:
                                            return const SettingsPage();
                                          default:
                                            return const MainPage();
                                        }
                                      }),
                                  AnimatedOpacity(
                                      opacity: collapse ? 0.5 : 0.0,
                                      duration: Constants.duration,
                                      child: IgnorePointer(
                                          ignoring: !collapse,
                                          child: HoverClick(
                                              onPressedL: (p0) {
                                                context
                                                    .read<AppModel>()
                                                    .setCollapse(false);
                                              },
                                              child: Container(
                                                  color: Constants
                                                      .colorBgUnderCard))))
                                ]),
                                bottomNavigationBar: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Constants.colorCard,
                                        // color: Colors.amber,
                                        // borderRadius: BorderRadius.only(
                                        //     topLeft: Radius.circular(20),
                                        //     topRight: Radius.circular(20)),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 0),
                                          )
                                        ]),
                                    child: StreamBuilder(
                                        stream: NavigatorRep().routeBloc.onGoto,
                                        builder: (context, snapshot) {
                                          var page = snapshot.data?.type;
                                          return BottomNavigationBar(
                                              elevation: 0,
                                              selectedFontSize: 12,
                                              unselectedFontSize: 12,
                                              type:
                                                  BottomNavigationBarType.fixed,
                                              backgroundColor:
                                                  Colors.transparent,
                                              // backgroundColor: Constants.colorCard,
                                              unselectedItemColor: Constants
                                                  .colorTextSecond
                                                  .withOpacity(0.8),
                                              items: const <BottomNavigationBarItem>[
                                                BottomNavigationBarItem(
                                                    icon: Icon(Icons.home),
                                                    label: 'Home'),
                                                BottomNavigationBarItem(
                                                    icon: Icon(Icons
                                                        .photo_camera_front_sharp),
                                                    label: 'Capture'),
                                                BottomNavigationBarItem(
                                                    icon: Icon(
                                                        Icons.notifications),
                                                    label: 'Alert'),
                                                BottomNavigationBarItem(
                                                    icon: Icon(Icons.settings),
                                                    label: 'Settings'),
                                              ],
                                              currentIndex: page?.index ?? 0,
                                              selectedItemColor:
                                                  Constants.colorPrimary,
                                              onTap: (value) async {
                                                if (collapse) {
                                                  context
                                                      .read<AppModel>()
                                                      .setCollapse(false);
                                                }
                                                NavigatorRep().routeBloc.goto(
                                                    Panel(
                                                        type: PageType
                                                            .values[value]));
                                              });
                                        })))
                          ]))
                    ]))));
          });
        });
  }
}
