import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/click_detector.dart';
import 'package:flutter_demo/components/slidable_item.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';

class ViewItem1 extends StatefulWidget {
  const ViewItem1(
      {required this.history,
      required this.onPressed,
      required this.onDelete,
      this.onCloseSlide,
      this.size,
      this.padding,
      this.showText = true,
      this.useSwipe = true,
      super.key});
  final HistoryRecord history;
  final Function() onPressed;
  final Function() onDelete;
  final Size? size;
  final EdgeInsets? padding;
  final bool showText;
  final bool useSwipe;
  final BehaviorSubject<bool>? onCloseSlide;
  @override
  State<ViewItem1> createState() => ViewItem1State();
}

class ViewItem1State extends State<ViewItem1> with TickerProviderStateMixin {
  late final SlidableController _slideCtr;
  late AnimationController _controller;
  late final Animation<double> _width;
  final _dispStream = DisposableStream();

  @override
  void initState() {
    super.initState();
    _slideCtr = SlidableController(this);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    _width = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeOut)));

    var closeStream = widget.onCloseSlide;
    if (closeStream != null) {
      _dispStream.add(closeStream.listen((value) async {
        if (value) {
          if (_slideCtr.animation.isCompleted) {
            await _controller.forward().orCancel;
            _slideCtr.close();
          }
        }
      }));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideCtr.dispose();
    _dispStream.dispose();
    super.dispose();
  }

  void _onClick() async {
    if (_slideCtr.animation.isCompleted) {
      logDebug('BTEST_onTapUp: skip because slide is open');
      await _controller.forward().orCancel;
      _slideCtr.close();
      return;
    }
    widget.onPressed();
  }

  void _onLongClick() async {
    if (_controller.isForwardOrCompleted) {
      await _controller.reverse().orCancel;
    } else {
      await _controller.forward().orCancel;
      // if slide open
      if (_slideCtr.animation.isCompleted) {
      } else {
        _slideCtr.openEndActionPane();
      }
    }
  }

  Widget _swipe(Widget child) {
    return SlidableItem(
        controller: _slideCtr,
        onSlided: () {},
        button: RoundButton(
            color: Constants.colorButtonRed.withValues(alpha: 0.8),
            iconColor: Constants.colorCard.withValues(alpha: 0.8),
            size: 55,
            radius: 20,
            useScaleAnimation: true,
            iconData: Icons.delete_outline,
            onPressed: (v) {
              _slideCtr.close();
              widget.onDelete();
            }),
        direction: SlideDirection.right,
        child: child);
  }

  Widget _card() {
    var history = widget.history;
    var itemPath = history.items.lastOrNull?.path;
    return ClickDetector(
        onClick: () {
          _onClick();
        },
        onLongClick: () {
          _onLongClick();
        },
        child: ScaleTransition(
            scale: _width,
            child: Container(
                margin: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 5),
                decoration: BoxDecoration(
                    color: Constants.colorCard,
                    boxShadow: [
                      BoxShadow(
                          color: Constants.colorPrimary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
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
                                                .withValues(alpha: 0.5),
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
                                                        .withValues(alpha: 0.5),
                                                    fontSize: 16,
                                                    // fontFamily: 'Salsa',
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            //
                                            // second line (Year)
                                            Text(history.dateSub,
                                                style: const TextStyle(
                                                    color: Constants
                                                        .colorTextSecond,
                                                    fontSize: 12,
                                                    // fontFamily: 'Salsa',
                                                    fontWeight:
                                                        FontWeight.w600))
                                          ]))),
                          const Spacer(),
                          Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(children: [
                                Icon(Icons.photo_library_sharp,
                                    size: 18,
                                    color: Constants.colorTextAccent
                                        .withValues(alpha: 0.5)),
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
                          if (itemPath != null)
                            ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.file(File(itemPath),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover)),
                          // test data
                          // Text(widget.history.date.toString())
                        ]))
                  ])
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (widget.useSwipe) {
        return _swipe(_card());
      }
      return _card();
    });
  }
}
