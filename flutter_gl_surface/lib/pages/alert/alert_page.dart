import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({this.arg, super.key});
  final HistoryRecord? arg;

  @override
  State<AlertPage> createState() => AlertPageState();
}

class AlertPageState extends State<AlertPage> {
  @override
  void initState() {
    super.initState();
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
                    child: const Text('Alert',
                        style: TextStyle(
                          fontSize: 25,
                        ))),
                const Spacer()
              ])))
    ]);
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 60,
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
    return Builder(builder: (context) {
      return SizedBox(
          height: NavigatorRep().size.height / 1.5,
          child: Column(children: [
            ListView(
                padding: EdgeInsets.only(left: 20, right: 20),
                shrinkWrap: true,
                children: [
                  // TODO: alert sound
                  Row(children: [Text('Sound')]),
                  // TODO: alert send tcp/udp packet
                  Row(children: [Text('Send TCP/UDP packet')])
                ])
          ]));
    });
  }
}
