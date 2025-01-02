import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/history_item_thumb.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _fetch();
    });
  }

  Future _fetch() async {
    var history = await MyRep().history();
    if (!mounted) return;
    context.read<AppModel>().setHistory(history);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await _fetch();
        },
        // child: Container(
        //     color: Constants.colorBackground,
        //     // margin: const EdgeInsets.only(top: 20),
        //     height: double.infinity,
        //     child: Column(children: [
        //       // top bar
        child: Container(
            color: Constants.colorBar,
            child: Stack(children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      height: kToolbarHeight,
                      color: Constants.colorBar,
                      // decoration: BoxDecoration(
                      //     color: Constants.colorCard,
                      //     borderRadius:
                      //         BorderRadius.only(topLeft: Radius.circular(30))),
                      child: Row(children: [
                        const Spacer(),
                        Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(30)),
                            margin: const EdgeInsets.only(left: 10, right: 20))
                      ]))),
              Positioned(
                  top: kToolbarHeight + 10,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: Constants.colorBackgroundUnderCard,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [_item1()])))
            ])));
  }

  Widget _item1() {
    return Builder(builder: (context) {
      var history =
          context.select<AppModel, List<HistoryRecord>>((v) => v.history);
      return Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 100),
          decoration: const BoxDecoration(
              color: Constants.colorCard,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: 260,
          child: Column(children: [
            if (history.isNotEmpty)
              Column(children: [
                // header
                Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: Row(children: [
                      Container(
                          width: 50,
                          height: 50,
                          // color: Colors.pink,
                          decoration: BoxDecoration(
                              color: Constants.colorBackgroundUnderCard,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('28',
                                    style: TextStyle(
                                        color: Constants.colorTextSecond,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text('DEC',
                                    style: TextStyle(
                                        color: Constants.colorTextSecond,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600))
                              ])),
                      // Icon(Icons.info_outline, size: 18),
                      Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Saturday',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400)))
                    ])),
                Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20.0), // Set the radius here
                        child: Image.file(File(history.first.path),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover)))
                // body
                // _itemSubLine(
                //     text: 'Sessions',
                //     value: '${history.length}',
                //     firstLine: true),
                // _itemSubLine(text: 'Images', value: '450', firstLine: false),
                // _itemSubLine(text: 'Storage', value: '4.5Gb', firstLine: false)
              ]),
            // history.isNotEmpty
            //     ? Container(
            //         // color: Colors.pink,
            //         height: 60,
            //         width: double.infinity,
            //         margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
            //         child: Row(children: [
            //           ListView.builder(
            //               scrollDirection: Axis.horizontal,
            //               shrinkWrap: true,
            //               itemCount: history.length,
            //               itemBuilder: (context, index) {
            //                 var i = history[index];
            //                 return HistoryItemThumbnail(
            //                     history: i,
            //                     padding: const EdgeInsets.only(right: 2),
            //                     size: const Size(50, 50),
            //                     onPressed: () {
            //                       NavigatorRep().routeBloc.goto(
            //                           Panel(type: PageType.history, arg: i));
            //                     });
            //               })
            //         ]))
            //     : const Flexible(
            //         child: Center(child: Text("You don't have history yet")))
          ]));
    });
  }

  Widget _itemSubLine(
      {required String text, required String value, required bool firstLine}) {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 10, top: firstLine ? 15 : 5),
        child: Row(children: [
          SizedBox(
              width: 100,
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Constants.colorTextSecond.withOpacity(0.7)))),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Constants.colorTextSecond.withOpacity(0.7)))
        ]));
  }
}
