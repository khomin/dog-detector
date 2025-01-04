// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/components/history_item_thumb.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final _scrollCtr = ScrollController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _fetch();
      _scrollCtr.addListener(() {
        _focus.unfocus();
      });
    });
  }

  Future _fetch() async {
    var history = await MyRep().history();
    if (!mounted) return;
    context.read<AppModel>().setHistory(history);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.colorBar,
        body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            controller: _scrollCtr,
            slivers: [
              SliverAppBar(
                  backgroundColor: Constants.colorBar,
                  toolbarHeight: kToolbarHeight,
                  flexibleSpace: const FlexibleSpaceBar(
                      title: Row(children: [
                        Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Recent',
                                style: TextStyle(
                                  // fontFamily: 'Salsa',
                                  fontSize: 25,
                                  // fontStyle: FontStyle.italic,
                                  // color: Colors.white,
                                  // fontWeight: FontWeight.bold
                                  // fontWeight: FontWeight.w400
                                )))
                      ]),
                      centerTitle: true)),
              SliverToBoxAdapter(child: _header()),
              DecoratedSliver(
                  decoration: const BoxDecoration(
                    color: Constants.colorBackgroundUnderCard,
                  ),
                  sliver: SliverList.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        if (index == 10 - 1) {
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: _item1());
                        }
                        return _item1();
                      }))
            ]));
  }

  Widget _header() {
    return Container(
        width: 300,
        height: 60,
        // color: Colors.pink,
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
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 50,
                  decoration: BoxDecoration(
                      // color: Colors.red,
                      color: Constants.colorBackgroundUnderCard,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        )
                      ]),
                  child: Row(children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Icon(
                          Icons.search_outlined,
                          color: Constants.colorTextSecond,
                          size: 28,
                        )),
                    Flexible(
                        child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Row(children: [
                              Flexible(
                                  child: TextField(
                                      controller: TextEditingController(),
                                      focusNode: _focus,
                                      maxLines: 1,
                                      decoration: InputDecoration.collapsed(
                                          hintText: 'Search, tag',
                                          hintStyle: TextStyle(
                                              color: Constants.colorTextSecond
                                                  .withOpacity(0.4),
                                              fontSize: 16,
                                              fontFamily: 'Sulphur',
                                              fontWeight: FontWeight.bold)),
                                      style: TextStyle(
                                          color: Constants.colorTextSecond
                                              .withOpacity(0.8),
                                          fontSize: 16,
                                          fontFamily: 'Sulphur',
                                          fontWeight: FontWeight.bold),
                                      cursorColor: Constants.colorTextSecond)),
                              CircleButton(
                                  iconData: Icons.calendar_month,
                                  color: Colors.transparent,
                                  iconSize: 28,
                                  iconColor: Constants.colorTextAccent
                                      .withOpacity(0.5),
                                  onPressed: (_) async {
                                    showModalBottomSheet(
                                        context: context,
                                        barrierColor: Colors.black26,
                                        builder: (BuildContext context) {
                                          return Container(
                                              decoration: BoxDecoration(
                                                  color: Constants.colorCard,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 0),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Center(
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                    CalendarDatePicker2(
                                                        config:
                                                            CalendarDatePicker2Config(
                                                          calendarType:
                                                              CalendarDatePicker2Type
                                                                  .multi,
                                                        ),
                                                        value: [DateTime.now()],
                                                        onValueChanged:
                                                            (dates) {
                                                          // _dates = dates
                                                        })
                                                  ])));
                                        });
                                  })
                            ])))
                  ])))
        ]));
  }

  Widget _item1() {
    return Builder(builder: (context) {
      var history =
          context.select<AppModel, List<HistoryRecord>>((v) => v.history);
      return Container(
          margin:
              const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 5),
          decoration: BoxDecoration(
              color: Constants.colorCard,
              boxShadow: [
                BoxShadow(
                  // color: Colors.black.withOpacity(0.2),
                  color: Constants.colorBar.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: 270,
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
                                        color: Constants.colorTextAccent
                                            .withOpacity(0.5),
                                        fontSize: 16,
                                        // fontFamily: 'Salsa',
                                        fontWeight: FontWeight.bold)),
                                Text('DEC',
                                    style: TextStyle(
                                        color: Constants.colorTextSecond,
                                        fontSize: 12,
                                        fontFamily: 'Salsa',
                                        fontWeight: FontWeight.w600))
                              ])),
                      Padding(
                          padding: EdgeInsets.only(left: 10),
                          child:
                              //
                              SizedBox(
                                  // width: 50,
                                  height: 50,
                                  // color: Colors.pink,
                                  // decoration: BoxDecoration(
                                  //     color: Constants.colorBackgroundUnderCard,
                                  //     borderRadius:
                                  //         BorderRadius.all(Radius.circular(10))),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Saturday',
                                            style: TextStyle(
                                                color: Constants.colorTextAccent
                                                    .withOpacity(0.5),
                                                fontSize: 16,
                                                // fontFamily: 'Salsa',
                                                fontWeight: FontWeight.bold)),
                                        Text('2024',
                                            style: TextStyle(
                                                color:
                                                    Constants.colorTextSecond,
                                                fontSize: 12,
                                                fontFamily: 'Salsa',
                                                fontWeight: FontWeight.w600))
                                      ]))),
                      const Spacer(),
                      Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Row(children: [
                            Icon(Icons.photo_library_sharp,
                                size: 18,
                                color:
                                    Constants.colorTextAccent.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text('64',
                                style: TextStyle(
                                    color: Constants.colorTextSecond,
                                    fontSize: 12,
                                    // fontFamily: 'Salsa',
                                    fontWeight: FontWeight.bold)),
                          ]))
                    ])),
                Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Stack(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(File(history.first.path),
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
}
