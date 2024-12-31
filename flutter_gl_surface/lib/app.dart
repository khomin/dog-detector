import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/account_page.dart';
import 'package:flutter_demo/pages/history_page.dart';
import 'package:flutter_demo/pages/main_page.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/pages/record_page.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
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
      // NavigatorRep().routeBloc.goto(Panel(type: PageType.main));
      _appModel.setReady(true);
    }();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppModel>.value(
        value: _appModel,
        builder: (context, child) {
          if (!context.select<AppModel, bool>((v) => v.ready)) {
            return const SizedBox();
          }
          return LayoutBuilder(builder: (context, constraints) {
            Common().calcLayout(context);
            return Container(
                color: Colors.white,
                child: SafeArea(
                    child: Scaffold(
                        backgroundColor: Colors.white,
                        body: StreamBuilder(
                            stream: NavigatorRep().routeBloc.onGoto,
                            builder: (context, snapshot) {
                              var page = snapshot.data?.type;
                              var arg = snapshot.data?.arg;
                              switch (page) {
                                case PageType.main:
                                  return const MainPage();
                                case PageType.record:
                                  return const RecordPage();
                                case PageType.history:
                                  return HistoryPage(arg: arg);
                                case PageType.settings:
                                  return const AccountPage();
                                default:
                                  // return HistoryPage(arg: arg);
                                  return const RecordPage();
                              }
                            }),
                        bottomNavigationBar: StreamBuilder(
                            stream: NavigatorRep().routeBloc.onGoto,
                            builder: (context, snapshot) {
                              var page = snapshot.data?.type;
                              return BottomNavigationBar(
                                  selectedFontSize: 12,
                                  unselectedFontSize: 12,
                                  type: BottomNavigationBarType.fixed,
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  items: const <BottomNavigationBarItem>[
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.home), label: 'Home'),
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.camera),
                                        label: 'Record'),
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.history),
                                        label: 'History'),
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.settings),
                                        label: 'Settings'),
                                  ],
                                  currentIndex: page?.index ?? 0,
                                  selectedItemColor: Colors.blueAccent,
                                  onTap: (value) {
                                    NavigatorRep().routeBloc.goto(
                                        Panel(type: PageType.values[value]));
                                  });
                            }))));
          });
        });
  }
}
