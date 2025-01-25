import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:collection/collection.dart';

class HistoryRecord with ChangeNotifier {
  HistoryRecord(
      {required this.date,
      required this.dateHeader,
      required this.dateSub,
      required this.dateMonth,
      required this.items,
      required this.path,
      required this.folderName});
  DateTime date;
  String dateHeader;
  String dateSub;
  String dateMonth;
  String folderName;
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
  final onHistory = BehaviorSubject<List<HistoryRecord>>();
  var historyCache = <HistoryRecord>[];
  Function(String path)? onCapture;
  Function()? onFirstFrame;
  // private
  var _frameSize = const Size(0, 0);
  Timer? _captureTm;
  DateTime? _captureStart;
  Completer<String>? _complCaptOneFrame;
  static const _mainChannel = MethodChannel('main/cmd');
  static const _surfaceChannel = MethodChannel('camera/cmd');

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
          if (path.contains('/service/')) {
            _complCaptOneFrame?.complete(path);
            _complCaptOneFrame = null;
          } else {
            onCapture?.call(path);
          }
          getHistory();
          break;
        case 'onMovement':
          logDebug('BTEST_onMovement');
          break;
        case 'onFirstFrameNotify':
          logDebug('BTEST_onFirstFrameNotify');
          onFirstFrame?.call();
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
          await _mainChannel.invokeMethod('get_cameras', <String, dynamic>{});
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
    } catch (e) {
      logError('$tag: error: $e');
    }
    return cameraMap;
  }

  Future<void> initRender() async {
    try {
      await _surfaceChannel.invokeMethod('init_render', <String, dynamic>{});
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
      var r = await _mainChannel.invokeMethod('start_camera', <String, dynamic>{
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
      await _mainChannel.invokeMethod('stop_camera', <String, dynamic>{});
    } on PlatformException catch (e) {
      logError('$tag: error: ${e.message}');
    }
  }

  Future<void> updateConfiguration(
      {required int minArea,
      required int captureIntervalSec,
      required bool showAreaOnCapture}) async {
    try {
      await _mainChannel.invokeMethod('update_configuration', <String, dynamic>{
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

  Future<void> setCaptureActive(bool v) async {
    if (captureActive != v) {
      captureActive = v;
      if (captureActive) {
        _captureStart = DateTime.now();
        _captureTm = Timer.periodic(const Duration(seconds: 1), (timer) {
          var duration = (_captureStart?.difference(DateTime.now()).abs()) ??
              Duration.zero;
          onCaptureTime.add(CaptureTime(duration: duration, isFirstEv: false));
        });
        onCaptureTime
            .add(CaptureTime(duration: const Duration(), isFirstEv: true));
      } else {
        _captureTm?.cancel();
        _captureStart = null;
        onCaptureTime.add(null);
      }
      try {
        await _mainChannel.invokeMethod(
            'set_capture_active', <String, dynamic>{'active': captureActive});
      } catch (e) {
        logError('$tag: set capture active ex: $e');
      }
    }
  }

  Future<List<HistoryRecord>> getHistory() async {
    var path = '${FileUtils.homeDir}/gallery/';
    historyCache = [];
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
        var folderName = file.parent.path;
        mapByYear[date.year]?[dateJiffy.dayOfYear]?.add(HistoryRecord(
            date: date,
            dateHeader: header,
            dateSub: sub,
            dateMonth: Common().monthString(date.month),
            folderName: folderName,
            items: [],
            path: file.path));
      }
      mapByYear.forEach((key, valueYear) {
        valueYear.forEach((key, valueDayOfYear) {
          valueDayOfYear.sort((a, b) {
            return a.date.compareTo(b.date);
          });
          var item = valueDayOfYear.first;
          var folderName = File(item.path).parent.path;
          historyCache.add(HistoryRecord(
              date: valueDayOfYear.first.date,
              dateHeader: item.dateHeader,
              dateSub: item.dateSub,
              dateMonth: item.dateMonth,
              folderName: folderName,
              items: valueDayOfYear,
              path: item.path));
        });
      });
      historyCache.sort((a, b) {
        return b.date.compareTo(a.date);
      });
    } catch (ex) {
      logWarning('$tag: ex');
    }
    onHistory.add(historyCache);
    return historyCache;
  }

  Future<String> captureOneFrame({bool serviceFrame = false}) async {
    var completer = Completer<String>();
    try {
      await _mainChannel.invokeMethod('capture_one_frame',
          <String, dynamic>{'service_frame': serviceFrame});
    } catch (e) {
      logError('$tag: capture one frame ex: $e');
    }
    _complCaptOneFrame?.complete('');
    _complCaptOneFrame = completer;
    return completer.future;
  }

  Future<void> deleteHistoryRoot(List<HistoryRecord> list) async {
    var removeItems = <HistoryRecord>[];
    for (var it in list) {
      for (var it2 in it.items) {
        try {
          removeItems.add(it2);
        } catch (ex) {
          logWarning('$tag: delete [$ex]');
        }
      }
    }
    for (var it in removeItems) {
      // get root item in cache
      var cacheItem = historyCache.firstWhereOrNull((h1) {
        return h1.folderName == it.folderName;
      });
      cacheItem?.items.removeWhere((element) {
        return element.path == it.path;
      });
      await File(it.path).delete();
    }
    historyCache.removeWhere((element) {
      return element.items.isEmpty;
    });
    onHistory.add(historyCache);
  }

  Future<void> deleteHistory2(List<HistoryRecord> list) async {
    if (list.isEmpty) return;
    for (var it in list) {
      var v = historyCache.firstWhereOrNull((element) {
        return element.folderName == it.folderName;
      });
      try {
        await File(it.path).delete();
        v?.items.removeWhere((element) {
          return element.path == it.path;
        });
      } catch (ex) {
        logWarning('$tag: delete [$ex]');
      }
    }
    onHistory.add(historyCache);
  }

  void share(List<HistoryRecord> list) {
    if (list.isEmpty) return;
    var listPath = <XFile>[];
    for (var it in list) {
      listPath.add(XFile(it.path));
    }
    Share.shareXFiles(listPath, text: 'Check out this image!');
  }

  Future<List<Sound>> getSounds() async {
    var list = <Sound>[];
    try {
      var r = await _mainChannel
          .invokeMethod('get_system_sounds', <String, dynamic>{});
      r.forEach((key, value) {
        list.add(Sound(name: value['name'], uri: value['uri']));
      });
    } catch (e) {
      logError('$tag: error: $e');
    }
    return list;
  }

  Future<bool> playSound({required String sound}) async {
    try {
      var r = await _mainChannel.invokeMethod(
          'play_system_sound', <String, dynamic>{'id': sound}) as bool;
      return r;
    } catch (e) {
      logError('$tag: error: $e');
    }
    return false;
  }
}

class Sound {
  Sound({required this.name, required this.uri});
  final String name;
  final String uri;
}
