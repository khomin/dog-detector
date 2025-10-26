import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCameraButtons extends StatefulWidget {
  const AnimatedCameraButtons({super.key});
  @override
  State<AnimatedCameraButtons> createState() => AnimatedCameraButtonsState();
}

class TabInfo {
  const TabInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class AnimatedCameraButtonsState extends State<AnimatedCameraButtons>
    with TickerProviderStateMixin {
  // final _dispStream = DisposableStream();
  // late RecordModel _model;
  final tag = 'animCameraButtons';

  late final Animation<double> opacity;
  late final Animation<double> _width;
  late final Animation<double> _height;
  late final Animation<double> _borderRadius;
  late final Animation<double> _leftOffset;
  late AnimationController _controller;

  final List<TabInfo> tabs = [
    const TabInfo(
      icon: Icons.info_outline,
      label: 'Mode',
    ),
    const TabInfo(icon: Icons.palette_outlined, label: 'Take image'),
    const TabInfo(icon: Icons.palette_outlined, label: 'Flip'),
  ];

  var tabInfoItems = <Widget>[];

  @override
  void initState() {
    super.initState();

    // // Animate all of the info items in the list:
    // tabInfoItems = tabInfoItems
    //     .animate(interval: 100.ms)
    //     .fadeIn(duration: 200.ms, delay: 300.ms)
    //     .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
    //     .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);

    tabInfoItems = [
      for (final tab in tabs)
        RoundButton(
            color: Constants.colorBgUnderCard.withValues(alpha: 0.3),
            iconColor: Constants.colorCard.withValues(alpha: 0.8),
            size: 55,
            useScaleAnimation: true,
            iconData: Icons.hdr_auto,
            onPressed: (v) async {})
      // Container(
      //   padding: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
      //   color: Colors.transparent,
      //   child: Row(
      //     // crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Icon(tab.icon, color: Constants.colorPrimary),
      //       // const SizedBox(width: 8),
      //       // Flexible(
      //       //   child:
      //       // Text(
      //       //   tab.label,
      //       //   style: const TextStyle(color: Colors.white),
      //       // ),
      //       // ),
      //     ],
      //   ),
      // )
    ];
    tabInfoItems = tabInfoItems
        .animate(interval: 100.ms)
        .fadeIn(duration: 200.ms, delay: 50.ms)
        .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
        .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _width = Tween<double>(
      begin: 55.0,
      end: 120.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.125,
          0.250,
          curve: Curves.ease,
        )));
    _height = Tween<double>(begin: 55.0, end: 100.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.250,
          0.375,
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
  }

  // void _doPlay() {
  //   Timer(Duration(milliseconds: 1), () {
  //     setState(() {
  //       tabInfoItems = [
  //         for (final tab in tabs)
  //           Container(
  //             padding:
  //                 const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
  //             color: Colors.transparent,
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Icon(tab.icon, color: Constants.colorPrimary),
  //                 const SizedBox(width: 8),
  //                 Flexible(
  //                   child: Text(
  //                     tab.label,
  //                     style: const TextStyle(color: Colors.white),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //       ];
  //       tabInfoItems = tabInfoItems
  //           .animate(interval: 50.ms)
  //           .fadeIn(duration: 200.ms, delay: 100.ms)
  //           .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
  //           .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);
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
    _controller.dispose();
    // _dispStream.dispose();
    // _model.setRun(run: false, camera: null, mounted: false);
    // MyRep().stopCamera();
    // WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: tabInfoItems),
    );
  }
}
