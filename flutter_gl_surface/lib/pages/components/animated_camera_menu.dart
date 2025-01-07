import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class AnimatedCameraMenu extends StatefulWidget {
  const AnimatedCameraMenu({super.key});
  @override
  State<AnimatedCameraMenu> createState() => AnimatedCameraMenuState();
}

class TabInfo {
  const TabInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class AnimatedCameraMenuState extends State<AnimatedCameraMenu>
    with TickerProviderStateMixin {
  // final _dispStream = DisposableStream();
  // late RecordModel _model;
  final tag = 'animCameraMenu';

  late final Animation<double> opacity;
  late final Animation<double> width;
  late final Animation<double> height;
  late final Animation<double> _borderRadius;
  late final Animation<double> _leftOffset;
  late AnimationController _controller;

  final List<TabInfo> tabs = [
    const TabInfo(
      icon: Icons.info_outline,
      label: 'Auto',
    ),
    const TabInfo(icon: Icons.palette_outlined, label: 'Manual'),
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

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    width = Tween<double>(
      begin: 55.0,
      end: 120.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.125,
          0.250,
          curve: Curves.ease,
        )));
    height = Tween<double>(begin: 55.0, end: 100.0).animate(CurvedAnimation(
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

  Future<void> _playAnimation() async {
    try {
      if (_controller.isForwardOrCompleted) {
        _doStop();
        await _controller.reverse().orCancel;
      } else {
        _doPlay();
        await _controller.forward().orCancel;
      }
    } on TickerCanceled {
      // The animation got canceled, probably because we were disposed.
    }
  }

  void _doPlay() {
    Timer(Duration(milliseconds: 1), () {
      setState(() {
        tabInfoItems = [
          for (final tab in tabs)
            Container(
              padding:
                  const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(tab.icon, color: Constants.colorPrimary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      tab.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
        ];
        tabInfoItems = tabInfoItems
            .animate(interval: 50.ms)
            .fadeIn(duration: 200.ms, delay: 100.ms)
            .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
            .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);
      });
    });
  }

  void _doStop() {
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        tabInfoItems = [];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // _dispStream.dispose();
    // _model.setRun(run: false, camera: null, mounted: false);
    // MyRep().stopCamera();
    // WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return HoverClick(
        onPressedL: (_) {
          // var model = context.read<RecordModel>();
          // model.setModeMenuVisible(!model.modeMenuVisible);
          _playAnimation();
        },
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: width.value,
                height: height.value,
                decoration: BoxDecoration(
                    color: Constants.colorBgUnderCard.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(_borderRadius.value),
                        topRight: Radius.circular(_borderRadius.value),
                        bottomLeft: Radius.circular(_borderRadius.value),
                        bottomRight: Radius.circular(_borderRadius.value))),
                child: ListView(
                  children: tabInfoItems,
                ),
              );
            }));
  }
}
