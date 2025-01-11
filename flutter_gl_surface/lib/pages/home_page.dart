import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/home/history_grid_dialog.dart';
import 'package:flutter_demo/pages/home/history_item.dart';
import 'package:flutter_demo/pages/home/history_view_dialog.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

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
              const SliverAppBar(
                  backgroundColor: Constants.colorBar,
                  toolbarHeight: kToolbarHeight,
                  flexibleSpace: FlexibleSpaceBar(
                      title: Row(children: [
                        Padding(
                            padding: EdgeInsets.only(left: 25),
                            child:
                                Text('Home', style: TextStyle(fontSize: 25))),
                        Spacer(),
                      ]),
                      centerTitle: true)),
              SliverToBoxAdapter(child: _header()),
              //
              // -
              // DecoratedSliver(
              //     decoration: const BoxDecoration(
              //       color: Constants.colorBgUnderCard,
              //     ),
              //     sliver: _gallery())
              // SliverFillRemaining(
              //     // fillOverscroll: false,
              //     // fillOverscroll: true,
              //     // hasScrollBody: false,
              //     // child: _gallery()
              SliverToBoxAdapter(child: _gallery())
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
                  decoration: const BoxDecoration(
                      color: Constants.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))))),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  height: 50,
                  decoration: BoxDecoration(
                      // color: Colors.red,
                      color: Constants.colorBgUnderCard,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        )
                      ]),
                  child: Row(children: [
                    const Padding(
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
                                                      const BorderRadius.all(
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

  Widget _gallery() {
    return Builder(builder: (context) {
      var history =
          context.select<AppModel, List<HistoryRecord>>((v) => v.history);
      return Container(
          height: ((270 + 28) * history.length).toDouble(),
          decoration: const BoxDecoration(color: Constants.colorBgUnderCard),
          width: 300,
          child: history.isEmpty
              ? const Center(child: Text('No history yet'))
              : CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                      SliverList.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            // if (index == 10 - 1) {
                            //   return Padding(
                            //       padding: const EdgeInsets.only(bottom: 20.0),
                            //       child: _item1());
                            // }
                            var model = history[index];
                            return HistoryItem(
                                history: model,
                                onPressed: () {
                                  HistoryGridDialog()
                                      .show(
                                          context: context,
                                          models: model.items,
                                          // animationTicker: this,
                                          initialIndex: index)
                                      .then((value) {});
                                });
                          })
                    ]));
    });
  }
}
