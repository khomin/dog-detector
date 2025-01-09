import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/button_round_corner.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/components/hover_click.dart';
import 'package:flutter_demo/pages/components/my_cliper.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/pages/model/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/repo/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExpandModel with ChangeNotifier {
  bool isExpanded = false;
  void setExpanded(bool v) {
    if (isExpanded != v) {
      isExpanded = v;
      notifyListeners();
    }
  }
}

class AnimatedCameraButton extends StatefulWidget {
  const AnimatedCameraButton(
      {required this.onCapture, required this.onStop, super.key});
  final Function() onCapture;
  final Function() onStop;
  @override
  State<AnimatedCameraButton> createState() => AnimatedCameraButtonState();
}

class TabInfo {
  const TabInfo({required this.icon /*, required this.label*/});
  final IconData icon;
  // final String label;
}

class AnimatedCameraButtonState extends State<AnimatedCameraButton>
    with TickerProviderStateMixin {
  // final _dispStream = DisposableStream();
  // late RecordModel _model;
  final tag = 'animCameraButton';

  late final Animation<double> _opacity1;
  late final Animation<double> _opacity2;
  late final Animation<double> width;
  late final Animation<double> height;
  late final Animation<double> widthIcon1;
  late final Animation<double> widthIcon2;
  late final Animation<double> _borderRadius;
  late final Animation<double> _leftOffset;
  late AnimationController _controller;

  final List<TabInfo> tabs = [
    const TabInfo(icon: Icons.info_outline),
    const TabInfo(icon: Icons.palette_outlined),
    // const TabInfo(
    //     icon: Icons.format_list_bulleted,
    //     label: 'Adapters',
    //     description: 'Animations'),
    // const TabInfo(
    //     icon: Icons.grid_on_outlined,
    //     label: 'Kitchen Sink',
    //     description: 'Grid'),
    // const TabInfo(
    //     icon: Icons.science_outlined,
    //     label: 'Playground',
    //     description: 'A blank'),
  ];

  // var tabInfoItems = <Widget>[];

  @override
  void initState() {
    super.initState();

    // // Animate all of the info items in the list:
    // tabInfoItems = tabInfoItems
    //     .animate(interval: 100.ms)
    //     .fadeIn(duration: 200.ms, delay: 300.ms)
    //     .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
    //     .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    width = Tween<double>(
      begin: 70.0,
      end: 150.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.025,
          0.200,
          curve: Curves.ease,
        )));

    height = Tween<double>(begin: 70.0, end: 100.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.250,
          0.375,
          curve: Curves.ease,
        )));

    widthIcon1 = Tween<double>(
      begin: 70.0,
      end: 10.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.055,
          0.200,
          curve: Curves.ease,
        )));

    widthIcon2 = Tween<double>(
      begin: 10.0,
      end: 30.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.055,
          0.200,
          curve: Curves.ease,
        )));

    _borderRadius =
        Tween<double>(begin: 60.0, end: 25.0).animate(CurvedAnimation(
            parent: _controller.view,
            curve: const Interval(
              0.000,
              0.125,
              curve: Curves.ease,
            )
            // curve: Curves.easeInOut,
            ));
    _leftOffset = Tween<double>(begin: 40.0, end: 10.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.150, 0.225, curve: Curves.easeIn)));

    _opacity1 = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.000,
          0.100,
          curve: Curves.ease,
        )
        // curve: Curves.easeInOut,
        ));
    _opacity2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.025,
          0.150,
          curve: Curves.ease,
        )
        // curve: Curves.easeInOut,
        ));
  }

  Future<void> _switchAnimation() async {
    try {
      if (_expandModel.isExpanded) {
        widget.onStop();
      } else {
        widget.onCapture();
      }
      if (_controller.isForwardOrCompleted) {
        // _doStop();
        await _controller.reverse().orCancel;
      } else {
        // _doPlay();
        await _controller.forward().orCancel;
      }
    } on TickerCanceled {
      // The animation got canceled, probably because we were disposed.
    }
  }

  // void _doPlay() {
  //   Timer(Duration(milliseconds: 1), () {
  //     setState(() {
  //       tabInfoItems = [
  //         Container(
  //             // padding:
  //             //     const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
  //             child: Icon(Icons.photo_camera_back_rounded,
  //                 color: Constants.colorCard, size: 30)),
  //         Container(
  //             // padding:
  //             //     const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
  //             child: Icon(Icons.stop_circle,
  //                 color: Constants.colorCard, size: 30)),
  //       ];
  //       tabInfoItems = tabInfoItems
  //           .animate(interval: 500.ms)
  //           .fadeIn(duration: 500.ms, delay: 100.ms)
  //           // .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
  //           // .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);
  //           // .
  //           .move(begin: const Offset(0, -16), curve: Curves.easeOutQuad);
  //     });
  //   });
  // }

  // void _doStop() {
  //   Timer(Duration(milliseconds: 300), () {
  //     setState(() {
  //       tabInfoItems = [];
  //     });
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    // _dispStream.dispose();
    // _model.setRun(run: false, camera: null, mounted: false);
    // MyRep().stopCamera();
    // WidgetsBinding.instance.removeObserver(this);
  }

  var _expandModel = ExpandModel();

  @override
  Widget build(BuildContext context) {
    // return HoverClick(
    //     onPressedL: (_) {
    //       // var model = context.read<RecordModel>();
    //       // model.setModeMenuVisible(!model.modeMenuVisible);
    //       // _playAnimation();
    //       _playAnimation();
    //     },
    //     child:
    //
    return ChangeNotifierProvider<ExpandModel>.value(
        value: _expandModel,
        builder: (context, child) {
          return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                    width: width.value,
                    // width: 70,
                    height: 70,
                    // height: height.value,
                    // margin: const EdgeInsets.only(top: 8, bottom: 8),
                    decoration: const BoxDecoration(
                        color: Constants.colorButton,
                        borderRadius: BorderRadius.all(Radius.circular(90))),
                    child: Stack(alignment: Alignment.center, children: [
                      Opacity(
                          opacity: _opacity1.value,
                          child: Builder(builder: (context) {
                            var expanded = context
                                .select<ExpandModel, bool>((v) => v.isExpanded);
                            return IgnorePointer(
                                ignoring: expanded,
                                child: CircleButton(
                                    color: Constants.colorButtonBg,
                                    iconColor: Colors.red.withOpacity(0.8),
                                    size: widthIcon1.value,
                                    useScaleAnimation: true,
                                    iconSize: 50,
                                    iconData: Icons.radio_button_on,
                                    onPressed: (v) {
                                      _switchAnimation();
                                      Timer(const Duration(milliseconds: 250),
                                          () {
                                        context
                                            .read<ExpandModel>()
                                            .setExpanded(!expanded);
                                      });
                                    }));
                          })),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Opacity(
                                opacity: _opacity2.value,
                                child: Builder(builder: (context) {
                                  var expanded =
                                      context.select<ExpandModel, bool>(
                                          (v) => v.isExpanded);
                                  return IgnorePointer(
                                      ignoring: !expanded,
                                      child: ButtonRoundCorner(
                                          color: Colors.transparent,
                                          colorIcon: Constants.colorCard,
                                          width: width.value / 2,
                                          icon: Icon(
                                              Icons.photo_camera_back_rounded,
                                              color: Constants.colorCard,
                                              size: widthIcon2.value),
                                          radious: const BorderRadius.only(
                                              topLeft: Radius.circular(90),
                                              bottomLeft: Radius.circular(90)),
                                          onPressed: () {
                                            MyRep().takeImage();
                                          }));
                                })),
                            Opacity(
                                opacity: _opacity2.value,
                                child: Builder(builder: (context) {
                                  var expanded =
                                      context.select<ExpandModel, bool>(
                                          (v) => v.isExpanded);
                                  return IgnorePointer(
                                      ignoring: !expanded,
                                      child: ButtonRoundCorner(
                                          color: Colors.transparent,
                                          width: width.value / 2,
                                          colorIcon: Constants.colorCard,
                                          icon: Icon(Icons.stop_circle,
                                              color: Constants.colorCard,
                                              size: widthIcon2.value),
                                          radious: const BorderRadius.only(
                                              topRight: Radius.circular(90),
                                              bottomRight: Radius.circular(90)),
                                          onPressed: () {
                                            _switchAnimation();
                                            Timer(
                                                const Duration(
                                                    milliseconds: 200), () {
                                              context
                                                  .read<ExpandModel>()
                                                  .setExpanded(!expanded);
                                            });
                                          }));
                                }))
                          ])
                    ]));
              });
        });
  }
}
