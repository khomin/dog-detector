import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:loggy/loggy.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static String homeDir = '';
  static const tag = 'fileUtils';

  static Future init() async {
    try {
      if (homeDir.isEmpty) {
        homeDir = await FileUtils._getLocalFolder();
      }
      await createFolder(homeDir);
    } catch (ex) {
      logWarning('$tag: init error [$ex]');
    }
    return null;
  }

  static Future<bool> isResourcesReady() async {
    try {
      if (await File('$homeDir/database.db').exists() &&
          await File('$homeDir/sentences.db').exists()) {
        return true;
      }
    } catch (ex) {
      logWarning('$tag: error [$ex]');
    }
    return false;
  }

  static Future<String> _getLocalFolder() async {
    var path = '';
    switch (Platform.operatingSystem) {
      case 'linux':
      case 'macos':
        path = Platform.environment['HOME'] ?? '/';
        path = '$path/${Constants.localFolderName}';
        break;
      case 'windows':
        path = Platform.environment['USERPROFILE'] ?? '/';
        path = '$path/${Constants.localFolderName}';
        break;
      case 'android':
        var dir = await getExternalStorageDirectory();
        path = dir?.path ?? '/';
        break;
      case 'ios':
        var dir = await getApplicationDocumentsDirectory();
        var dirStr = dir.path;
        await Directory(dirStr).create(recursive: true);
        path = dirStr;
        path = '$path/${Constants.localFolderName}';
        break;
      default:
        path = '/';
    }
    return path;
  }

  static Future copyResourcesToDir() async {
    Uint8List? bytesMain;
    Uint8List? bytesSen;
    {
      final data = await rootBundle.load('assets/database.db');
      bytesMain =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    {
      final data = await rootBundle.load('assets/sentences.db');
      bytesSen =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }

    await Future.wait([
      saveBufToFile(bytesMain, '$homeDir/database.db'),
      saveBufToFile(bytesSen, '$homeDir/sentences.db')
    ]);
    return null;
  }

  Future writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return null;
  }

  static Future<String?> getDowloadPath(String name) async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
    } else {
      dir = await getDownloadsDirectory();
    }
    if (dir == null) return null;
    var path = '${dir.path}/$name';
    return path;
  }

  static Future createFolder(String path) async {
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
  }

  static Future deleteFolder(String path) async {
    if (await Directory(path).exists()) {
      await Directory(path).delete(recursive: true);
    }
  }

  static Future<String?> saveFileToDownloads(String path, String name) async {
    // copy the file to download
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      var dir = await getDownloadsDirectory();
      if (dir == null) return null;
      var pathToFile = '${dir.path}/$name';
      await copyFile(path, pathToFile);
      return pathToFile;
    } else {
      var dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        var dir_ = await getExternalStorageDirectory();
        if (dir_ != null) {
          dir = dir_;
        }
      }
      var pathToFile = '${dir.path}/$name';
      await copyFile(path, pathToFile);
      return pathToFile;
    }
  }

  static Future<bool> copyFile(String srcPath, String destPath) async {
    await File(srcPath).copy(destPath);
    return true;
  }

  static Future<File> saveBufToFile(List<int> data, String filePath) async {
    var outFile = await File(filePath).create(recursive: true);
    return await outFile.writeAsBytes(data);
  }

  static String getExtension(String url) {
    try {
      return '.${url.split('.').last}';
    } catch (e) {
      return '';
    }
  }

  static Future<Uint8List> readFileToBuf(String path) async {
    var file = File(path);
    return await file.readAsBytes();
  }

  static Future<List<String>> readFileToStringLine(String path) async {
    var file = File(path);
    return await file.readAsLines();
  }

  static Future changeEpubToTxt(String dirSource, String dirOut) async {
    var dir = Directory(dirSource);
    var list = dir.listSync();
    var count = 0;
    handle(String path) async {
      var res = await Process.run(
          'mutool', ['convert', '-o', '$dirOut/$count.txt', path]);
      count++;
      logDebug(res);
    }

    for (var it in list) {
      if (it is Directory) {
        var list2 = it.listSync();
        for (var it2 in list2) {
          var ext = FileUtils.getExtension(it2.path);
          if (ext.isNotEmpty) {
            if (ext == '.epub') {
              await handle(it2.path);
            }
          }
        }
      } else {
        var ext = FileUtils.getExtension(it.path);
        if (ext.isNotEmpty) {
          if (ext == '.epub') {
            await handle(it.path);
          }
        }
      }
    }
    // mutool convert -o /home/khomin/Downloads/test.txt /home/khomin/Downloads/other/2155000/e81d94fc2036403d7a98fc2b4a99cdc7.epub
  }

  static Future convertEpub(
      {required String fromDir, required String toDir}) async {
    try {
      await changeEpubToTxt(fromDir, toDir);
    } catch (ex) {
      logWarning('$tag: convert error [$ex]');
    }
    return null;
  }
}
