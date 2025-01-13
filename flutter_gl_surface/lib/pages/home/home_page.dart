import 'dart:async';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/pages/home/grid_dialog.dart';
import 'package:flutter_demo/pages/home/view_item1.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final _scrollCtr = ScrollController();
  final _focus = FocusNode();
  // var _test = false;
  late final Animation<double> _width;
  late final Animation<double> _opacity;
  late AnimationController _ctrSlideTop;
  late AnimationController _ctrShakeIcon;
  late final Animation<double> _iconRotate;
  final _dispStream = DisposableStream();

  @override
  void initState() {
    super.initState();

    _ctrSlideTop = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _width = Tween<double>(
      begin: kToolbarHeight,
      end: kToolbarHeight * 3,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _ctrShakeIcon = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _iconRotate = TweenSequence<double>([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.005, end: 0), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.005, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _ctrShakeIcon.view,
      curve: Curves
          .linear, // Use a linear curve for a consistent back-and-forth movement
    ));

    _scrollCtr.addListener(() {
      _focus.unfocus();
    });

    Future.microtask(() async {
      await _fetch();
      if (!mounted) return;
      if (context.read<AppModel>().history.isEmpty) {
        Timer(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          if (_ctrShakeIcon.isForwardOrCompleted) {
            _ctrShakeIcon.reverse().orCancel;
          } else {
            _ctrShakeIcon.forward().orCancel;
          }
        });
      }
    });
  }

  Future _fetch() async {
    var history = await MyRep().getHistory();
    if (!mounted) return;
    context.read<AppModel>().setHistory(history);
  }

  @override
  void dispose() {
    _scrollCtr.dispose();
    _dispStream.dispose();
    super.dispose();
  }

  void _handleOnSlide() {
    if (_ctrSlideTop.isForwardOrCompleted) {
      _ctrSlideTop.reverse().orCancel;
    } else {
      _ctrSlideTop.forward().orCancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    var v = kToolbarHeight;
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
          CustomScrollView(
              physics: const ClampingScrollPhysics(),
              controller: _scrollCtr,
              slivers: [
                AnimatedBuilder(
                    animation: _ctrSlideTop,
                    builder: (context, child) {
                      return SliverAppBar(
                          backgroundColor: Constants.colorBar,
                          toolbarHeight: _width.value,
                          // toolbarHeight: _test ? kToolbarHeight * 2 : kToolbarHeight,
                          // expandedHeight: kToolbarHeight,
                          // collapsedHeight: kToolbarHeight,
                          flexibleSpace: Stack(
                              // alignment: Alignment.center,
                              children: [
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Opacity(
                                        opacity: _opacity.value,
                                        // opacity: 1,
                                        child: SizedBox(
                                            height: _width.value / 1.5,
                                            // color: Colors.purple.withOpacity(0.3),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  RoundButton(
                                                      color: Constants
                                                          .colorButtonRed
                                                          .withOpacity(0.8),
                                                      iconColor: Constants
                                                          .colorCard
                                                          .withOpacity(0.8),
                                                      size: 55,
                                                      radius: 20,
                                                      useScaleAnimation: true,
                                                      iconData:
                                                          Icons.delete_outline,
                                                      onPressed: (v) {
                                                        MyRep()
                                                            .setCaptureActive(
                                                                false);
                                                        _handleOnSlide();
                                                      }),
                                                  const SizedBox(width: 15),
                                                  RoundButton(
                                                      color: Constants
                                                          .colorSecondary
                                                          .withOpacity(0.8),
                                                      iconColor: Constants
                                                          .colorCard
                                                          .withOpacity(0.8),
                                                      size: 55,
                                                      radius: 20,
                                                      useScaleAnimation: true,
                                                      iconData: Icons.close,
                                                      onPressed: (v) {
                                                        _handleOnSlide();
                                                      })
                                                ])))),
                                Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    // right: 0,
                                    child: Container(
                                        color: Constants.colorBar,
                                        height: kToolbarHeight,
                                        child: Row(children: [
                                          Container(
                                              width: 100,
                                              // color: Colors.yellow,
                                              margin: const EdgeInsets.only(
                                                  left: 25),
                                              child: const Text('Home',
                                                  style: TextStyle(
                                                    // fontFamily: 'Sulphur',
                                                    fontSize: 25,
                                                    // color: Colors.black38,
                                                    // fontWeight: FontWeight.bold
                                                  ))),
                                          //
                                          // duration
                                          HoverClick(
                                              onPressedL: (p0) async {
                                                _handleOnSlide();
                                              },
                                              child: SizedBox(
                                                  width: 130,
                                                  height: 50,
                                                  // color: Colors.orange,
                                                  // margin: const EdgeInsets.only(
                                                  //     left: 20),
                                                  child: RepaintBoundary(
                                                      child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                        StreamBuilder(
                                                            stream: MyRep()
                                                                .onCaptureTime,
                                                            initialData: MyRep()
                                                                .onCaptureTime
                                                                .valueOrNull,
                                                            builder: (context,
                                                                snapshot) {
                                                              var duration =
                                                                  snapshot.data;
                                                              return AnimatedContainer(
                                                                  duration:
                                                                      Duration
                                                                          .zero,
                                                                  width: duration ==
                                                                          null
                                                                      ? 10
                                                                      : 130,
                                                                  height:
                                                                      duration ==
                                                                              null
                                                                          ? 10
                                                                          : 30,
                                                                  child: RoundBox(
                                                                      text: duration
                                                                              ?.duration
                                                                              .format() ??
                                                                          '',
                                                                      color: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              211,
                                                                              19,
                                                                              5)
                                                                          .withOpacity(
                                                                              0.8),
                                                                      borderRadius:
                                                                          40));
                                                            }),
                                                        // Positioned(
                                                        //     bottom: 0, child: Text('1'))
                                                      ])))),
                                          const Spacer(),
                                          // RoundButton(
                                          //     color: Colors.transparent,
                                          //     iconColor: Constants.colorTextAccent
                                          //         .withOpacity(0.8),
                                          //     size: 70,
                                          //     iconData: Icons.close_sharp,
                                          //     onPressed: (p0) async {
                                          //       var model =
                                          //           context.read<AppModel>();
                                          //       model.setCollapse(!model.collapse);
                                          //     })
                                        ])))
                              ]));
                    }),
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
              ])
        ]));
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 60,
        // color: Colors.pink,
        child: Stack(children: [
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
                              RoundButton(
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
      if (history.isEmpty) {
        return RotationTransition(
            turns: _iconRotate,
            child: SizedBox(
                // height: double.infinity, //((270 + 28) * history.length).toDouble(),
                // decoration: const BoxDecoration(color: Constants.colorBgUnderCard),
                height: NavigatorRep().size.height / 1.5,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RoundButton(
                          iconData: Icons.create_new_folder_rounded,
                          color: Constants.colorPrimary,
                          iconColor: Constants.colorBar,
                          // iconColor: Constants.colorBgUnderCard,
                          size: (NavigatorRep().size.width / 5) + 15,
                          iconSize: NavigatorRep().size.width / 5,
                          useScaleAnimation: true,
                          onPressed: (p0) {
                            // _handleOnSlide();
                            if (_ctrShakeIcon.isForwardOrCompleted) {
                              _ctrShakeIcon.reverse().orCancel;
                            } else {
                              _ctrShakeIcon.forward().orCancel;
                            }
                          }),
                      const SizedBox(height: 20),
                      const Text('There are no entries yet',
                          style: TextStyle(
                              color: Constants.colorTextAccent, fontSize: 18)),
                      // const SizedBox(height: 5),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Click',
                                style: TextStyle(
                                    color: Constants.colorTextAccent,
                                    fontSize: 18)),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Icon(Icons.create_new_folder_rounded,
                                    color: Constants.colorTextSecond
                                        .withOpacity(0.5))),
                            // Padding(
                            //     padding: EdgeInsets.only(left: 2, right: 8),
                            //     child: Text('Capture',
                            //         style: TextStyle(
                            //             color: Colors.black45, fontSize: 18))),
                            const Text('to start',
                                style: TextStyle(
                                    color: Constants.colorTextAccent,
                                    fontSize: 18))
                          ])
                    ])));
      }
      return SizedBox(
          height: ((270 + 28) * history.length).toDouble(),
          // decoration: const BoxDecoration(color: Constants.colorBgUnderCard),
          width: 300,
          child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                SliverList.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      var model = history[index];
                      return ViewItem1(
                          history: model,
                          onPressed: () {
                            GridDialog()
                                .show(
                                    context: context,
                                    models: model.items,
                                    // animationTicker: this,
                                    initialIndex: index)
                                .then((value) {});
                          },
                          onDelete: () async {
                            await MyRep().delete([model]);
                            _fetch();
                          });
                    })
              ]));
    });
  }
}
