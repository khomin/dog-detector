import 'package:flutter/material.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/pages/alert/alert_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({this.arg, super.key});
  final HistoryRecord? arg;

  @override
  State<AlertPage> createState() => AlertPageState();
}

class AlertPageState extends State<AlertPage> {
  final _model = AlertModel();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _model.setSound('Loundsound.wav');
      _model.setSoundList(
          ['Loundsound.wav', 'Loundsound2.wav', 'Loundsound3.wav']);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _model.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        // detection sound
                        _motion(),
                        //
                        // TCP/UDP
                        _packet()
                      ])
                ]));
          });
        });
  }

  Widget _motion() {
    return Builder(builder: (context) {
      var soundList = context.watch<AlertModel>().soundList;
      var useSound = context.watch<AlertModel>().useSound;
      return Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
              border: Border(
                  // bottom: BorderSide(
                  //     color: Constants.colorTextSecond
                  //         .withOpacity(0.2),
                  //     width: 1),
                  // top: BorderSide(
                  //     color: Constants.colorTextSecond
                  //         .withOpacity(0.2),
                  //     width: 1)
                  )),
          child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Row(children: [
                      Text('Motion detection',
                          style: TextStyle(
                              color: Constants.colorTextAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w400))
                    ]),
                    Row(children: [
                      const Text('Use sound',
                          style: TextStyle(
                              color: Constants.colorTextSecond,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      const Spacer(),
                      Switch(
                          value: useSound,
                          onChanged: (bool value) {
                            context.read<AlertModel>().setUseSound(value);
                          })
                    ]),
                    Row(children: [
                      const Text('Sound',
                          style: TextStyle(
                              color: Constants.colorTextSecond,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      const Spacer(),
                      SizedBox(
                          height: 50,
                          child: soundList.isNotEmpty
                              ? DropdownButton<String>(
                                  padding: const EdgeInsets.only(right: 6),
                                  value: context.watch<AlertModel>().sound,
                                  onChanged: (String? value) {
                                    context.read<AlertModel>().setSound(value);
                                  },
                                  items: soundList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Constants.colorPrimary
                                              // color:
                                              //     Theme.of(context)
                                              //         .colorScheme
                                              //         .iconColor,
                                              )),
                                    );
                                  }).toList())
                              : const SizedBox())
                    ])
                  ])));
    });
  }

  Widget _packet() {
    // return const SizedBox(height: 10),
    return Builder(builder: (context) {
      var usePacket = context.watch<AlertModel>().usePacket;
      var packets = context.watch<AlertModel>().packetList;
      var packet = context.watch<AlertModel>().packetValue;
      var packetToAddr = context.watch<AlertModel>().packetToAddr;
      return Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Constants.colorTextSecond.withOpacity(0.2),
                      width: 1),
                  top: BorderSide(
                      color: Constants.colorTextSecond.withOpacity(0.2),
                      width: 1))),
          child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(children: [
                      const Text('Send packets',
                          style: TextStyle(
                              color: Constants.colorTextSecond,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      const Spacer(),
                      Switch(
                          value: usePacket,
                          onChanged: (bool value) {
                            context.read<AlertModel>().setUsePacket(value);
                          })
                    ]),
                    Row(children: [
                      const Text('TCP/UDP',
                          style: TextStyle(
                              color: Constants.colorTextSecond,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      const Spacer(),
                      SizedBox(
                          height: 50,
                          child: packets.isNotEmpty
                              ? DropdownButton<String>(
                                  padding: const EdgeInsets.only(right: 6),
                                  value: packet,
                                  onChanged: (String? value) {
                                    context.read<AlertModel>().setSound(value);
                                  },
                                  items: packets.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color:
                                                    Constants.colorPrimary)));
                                  }).toList())
                              : const SizedBox())
                    ]),
                    //
                    // IP/URI
                    Row(children: [
                      const Text('IP/URI',
                          style: TextStyle(
                              color: Constants.colorTextSecond,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      const Spacer(),
                      Expanded(
                          flex: 2,
                          child: HoverClick(
                              onPressedL: (p0) {
                                showModalBottomSheet(
                                    context: context,
                                    barrierColor: Colors.black26,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: 200,
                                        color: Constants.colorBgUnderCard,
                                      );
                                    });
                              },
                              child: SizedBox(
                                  height: 40,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Constants.colorCard,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      width: 150,
                                      child: Center(
                                          child: Text(packetToAddr ?? 'Unused',
                                              style: TextStyle(
                                                  color:
                                                      Constants.colorTextSecond,
                                                  fontSize: 15,
                                                  // fontFamily: 'Sulphur',
                                                  // fontWeight: FontWeight.bold
                                                  fontWeight:
                                                      FontWeight.w400)))))))
                    ])
                  ])));
    });
  }
}
