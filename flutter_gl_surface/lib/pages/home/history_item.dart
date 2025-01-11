import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/hover_click.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';

class HistoryItem extends StatefulWidget {
  const HistoryItem(
      {required this.history,
      required this.onPressed,
      this.size,
      this.padding,
      this.showText = true,
      super.key});
  final HistoryRecord history;
  final Function() onPressed;
  final Size? size;
  final EdgeInsets? padding;
  final bool showText;
  @override
  State<HistoryItem> createState() => HistoryItemState();
}

class HistoryItemState extends State<HistoryItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var history = widget.history;
    return Builder(builder: (context) {
      return HoverClick(
          onPressedL: (_) {
            widget.onPressed();
          },
          child: Container(
              margin: const EdgeInsets.only(
                  left: 25, right: 25, top: 20, bottom: 5),
              decoration: BoxDecoration(
                  color: Constants.colorCard,
                  boxShadow: [
                    BoxShadow(
                      color: Constants.colorBar.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    )
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              height: 270,
              child: Column(children: [
                Column(children: [
                  // header
                  Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: Row(children: [
                        Container(
                            width: 50,
                            height: 50,
                            // color: Colors.pink,
                            decoration: const BoxDecoration(
                                color: Constants.colorBgUnderCard,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //
                                  // day of month
                                  Text('${history.date.day}',
                                      style: TextStyle(
                                          color: Constants.colorTextAccent
                                              .withOpacity(0.5),
                                          fontSize: 16,
                                          // fontFamily: 'Salsa',
                                          fontWeight: FontWeight.bold)),
                                  //
                                  // month in string [DEC]
                                  Text(
                                      history.dateMonth
                                          .toUpperCase()
                                          .substring(0, 3),
                                      style: const TextStyle(
                                          color: Constants.colorTextSecond,
                                          fontSize: 12,
                                          fontFamily: 'Salsa',
                                          fontWeight: FontWeight.w600))
                                ])),
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child:
                                //
                                SizedBox(
                                    height: 50,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          //
                                          // header (Yesterday, Today etc)
                                          Text(history.dateHeader,
                                              style: TextStyle(
                                                  color: Constants
                                                      .colorTextAccent
                                                      .withOpacity(0.5),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          //
                                          // second line (Year)
                                          Text(history.dateSub,
                                              style: const TextStyle(
                                                  color:
                                                      Constants.colorTextSecond,
                                                  fontSize: 12,
                                                  fontFamily: 'Salsa',
                                                  fontWeight: FontWeight.w600))
                                        ]))),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Row(children: [
                              Icon(Icons.photo_library_sharp,
                                  size: 18,
                                  color: Constants.colorTextAccent
                                      .withOpacity(0.5)),
                              const SizedBox(width: 4),
                              //
                              // count of photos
                              Text('${history.items.length}',
                                  style: const TextStyle(
                                      color: Constants.colorTextSecond,
                                      fontSize: 12,
                                      // fontFamily: 'Salsa',
                                      fontWeight: FontWeight.bold)),
                            ]))
                      ])),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: Stack(children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.file(File(history.path),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover)),
                        // Positioned(
                        //     right: 5,
                        //     bottom: 0,
                        //     // top: 0,
                        //     child: Container(
                        //         // margin: EdgeInsets.only(top: 20, bottom: 20),
                        //         decoration: BoxDecoration(
                        //             // color: Colors.yellow,
                        //             // color: Constants.colorBackgroundUnderCard
                        //             //     .withOpacity(0.2),
                        //             borderRadius: BorderRadius.all(
                        //                 Radius.circular(10))),
                        //         child: Row(children: [
                        //           // Icon(Icons.image, color: Colors.white),
                        //           Image.file(File(history.first.path),
                        //               width: 80, height: 80),
                        //           Image.file(File(history.first.path),
                        //               width: 80, height: 80),
                        //           Image.file(File(history.first.path),
                        //               width: 80, height: 80),
                        //         ])))
                        // Positioned(
                        //     right: 0,
                        //     bottom: 0,
                        //     child: Image.file(File(history.first.path),
                        //         width: 80, height: 80)),
                        // Positioned(
                        //     right: 0,
                        //     bottom: 40,
                        //     child: Image.file(File(history.first.path),
                        //         width: 80, height: 80)),
                        // Positioned(
                        //     right: 0,
                        //     bottom: 80,
                        //     child: Image.file(File(history.first.path),
                        //         width: 80, height: 80))
                      ]))
                ])
              ])));
    });
  }
}
