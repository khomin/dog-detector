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
  Camera({required this.id, required this.facing});
  final String id;
  final String facing;
}

class MyRep {
  var cameraMap = <String, Camera>{};
  final onCameraChanged = BehaviorSubject<void>();
  var frameSize = const Size(0, 0);
  final onFrameSizeChanged = BehaviorSubject<bool>();
  // private
  static const _cameraChannel = MethodChannel('camera/cmd');
  // static const _mainChannel = MethodChannel('main/cmd');

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

  Future<Map<String, Camera>> getCameras() async {
    try {
      var r = await _cameraChannel
          .invokeMethod('get_cameras', <String, dynamic>{}) as Map;
      r.forEach((key, value) {
        if (value['facing'] == 'Back') {
          cameraMap['back'] = Camera(id: key, facing: value['facing']);
        } else if (value['facing'] == 'Front') {
          cameraMap['front'] = Camera(id: key, facing: value['facing']);
        }
      });
      onCameraChanged.add(null);
      return cameraMap;
    } catch (e) {
      logError('$tag: error starting rende  ring: $e');
    }
    return cameraMap;
  }

  Future<void> startRender(String id) async {
    try {
      var r = await _cameraChannel
          .invokeMethod('start_camera', <String, dynamic>{'id': id});
      // TODO: update frame size
      // setState(() {
      //   _frameSize = Size((r['size_width'] as int).toDouble(),
      //       (r['size_height'] as int).toDouble());
      // });
    } on PlatformException catch (e) {
      logError('$tag: error starting rende  ring: ${e.message}');
    }
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
