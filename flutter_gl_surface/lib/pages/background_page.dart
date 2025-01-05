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
          Column(children: [
            Container(
                color: Constants.colorBar,
                height: kToolbarHeight,
                child: Row(children: [
                  const Padding(
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
                      color: Colors.transparent,
                      iconColor: Constants.colorTextAccent.withOpacity(0.8),
                      size: 70,
                      iconData: Icons.close_sharp,
                      onPressed: (p0) async {
                        // await Future.delayed(
                        // const Duration(milliseconds: 20));
                        var model = context.read<AppModel>();
                        model.setCollapse(!model.collapse);
                      })
                ])),
            Builder(builder: (context) {
              var collapse = context.select<AppModel, bool>((v) => v.collapse);
              if (collapse) {
                return Container(
                    margin: EdgeInsets.only(
                        top: (NavigatorRep().size.height / 3) - kToolbarHeight),
                    height: 50,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        spreadRadius: 10,
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      )
                    ]));
              }
              return const SizedBox();
            })
          ])
        ]));
  }
}
