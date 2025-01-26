import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/pages/alert/alert_addr_page.dart';
import 'package:flutter_demo/pages/alert/alert_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({this.arg, super.key});
  final HistoryRecord? arg;

  @override
  State<AlertPage> createState() => AlertPageState();
}

class AlertPageState extends State<AlertPage> {
  late AlertModel _model;
  final _fontColor1 = Constants.colorTextAccent;
  final _fontColor2 = Constants.colorTextSecond;
  final _fontSize1 = 15.0;
  final _fontSize2 = 14.0;
  final _fontSize3 = 13.0;
  final _borderColor = const Color.fromARGB(159, 211, 211, 212);
  final _animationDuraton = const Duration(milliseconds: 150);
  final tag = 'aletPage';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      _model.initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<AlertModel>();
    return Scaffold(
        backgroundColor: Constants.colorBar,
        body: Stack(alignment: Alignment.center, children: [
          Positioned(
              top: (kToolbarHeight * 2) - 30,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  decoration: const BoxDecoration(
                      color: Constants.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))))),
          CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [
            SliverAppBar(
                backgroundColor: Constants.colorBar,
                automaticallyImplyLeading: false,
                flexibleSpace: _sliverAppBar()),
            SliverToBoxAdapter(child: _header()),
            DecoratedSliver(
                decoration: const BoxDecoration(
                  color: Constants.colorBgUnderCard,
                ),
                sliver: SliverToBoxAdapter(child: _list()))
          ])
        ]));
  }

  Widget _sliverAppBar() {
    return Stack(children: [
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          // right: 0,
          child: Container(
              color: Constants.colorBar,
              // color: Colors.blueAccent,
              height: kToolbarHeight,
              child: Row(children: [
                Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 25),
                    child: const Text('Alert', style: TextStyle(fontSize: 25))),
                const Spacer()
              ])))
    ]);
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 30,
        child: Stack(children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 40,
                  width: 100,
                  decoration: const BoxDecoration(
                      color: Constants.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)))))
        ]));
  }

  Widget _list() {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Builder(builder: (context) {
            return SizedBox(
                height: NavigatorRep().size.height / 1.5,
                child: Column(children: [
                  ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        //
                        // detection
                        _sound(),
                        //
                        // TCP/UDP
                        _packet()
                      ])
                ]));
          });
        });
  }

  Widget _sound() {
    return Builder(builder: (context) {
      var soundList = context.watch<AlertModel>().sounds;
      var useSound = context.watch<AlertModel>().useSound;
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 30, left: 25, right: 25),
                child: Row(children: [
                  Text('Motion detection',
                      style: TextStyle(
                          color: _fontColor1,
                          fontSize: _fontSize1,
                          fontWeight: FontWeight.w400))
                ])),
            //
            // use sound
            _item(
                height: 80,
                useBorderTop: true,
                useBorderBot: false,
                child: Row(children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Use sound',
                            style: TextStyle(
                                color: _fontColor1,
                                fontSize: _fontSize1,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 4),
                        Text('For every capture',
                            style: TextStyle(
                                color: _fontColor2,
                                fontSize: _fontSize3,
                                fontWeight: FontWeight.w400))
                      ]),
                  const Spacer(),
                  Switch(
                      value: useSound,
                      onChanged: (bool value) {
                        var model = context.read<AlertModel>();
                        if (value) {
                          var i = model.sounds.firstOrNull;
                          model.setSound(i);
                        } else {
                          model.setSound(null);
                        }
                      })
                ])),
            //
            // sound
            AnimatedContainer(
                height: useSound ? 80 : 0,
                duration: _animationDuraton,
                child: AnimatedOpacity(
                    opacity: useSound ? 1 : 0,
                    duration: _animationDuraton,
                    child: _item(
                        height: double.infinity,
                        useBorderTop: true,
                        useBorderBot: false,
                        child: Row(children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sound',
                                    style: TextStyle(
                                        color: _fontColor1,
                                        fontSize: _fontSize1,
                                        fontWeight: FontWeight.w400)),
                                const SizedBox(height: 4),
                                Text('Particular type',
                                    style: TextStyle(
                                        color: _fontColor2,
                                        fontSize: _fontSize3,
                                        fontWeight: FontWeight.w400))
                              ]),
                          const Spacer(),
                          RoundButton(
                              color: Colors.transparent,
                              iconColor: Constants.colorPrimary,
                              size: 70,
                              iconData: Icons.play_circle_fill,
                              onPressed: (p0) async {
                                var sound = context.read<AlertModel>().sound;
                                if (sound == null) return;
                                MyRep().playSound(sound: sound.uri);
                              }),
                          Expanded(
                              flex: 2,
                              child: Row(children: [
                                Expanded(
                                    child: DropdownButton<Sound>(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        value:
                                            context.watch<AlertModel>().sound,
                                        isExpanded: true,
                                        onChanged: (Sound? value) {
                                          context
                                              .read<AlertModel>()
                                              .setSound(value);
                                        },
                                        items: soundList
                                            .map<DropdownMenuItem<Sound>>(
                                                (Sound value) {
                                          return DropdownMenuItem<Sound>(
                                              value: value,
                                              child: Text(value.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: _fontSize2,
                                                      color: Constants
                                                          .colorPrimary)));
                                        }).toList()))
                              ]))
                        ]))))
          ]);
    });
  }

  Widget _packet() {
    return Builder(builder: (context) {
      var usePacket = context.watch<AlertModel>().usePacket;
      var packets = context.watch<AlertModel>().packetList;
      var packet = context.watch<AlertModel>().packetValue;
      var packetToAddr = context.watch<AlertModel>().packetToAddr;
      return Column(children: [
        //
        // send packets
        _item(
            useBorderTop: true,
            useBorderBot: false,
            height: 80,
            child: Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send packets',
                        style: TextStyle(
                            color: _fontColor1,
                            fontSize: _fontSize1,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(height: 4),
                    Text('For every capture',
                        style: TextStyle(
                            color: _fontColor2,
                            fontSize: _fontSize3,
                            fontWeight: FontWeight.w400))
                  ]),
              const Spacer(),
              Switch(
                  value: usePacket,
                  onChanged: (bool value) {
                    context
                        .read<AlertModel>()
                        .setUsePacket(value: value, saveConfig: true);
                  })
            ])),
        //
        // tcp/udp mode
        AnimatedContainer(
            height: usePacket ? 80 : 0,
            duration: _animationDuraton,
            child: AnimatedOpacity(
                opacity: usePacket ? 1 : 0,
                duration: _animationDuraton,
                child: _item(
                    height: double.infinity,
                    useBorderTop: true,
                    useBorderBot: false,
                    child: Row(children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text('TCP/UDP',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: _fontColor1,
                                        fontSize: _fontSize1,
                                        fontWeight: FontWeight.w400))),
                            const SizedBox(height: 4),
                            Flexible(
                                child: Text('One of protocols',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: _fontColor2,
                                        fontSize: _fontSize3,
                                        fontWeight: FontWeight.w400)))
                          ]),
                      const Spacer(),
                      SizedBox(
                          height: 50,
                          child: packets.isNotEmpty
                              ? DropdownButton<String>(
                                  padding: const EdgeInsets.only(right: 6),
                                  value: packet,
                                  onChanged: (String? value) {
                                    if (value == null) return;
                                    context.read<AlertModel>().setPacketValue(
                                        v: value, saveConfig: true);
                                  },
                                  items: packets.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: _fontSize2,
                                                color:
                                                    Constants.colorPrimary)));
                                  }).toList())
                              : const SizedBox())
                    ])))),
        //
        // IP/URI
        AnimatedContainer(
            height: usePacket ? 80 : 0,
            duration: _animationDuraton,
            child: AnimatedOpacity(
                opacity: usePacket ? 1 : 0,
                duration: _animationDuraton,
                child: _item(
                    height: double.infinity,
                    useBorderTop: true,
                    useBorderBot: true,
                    child: Row(children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text('IP/URI',
                                    style: TextStyle(
                                        color: _fontColor1,
                                        fontSize: _fontSize1,
                                        fontWeight: FontWeight.w400))),
                            const SizedBox(height: 4),
                            Flexible(
                                child: Text('Destination address',
                                    style: TextStyle(
                                        color: _fontColor2,
                                        fontSize: _fontSize3,
                                        fontWeight: FontWeight.w400)))
                          ]),
                      const Spacer(),
                      Expanded(
                          flex: 2,
                          child: HoverClick(
                              onPressedL: (p0) {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        settings: const RouteSettings(),
                                        builder: (context) {
                                          return AlertAddrPage(model: _model);
                                        }));
                              },
                              child: SizedBox(
                                  height: 40,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Constants.colorCard,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      width: 150,
                                      child: Center(
                                          child: Text(
                                              packetToAddr ?? 'ex: 192.168.1.1',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color:
                                                      Constants.colorTextSecond,
                                                  fontSize: _fontSize2,
                                                  fontWeight:
                                                      FontWeight.w400)))))))
                    ]))))
      ]);
    });
  }

  Widget _item(
      {required bool useBorderTop,
      required bool useBorderBot,
      required double height,
      required Widget child}) {
    return Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.only(left: 25, right: 25),
        decoration: BoxDecoration(
            border: Border(
                top: useBorderTop
                    ? BorderSide(color: _borderColor, width: 1)
                    : BorderSide.none,
                bottom: useBorderBot
                    ? BorderSide(color: _borderColor, width: 1)
                    : BorderSide.none)),
        child: child);
  }
}
