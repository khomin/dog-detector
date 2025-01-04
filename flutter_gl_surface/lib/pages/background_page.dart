import 'dart:math';

import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/pages/model/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:collection/collection.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

class BackgroundPage extends StatefulWidget {
  const BackgroundPage({super.key});
  @override
  State<BackgroundPage> createState() => BackgroundPageState();
}

class BackgroundPageState extends State<BackgroundPage> {
  final _dispStream = DisposableStream();
  final _model = RecordModel();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {});
  }

  @override
  void dispose() {
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.colorBar,
        body: Stack(children: [
          CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Container(
                    // color: Colors.redAccent,
                    // color: Constants.colorBar,
                    height: 50,
                    child: Row(children: [
                      Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text('Settings',
                              style: TextStyle(
                                // fontFamily: 'Sulphur',
                                fontSize: 25,
                                // color: Colors.black38,
                                // fontWeight: FontWeight.bold
                              ))),
                      const Spacer(),
                      CircleButton(
                          // color: Colors.transparent,
                          // iconColor: Constants.colorTextAccent.withOpacity(0.8),
                          // size: 70,
                          // // margin: EdgeInsets.only(right: 4),
                          // iconData: Icons.close,
                          color: Colors.transparent,
                          iconColor: Constants.colorTextAccent.withOpacity(0.8),
                          size: 70,
                          // vertTransform: true,
                          // margin: const EdgeInsets.only(left: 10),
                          iconData: Icons.close_sharp,
                          onPressed: (p0) async {
                            await Future.delayed(
                                const Duration(milliseconds: 50));
                            var model = context.read<AppModel>();
                            model.setCollapse(!model.collapse);
                          })
                    ]))),
            // SliverToBoxAdapter(
            //     child: Container(
            //   // color: Colors.blueAccent,
            //   height: 650,
            //   child: _camera(),
            // )),
            // SliverToBoxAdapter(child: _header()),
            // DecoratedSliver(
            //     decoration: const BoxDecoration(
            //         // color: Constants.colorBackgroundUnderCard,
            //         color: Colors.orange),
            //     sliver:
            // SliverFillRemaining(
            //     // fillOverscroll: true,
            //     child: _camera()),
            //     sliver: SliverList.builder(
            //         itemCount: 10,
            //         itemBuilder: (context, index) {
            //           if (index == 10 - 1) {
            //             return Padding(
            //                 padding: const EdgeInsets.only(bottom: 50.0),
            //                 child: _item1());
            //           }
            //           return _item1();
            //         }))
          ]),
          Positioned(
              top: (NavigatorRep().size.height / 3),
              left: 0,
              right: 0,
              child: Container(
                  height: 100,
                  decoration: BoxDecoration(color: Colors.black, boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 0),
                    )
                  ])))
        ]));
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 60,
        child: Stack(children: [
          Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Constants.colorBackgroundUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))))),
        ]));
  }
}
