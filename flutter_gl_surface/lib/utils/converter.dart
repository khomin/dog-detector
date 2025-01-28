import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:loggy/loggy.dart';

class Converter {
  static String convertBytesToKbMbGb(Int64 bytes) {
    String res;
    int gbSize = 1024 * 1024 * 1024;
    int mbSize = 1024 * 1024;
    int kbSize = 1024;
    if (bytes > gbSize) {
      res = '${(bytes.toDouble() / 1000000000).toStringAsFixed(2)} Gb';
    } else if (bytes > mbSize) {
      res = '${(bytes.toDouble() / 1000000).toStringAsFixed(0)} Mb';
    } else if (bytes > kbSize) {
      res = '${(bytes.toDouble() / 1000).toStringAsFixed(0)} Kb';
    } else {
      res = "$bytes B";
    }
    return res;
  }

  static String convertBitRate(double bitrate) {
    String res;
    int gbSize = 1024 * 1024 * 1024;
    int mbSize = 1024 * 1024;
    int kbSize = 1024;
    double gbSizePart = 1024 * 1024 * 1024 / 10;
    double mbSizePart = 1024 * 1024 / 10;
    double kbSizePart = 1024 / 10;
    if (bitrate > gbSize) {
      res = '${((bitrate / gbSizePart) / 10).round().toStringAsFixed(0)} Gb/s';
    } else if (bitrate > mbSize) {
      res = '${((bitrate / mbSizePart) / 10).round().toStringAsFixed(0)} Mb/s';
    } else if (bitrate > kbSize) {
      res = '${((bitrate / kbSizePart) / 10).round().toStringAsFixed(0)} Kb/s';
    } else {
      res = "${bitrate.toStringAsFixed(0)} bit/s";
    }
    return res;
  }

  static String hexToIp4(int ip) {
    String res = '';
    try {
      var data = ByteData(4);
      data.setUint32(0, ip);
      var raw = InternetAddress.fromRawAddress(Uint8List.sublistView(data));
      res = raw.address;
    } catch (_) {
      logWarning('parse ip error');
    }
    return res;
  }
}
