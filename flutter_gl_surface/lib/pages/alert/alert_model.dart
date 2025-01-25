import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/settings_rep.dart';

class AlertModel with ChangeNotifier {
  var useSound = false;
  Sound? sound;
  var sounds = <Sound>[];

  var usePacket = false;
  var packetValue = 'TCP';
  var packetList = <String>['TCP', 'UDP'];
  String? packetToAddr;

  void setSound(Sound? v) {
    if (sound != v) {
      sound = v;
      useSound = v != null;
      SettingsRep().setSoundUsed(v);
      notifyListeners();
    }
  }

  void setSoundList(List<Sound> list) {
    if (sounds != list) {
      sounds = list;
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
