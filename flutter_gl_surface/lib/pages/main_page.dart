import 'package:flutter/material.dart';
import 'package:flutter_demo/components/camera_settings_page.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/pages/alert/alert_page.dart';
import 'package:flutter_demo/pages/capture/capture_page.dart';
import 'package:flutter_demo/pages/home/home_page.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/settings/settings_page.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return LayoutBuilder(builder: (context, constraints) {
    // Common().calcLayout(context);
    return Builder(builder: (context) {
      var collapse = context.select<AppModel, bool>((v) => v.collapse);
      var size = MediaQuery.of(context).size;
      return RepaintBoundary(
          child: Container(
              color: Constants.colorBar,
              child: SafeArea(
                  child: Stack(children: [
                const CameraSettingsPage(),
                AnimatedPositioned(
                    duration: Constants.durationPanel,
                    curve: Curves.easeIn,
                    top: collapse ? size.height / 3 : 0,
                    // top: 0,
                    left: 0,
                    right: 0,
                    // bottom: 0,
                    bottom: collapse ? -(size.height / 3) : 0,
                    child: Stack(children: [
                      Scaffold(
                          backgroundColor: Constants.colorBgUnderCard,
                          body: Stack(children: [
                            StreamBuilder(
                                stream: NavigatorRep().routeBloc.onGoto,
                                builder: (context, snapshot) {
                                  var page = snapshot.data?.type;
                                  switch (page) {
                                    case PageType.home:
                                      return const HomePagePage();
                                    case PageType.capture:
                                      return const CapturePage();
                                    case PageType.alert:
                                      return const AlertPage();
                                    case PageType.settings:
                                      return const SettingsPage();
                                    default:
                                      return const HomePagePage();
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
                                            color:
                                                Constants.colorBgUnderCard))))
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
                                          Colors.black.withValues(alpha: 0.2),
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
                                        type: BottomNavigationBarType.fixed,
                                        backgroundColor: Colors.transparent,
                                        // backgroundColor: Constants.colorCard,
                                        unselectedItemColor: Constants
                                            .colorTextSecond
                                            .withValues(alpha: 0.8),
                                        items: const <BottomNavigationBarItem>[
                                          BottomNavigationBarItem(
                                              icon: Icon(Icons.home),
                                              label: 'Home'),
                                          BottomNavigationBarItem(
                                              icon: Icon(Icons
                                                  .create_new_folder_rounded),
                                              label: 'Capture'),
                                          BottomNavigationBarItem(
                                              icon: Icon(Icons.notifications),
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
                                          NavigatorRep().routeBloc.goto(Panel(
                                              type: PageType.values[value]));
                                        });
                                  })))
                    ]))
              ]))));
    });
  }
}
