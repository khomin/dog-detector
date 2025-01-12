import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/components/click_detector.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/selection_repo.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';

class ViewItem2 extends StatefulWidget {
  const ViewItem2(
      {required this.history,
      required this.onPressed,
      required this.size,
      required this.selectionRep,
      this.padding,
      super.key});

  final HistoryRecord history;
  final Function() onPressed;
  final int size;
  final EdgeInsets? padding;
  final SelectionRep selectionRep;
  @override
  State<ViewItem2> createState() => ViewItem2State();
}

class ViewItem2State extends State<ViewItem2> with TickerProviderStateMixin {
  late AnimationController _controller;
  late final Animation<double> _width;
  late final Animation<double> _opacity;
  final _dispStream = DisposableStream();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _controller.addStatusListener((status) {});

    _width = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeOut)));
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.linear)));

    if (widget.history.selection) {
      _scale();
    }

    _dispStream.add(widget.selectionRep.selectedStream.listen((value) {
      if (value == 0) {
        widget.history.selection = false;
        // _controller.forward();
        _controller.reverse().orCancel;
      }
    }));
  }

  void _onClick() async {
    if (widget.selectionRep.selectedCnt == 0) {
      widget.onPressed();
    } else if (widget.history.selection) {
      widget.selectionRep.releaseSelection();
      widget.history.selection = false;
      _scale();
    } else {
      widget.selectionRep.addSelection();
      widget.history.selection = true;
      _scale();
    }
  }

  void _onLongClick() async {
    if (widget.selectionRep.selectedCnt == 0) {
      widget.selectionRep.addSelection();
      widget.history.selection = true;
      _scale();
    } else {
      widget.selectionRep.releaseSelection();
      widget.history.selection = false;
      _scale();
    }
  }

  void _scale() async {
    if (_controller.isForwardOrCompleted) {
      await _controller.reverse().orCancel;
    } else {
      await _controller.forward().orCancel;
    }
  }

  @override
  void dispose() {
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: _width,
        child: Container(
            color: Constants.colorCard,
            child: ClickDetector(
                onClick: () {
                  _onClick();
                },
                onLongClick: () {
                  _onLongClick();
                },
                child: Stack(alignment: Alignment.center, children: [
                  Column(children: [
                    Row(children: [
                      Padding(
                          padding: widget.padding ??
                              const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                          child: Stack(children: [
                            Icon(Icons.image,
                                color: Colors.black12,
                                size: widget.size.toDouble()),
                            Image.file(File(widget.history.path),
                                width: widget.size.toDouble(),
                                height: widget.size.toDouble(),
                                cacheWidth: widget.size * 2,
                                fit: BoxFit.cover)
                          ]))
                    ])
                  ]),
                  AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                            opacity: _opacity.value,
                            child: Icon(Icons.check_circle,
                                size: 40,
                                color: Constants.colorBgUnderCard
                                    .withOpacity(0.7)));
                      })
                ]))));
  }
}
