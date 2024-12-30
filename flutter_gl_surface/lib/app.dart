import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/account_page.dart';
import 'package:flutter_demo/pages/history_page.dart';
import 'package:flutter_demo/pages/main_page.dart';
import 'package:flutter_demo/pages/record_page.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/file_utils.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  var _page = PageType.main;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    () async {
      await FileUtils.init();
      setState(() {
        _ready = true;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox();
    }
    return LayoutBuilder(builder: (context, constraints) {
      Common().calcLayout(context);
      return Container(
          color: Colors.white,
          child: SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Builder(builder: (context) {
                    switch (_page) {
                      case PageType.main:
                        return const MainPage();
                      case PageType.record:
                        return const RecordPage();
                      case PageType.history:
                        return const HistoryPage();
                      case PageType.account:
                        return const AccountPage();
                    }
                  }),
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                          activeIcon: Icon(Icons.home)),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.camera),
                          activeIcon: Icon(Icons.home),
                          label: 'Record'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.history),
                          activeIcon: Icon(Icons.home),
                          label: 'History'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings),
                          activeIcon: Icon(Icons.home),
                          label: 'Settings'),
                    ],
                    currentIndex: _page.index,
                    selectedItemColor: Colors.blueAccent,
                    onTap: (value) {
                      setState(() {
                        _page = PageType.values[value];
                      });
                    },
                  ))));
    });
  }
}
