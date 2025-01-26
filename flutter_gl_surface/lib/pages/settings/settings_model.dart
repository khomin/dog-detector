import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/settings_rep.dart';
import 'package:loggy/loggy.dart';
import 'package:collection/collection.dart';

class SettingsModel with ChangeNotifier {
  var useSound = false;
  Sound? sound;
  var sounds = <Sound>[];

  var usePacket = false;
  var packetValue = 'TCP';
  final packetList = <String>['TCP', 'UDP'];
  String? packetToAddr;
  final tag = 'alertModel';

  Future<void> initData() async {
    // whether sound used
    Sound? usedSound = await SettingsRep().getSoundUsed();
    // all system sounds
    setSoundList(await MyRep().getSounds());
    if (sounds.isNotEmpty) {
      if (usedSound != null) {
        // check if used is in system sounds
        var found = sounds.firstWhereOrNull((it) {
          return it.uri == usedSound.uri;
        });
        if (found != null) {
          setSound(found);
        } else {
          // take first default
          setSound(sounds.first);
          SettingsRep().setSoundUsed(sounds.first);
        }
      }
    } else {
      logError('$tag: no sounds');
    }
    // whether use packet sending
    // await SettingsRep().get
    Packet? packetUri = await SettingsRep().getPacketUriUsed();
    if (packetUri != null) {
      setPacketToAddr(v: packetUri.address, saveConfig: false);
      setUsePacket(value: true, saveConfig: false);
      setPacketValue(v: packetUri.tcp ? 'TCP' : 'UDP', saveConfig: false);
    } else {
      setUsePacket(value: false, saveConfig: false);
    }
  }

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
      if (value && saveConfig) {
        SettingsRep().setPacketUri(
            packet ?? Packet(address: '192.168.1.1', tcp: true, udp: false));
      } else if (saveConfig) {
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
            address: packetToAddr ?? '',
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
            address: v,
            tcp: packetValue == 'TCP' ? true : false,
            udp: packetValue == 'UDP' ? true : false));
      }
      notifyListeners();
    }
  }
}
