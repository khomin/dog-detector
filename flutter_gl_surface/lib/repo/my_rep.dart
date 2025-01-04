import 'dart:async';
import 'dart:convert';
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
  Camera({required this.id, required this.facing, required this.sensor});
  final String id;
  final String facing;
  final int sensor;
}

class MyRep {
  var cameraMap = <String, Camera>{};
  final onCameraChanged = BehaviorSubject<void>();
  final onFrameSize = BehaviorSubject<Size>.seeded(const Size(0, 0));
  var _frameSize = const Size(0, 0);
  // private
  static const _cameraChannel = MethodChannel('camera/cmd');
  static const _mainChannel = MethodChannel('main/cmd');

  static MyRep? _instance;
  MyRep._internal();
  factory MyRep() {
    if (_instance == null) {
      var i = MyRep._internal();
      _instance = i;
    }
    return _instance!;
  }
  final tag = 'myRep';

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
        var camera =
            Camera(id: key, facing: value['facing'], sensor: value['sensor']);
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

  Future<void> startCamera(String id) async {
    try {
      var r = await _cameraChannel
          .invokeMethod('start_camera', <String, dynamic>{'id': id});
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

  Future<List<HistoryRecord>> history() async {
    var history = <HistoryRecord>[];
    var path = '${FileUtils.homeDir}/history/';
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
