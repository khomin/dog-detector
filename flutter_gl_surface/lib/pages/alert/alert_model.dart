import 'package:flutter/material.dart';

class AlertModel with ChangeNotifier {
  var useSound = false;
  String? sound;
  var soundList = <String>[];

  var usePacket = false;
  var packetValue = 'TCP';
  var packetList = <String>['TCP', 'UDP'];
  String? packetToAddr;

  void setUseSound(bool v) {
    if (useSound != v) {
      useSound = v;
      notifyListeners();
    }
  }

  void setSound(String? v) {
    if (sound != v) {
      sound = v;
      notifyListeners();
    }
  }

  void setSoundList(List<String> list) {
    if (soundList != list) {
      soundList = list;
      notifyListeners();
    }
  }

  void setUsePacket(bool v) {
    if (usePacket != v) {
      usePacket = v;
      notifyListeners();
    }
  }

  void setPacketValue(String v) {
    if (packetValue != v) {
      packetValue = v;
      notifyListeners();
    }
  }

  void setPacketToAddr(String? v) {
    if (packetToAddr != v) {
      packetToAddr = v;
      notifyListeners();
    }
  }
}
