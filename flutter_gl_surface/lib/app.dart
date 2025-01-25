import 'package:flutter/cupertino.dart';
import 'package:flutter_demo/components/splash.dart';
import 'package:flutter_demo/pages/main_page.dart';
import 'package:flutter_demo/pages/capture/camera_model.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/home/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
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
    () async {
      Jiffy.setLocale('uk');
      await FileUtils.init();
      Loggy.initLoggy(logPrinter: LogPrinter());
      _appModel.setReady(true);
      _appModel.setHistory(await MyRep().getHistory());
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
            return const Splash();
          }
          return const MainPage();
        });
  }
}
