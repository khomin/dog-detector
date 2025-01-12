import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/animated_camera_button.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';

class HistoryRecord with ChangeNotifier {
  HistoryRecord({
    required this.date,
    required this.dateHeader,
    required this.dateSub,
    required this.dateMonth,
    required this.items,
    required this.path,
    // this.selection = false
  });
  DateTime date;
  String dateHeader;
  String dateSub;
  String dateMonth;
  String path;
  List<HistoryRecord> items;
  bool get selection => _selection;
  set selection(bool v) {
    _selection = v;
    notifyListeners();
  }

  bool _selection = false;
}

class Camera {
  Camera(
      {required this.id,
      required this.facing,
      required this.sensor,
      required this.size});
  final String id;
  final String facing;
  final int sensor;
  final Size size;
}

class CaptureTime {
  CaptureTime({required this.duration, required this.isFirstEv});
  Duration duration;
  bool isFirstEv;
}

class MyRep {
  var cameraMap = <String, Camera>{};
  final onCameraChanged = BehaviorSubject<void>();
  bool captureActive = false;
  final onFrameSize = BehaviorSubject<Size>.seeded(const Size(0, 0));
  final onCaptureTime = BehaviorSubject<CaptureTime?>();
  var _frameSize = const Size(0, 0);
  // private
  Timer? _captureTm;
  DateTime? _captureStart;
  Duration? _captureDuration;
  static const _cameraChannel = MethodChannel('camera/cmd');
  static const _mainChannel = MethodChannel('main/cmd');

  static MyRep? _instance;
  MyRep._internal();
  factory MyRep() {
    if (_instance == null) {
      var i = MyRep._internal();
      i._init();
      _instance = i;
    }
    return _instance!;
  }
  final tag = 'myRep';

