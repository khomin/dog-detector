import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_demo/utils/file_utils.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';

class HistoryRecord {
  HistoryRecord({required this.date, required this.path});
  DateTime date;
  String path;
}

class MyRep {
  // var history = <HistoryRecord>[];

  // render
  var frameSize = const Size(0, 0);
  final onFrameSizeChanged = BehaviorSubject<bool>();
  // private
  static const _methodChannel = MethodChannel('dev/cmd');
  final tag = 'myRep';

  Future<void> startRender(String id) async {
    try {
      var r = await _methodChannel
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
      // top lavel
      for (var it in folders) {
        var dir2 = Directory(it.path);
        var files = dir2.listSync();
        // files
        for (var it2 in files) {
          history.add(HistoryRecord(date: DateTime.now(), path: it2.path));
        }
      }
    } catch (ex) {
      logWarning('$tag: ex');
    }
    return history;
  }
}
