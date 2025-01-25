import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/settings_rep.dart';

class AlertModel with ChangeNotifier {
  var useSound = false;
  Sound? sound;
  var sounds = <Sound>[];

  var usePacket = false;
  var packetValue = 'TCP';
  final packetList = <String>['TCP', 'UDP'];
  String? packetToAddr;

  void setInitial() {}

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

  void setUsePacket(
      {required bool value, required bool saveConfig, Packet? packet}) {
    if (usePacket != value) {
      usePacket = value;
      if (value) {
        SettingsRep().setPacketUri(
            packet ?? Packet(uri: '192.168.1.1', tcp: true, udp: false));
      } else {
        SettingsRep().setPacketUri(null);
      }
      notifyListeners();
    }
  }

  void setPacketValue({required String v, required bool saveConfig}) {
    if (packetValue != v) {
      packetValue = v;
      if (saveConfig) {
        SettingsRep().setPacketUri(Packet(
            uri: packetToAddr ?? '',
            tcp: packetValue == 'TCP' ? true : false,
            udp: packetValue == 'UDP' ? true : false));
      }
      notifyListeners();
    }
  }

  void setPacketToAddr({required String? v, required bool saveConfig}) {
    if (packetToAddr != v) {
      packetToAddr = v;
      if (v != null && saveConfig) {
        SettingsRep().setPacketUri(Packet(
            uri: v,
            tcp: packetValue == 'TCP' ? true : false,
            udp: packetValue == 'UDP' ? true : false));
      }
      notifyListeners();
    }
  }
}