  void _init() {
    _mainChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onCapture':
          var path = call.arguments['path'] as String;
          logDebug('BTEST_onCapture: $path');
          break;
        case 'onMovement':
          logDebug('BTEST_onMovement');
          break;
      }
    });
  }

  Future<void> registerView() async {
    try {
      await _mainChannel.invokeMethod('register_view', <String, dynamic>{});
    } catch (e) {
      logError('$tag: error: $e');
    }
  }

  Future<Map<String, Camera>> getCameras() async {
    try {
      var r =
          await _cameraChannel.invokeMethod('get_cameras', <String, dynamic>{});
      r.forEach((key, value) {
        var camera = Camera(
            id: key,
            facing: value['facing'],
            sensor: value['sensor'],
            size: Size((value['width'] as int).toDouble(),
                (value['height'] as int).toDouble()));
        if (value['facing'] == 'Back') {
          cameraMap['back'] = camera;
        } else if (value['facing'] == 'Front') {
          cameraMap['front'] = camera;
        }
      });
      onCameraChanged.add(null);
      return cameraMap;
      // await _cameraChannel
      //     .invokeMethod('init_render', <String, dynamic>{'1': '1'});
      // // await _cameraChannel.invokeMethod('get_cameras', <String, dynamic>{});
    } catch (e) {
      logError('$tag: error: $e');
    }
    return cameraMap;
  }

  Future<void> initRender() async {
    try {
      await _cameraChannel.invokeMethod('init_render', <String, dynamic>{});
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
  }

  Future<void> startCamera(
      {required String id,
      required int minArea,
      required int captureIntervalSec,
      required bool showAreaOnCapture}) async {
    try {
      var r =
          await _cameraChannel.invokeMethod('start_camera', <String, dynamic>{
        'id': id,
        'minArea': minArea,
        'captureIntervalSec': captureIntervalSec,
        'showAreaOnCapture': showAreaOnCapture
      });
      _frameSize = Size((r['size_width'] as int).toDouble(),
          (r['size_height'] as int).toDouble());
      onFrameSize.add(_frameSize);
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
  }

  Future stopCamera() async {
    try {
      await _cameraChannel.invokeMethod('stop_camera', <String, dynamic>{});
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
  }

  Future<void> updateConfiguration(
      {required int minArea,
      required int captureIntervalSec,
      required bool showAreaOnCapture}) async {
    try {
      await _cameraChannel
          .invokeMethod('update_configuration', <String, dynamic>{
        'minArea': minArea,
        'captureIntervalSec': captureIntervalSec,
        'showAreaOnCapture': showAreaOnCapture
      });
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
  }

  Future<int> getDeviceSensor() async {
    try {
      var rotation = await _mainChannel
          .invokeMethod('get_device_sensor', <String, dynamic>{});
      return rotation;
    } catch (e) {
      logError('$tag: error: $e');
    }
    return 0;
  }

  void setCaptureActive(bool v) {
    if (captureActive != v) {
      captureActive = v;
      if (captureActive) {
        _captureStart = DateTime.now();
        _captureTm = Timer.periodic(const Duration(seconds: 1), (timer) {
          var duration = (_captureStart?.difference(DateTime.now()).abs()) ??
              Duration.zero;
          onCaptureTime.add(CaptureTime(duration: duration, isFirstEv: false));
          _captureDuration = duration;
        });
        _captureDuration = const Duration();
        onCaptureTime
            .add(CaptureTime(duration: const Duration(), isFirstEv: true));
      } else {
        _captureTm?.cancel();
        _captureStart = null;
        _captureDuration = null;
        onCaptureTime.add(null);
      }
    }
  }

  Future<List<HistoryRecord>> history() async {
    var history = <HistoryRecord>[];
    var path = '${FileUtils.homeDir}/gallery/';
    try {
      var dir = Directory(path);
      var folders = dir.listSync();
      var mapByYear = <int, Map<int, List<HistoryRecord>>>{};
      var allFiles = <FileSystemEntity>[];
      for (var folder in folders) {
        var files = Directory(folder.path).listSync();
        allFiles.addAll(files);
        for (var file in files) {
          var name = FileUtils.getFileName(file.path);
          var date = Common().parseFileNameToDate(name);
          var dayOfYear = Jiffy.parseFromDateTime(date).dayOfYear;
          if (mapByYear[date.year] == null) {
            mapByYear[date.year] = <int, List<HistoryRecord>>{};
          }
          mapByYear[date.year]?[dayOfYear] = [];
        }
      }
      var now = DateTime.now();
      for (var file in allFiles) {
        var name = FileUtils.getFileName(file.path);
        var date = Common().parseFileNameToDate(name);
        String header = '';
        String sub = '';
        var dateJiffy = Jiffy.parseFromDateTime(date);
        var jiffyNow = Jiffy.parseFromDateTime(now);

        // same year & month & day:
        //   header = Monday
        //   sub    = Today
        if (dateJiffy.year == jiffyNow.year &&
            dateJiffy.dayOfYear == jiffyNow.dayOfYear) {
          header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
          sub = 'Today';
        } else if (dateJiffy.year == jiffyNow.year &&
            dateJiffy.month == jiffyNow.month) {
          // same year & month:
          //   header = Monday
          //   sub    = x days ago
          header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
          var dayAgo = jiffyNow.dateTime.day - date.day;
          sub = dayAgo == 1 ? '$dayAgo day ago' : '$dayAgo days ago';
        } else {
          // other year:
          //   header = Monday
          //   sub    = year
          header = Common().dayOfWeekString(dateJiffy.dayOfWeek);
          sub = dateJiffy.year.toString();
        }
        mapByYear[date.year]?[dateJiffy.dayOfYear]?.add(HistoryRecord(
            date: date,
            dateHeader: header,
            dateSub: sub,
            dateMonth: Common().monthString(date.month),
            items: [],
            path: file.path));
      }
      mapByYear.forEach((key, valueYear) {
        valueYear.forEach((key, valueDayOfYear) {
          valueDayOfYear.sort((a, b) {
            return a.date.compareTo(b.date);
          });
          var item = valueDayOfYear.first;
          history.add(HistoryRecord(
              date: valueDayOfYear.first.date,
              dateHeader: item.dateHeader,
              dateSub: item.dateSub,
              dateMonth: item.dateMonth,
              items: valueDayOfYear,
              path: item.path));
        });
      });
      history.sort((a, b) {
        return b.date.compareTo(a.date);
      });
    } catch (ex) {
      logWarning('$tag: ex');
    }
    return history;
  }

  void takeImage() {
    // TODO: image
  }

  void share(List<HistoryRecord> list) {
    // tODO: share
  }

  void delete(List<HistoryRecord> list) {
    // TODO: delete
  }

  // Future<List<HistoryRecord>> history() async {
  //   var history = <HistoryRecord>[];
  //   var path = '${FileUtils.homeDir}/history/';
  //   try {
  //     var dir = Directory(path);
  //     var folders = dir.listSync();
  //     // top lavel
  //     for (var it in folders) {
  //       var dir2 = Directory(it.path);
  //       var files = dir2.listSync();
  //       // files
  //       for (var it2 in files) {
  //         history.add(HistoryRecord(
  //             date: DateTime.now(), dateNice: 'Yesterday', path: it2.path));
  //       }
  //     }
  //   } catch (ex) {
  //     logWarning('$tag: ex');
  //   }
  //   return history;
  // }
}
