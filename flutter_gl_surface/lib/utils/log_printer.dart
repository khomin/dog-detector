import 'dart:io';

import 'package:flutter_demo/utils/file_utils.dart';
import 'package:loggy/loggy.dart';
import 'package:intl/intl.dart';

class LogPrinter extends LoggyPrinter {
  LogPrinter({
    this.showColors = true,
  }) {
    () async {
      var path = "${FileUtils.homeDir}/log/";
      String time = DateFormat('yyyy-MM-dd kk-mm--sss').format(DateTime.now());
      path = '${path}ft-$time.txt';
      // create
      try {
        var file = await File(path).create(recursive: true, exclusive: true);
        file.open(mode: FileMode.writeOnlyAppend);
        logFile = file;
      } catch (ex) {
        logError('cannot create log: ${ex.toString()}');
      }
    }();
  }

  final bool? showColors;

  bool get _colorize => showColors ?? false;

  static final _levelColors = {
    LogLevel.debug:
        AnsiColor(foregroundColor: AnsiColor.grey(0.5), italic: true),
    LogLevel.info: AnsiColor(foregroundColor: 35),
    LogLevel.warning: AnsiColor(foregroundColor: 214),
    LogLevel.error: AnsiColor(foregroundColor: 196),
  };

  static final _levelPrefixes = {
    LogLevel.debug: '🐛 ',
    LogLevel.info: '👻 ',
    LogLevel.warning: '⚠️ ',
    LogLevel.error: '‼️ ',
  };

  static const _defaultPrefix = '🤔 ';

  static File? logFile;

  @override
  void onLog(LogRecord record) async {
    final time = record.time.toIso8601String().split('T')[1];
    final callerFrame =
        record.callerFrame == null ? '-' : '(${record.callerFrame?.location})';
    final logLevel = record.level
        .toString()
        .replaceAll('Level.', '')
        .toUpperCase()
        .padRight(1);

    final color =
        _colorize ? levelColor(record.level) ?? AnsiColor() : AnsiColor();
    final prefix = levelPrefix(record.level) ?? _defaultPrefix;

    var msg = color('$prefix$time $logLevel $callerFrame ${record.message}\n');
    try {
      await logFile?.writeAsString(msg, mode: FileMode.append);
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
    // ignore: avoid_print
    print(msg);

    if (record.stackTrace != null) {
      await logFile?.writeAsString(record.stackTrace.toString(),
          mode: FileMode.append);
      // ignore: avoid_print
      print(record.stackTrace);
    }
  }

  String? levelPrefix(LogLevel level) {
    return _levelPrefixes[level];
  }

  AnsiColor? levelColor(LogLevel level) {
    return _levelColors[level];
  }
}
