import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';

class HistoryRecord {
  HistoryRecord(
      {required this.date, required this.dateNice, required this.path});
  DateTime date;
  String dateNice;
  String path;
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

class MyRep {
  var cameraMap = <String, Camera>{};
  final onCameraChanged = BehaviorSubject<void>();
  bool captureActive = false;
  final onFrameSize = BehaviorSubject<Size>.seeded(const Size(0, 0));
  final onCaptureTime = BehaviorSubject<Duration?>();
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
          _captureDuration = _captureStart?.difference(DateTime.now()).abs();
          onCaptureTime.add(_captureDuration);
        });
        _captureDuration = const Duration();
        onCaptureTime.add(_captureDuration);
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
      for (var it in folders) {
        var dir2 = Directory(it.path);
        var files = dir2.listSync();

        var name = FileUtils.getFileName(it.path);
        var date = Common().parseFileNameToDate(name);

        var file = files.firstOrNull;
        if (file != null) {
          // var name = FileUtils.getFileName(file.path);
          // var date = Common().parseFileNameToDate(name);
          history.add(HistoryRecord(
              date: DateTime.now(),
              dateNice: Common().formatDateInt(date.microsecondsSinceEpoch),
              path: file.path));
        }
      }
    } catch (ex) {
      logWarning('$tag: ex');
    }
    return history;
  }

  void takeImage() {
    // TODO: image
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
