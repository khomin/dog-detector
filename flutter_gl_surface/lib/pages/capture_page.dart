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

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});
  @override
  State<CapturePage> createState() => CapturePageState();
}

class CapturePageState extends State<CapturePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _dispStream = DisposableStream();
  late RecordModel _model;
  final tag = 'capturePage';

  late final Animation<double> opacity;
  late final Animation<double> width;
  late final Animation<double> height;
  late final Animation<double> _borderRadius;
  late final Animation<double> _leftOffset;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addObserver(this);

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
    height = Tween<double>(begin: 55.0, end: 200.0).animate(CurvedAnimation(
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

    Future.microtask(() async {
      _model.setOrientationWait(true);
      await MyRep().registerView();
      await MyRep().getCameras();
      await _start();
      await _updateRotation();
      _model.setOrientationWait(false);
    });
  }

  Future<void> _playAnimation() async {
    try {
      if (_controller.isForwardOrCompleted) {
        await _controller.reverse().orCancel;
      } else {
        await _controller.forward().orCancel;
      }
    } on TickerCanceled {
      // The animation got canceled, probably because we were disposed.
    }
  }

  Future _start() async {
    var cameras = MyRep().cameraMap;
    var front = cameras['front'];
    var back = cameras['back'];
    Camera? camera;
    // init first
    await MyRep().initRender();
    // start with last used or default camera
    var cameraId = await SettingsRep().getCameraUsed();
    if (front?.id == cameraId) {
      camera = front;
    } else if (back?.id == cameraId) {
      camera = back;
    } else {
      if (Constants.defaultCamera == front?.facing) {
        camera = front;
      } else if (back != null) {
        camera = back;
      }
    }
    if (camera == null) {
      logError('$tag: cannot initialize camera');
      return;
    }
    await MyRep().startCamera(camera.id);
    SettingsRep().setCameraUsed(camera.id);
    _model.setRun(run: true, camera: camera);
  }

  Future<void> _flip() async {
    var camera = _cameraToFlit();
    if (camera == null) return;
    _model.setRun(run: true, camera: camera);
    await MyRep().stopCamera();
    // await MyRep().initRender();
    await MyRep().startCamera(camera.id);
    SettingsRep().setCameraUsed(camera.id);
  }

  Camera? _cameraToFlit() {
    var camera = MyRep().cameraMap;
    var front = camera['front'];
    var back = camera['back'];
    var cur = _model.camera;
    if (front == cur) {
      return back;
    }
    return front;
  }

  @override
  void dispose() {
    super.dispose();
    _dispStream.dispose();
    _model.setRun(run: false, camera: null, mounted: false);
    MyRep().stopCamera();
    WidgetsBinding.instance.removeObserver(this);
  }

  Timer? _updateLayoutTm;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Here you can detect orientation change
    // final orientation = MediaQuery.of(context).orientation;
    var view = View.of(context).platformDispatcher.views.first;
    var size = view.physicalSize / view.devicePixelRatio;
    print("BTEST_Current size: $size");
    logDebug('BTEST: didChange');
    _model.setOrientationWait(true);
    _updateLayoutTm?.cancel();
    _updateLayoutTm = Timer(const Duration(milliseconds: 300), () async {
      await _updateRotation();
      Timer(Duration(milliseconds: 100), () {
        _model.setOrientationWait(false);
      });
    });
  }

  Future _updateRotation() async {
    var devRotation = await MyRep().getDeviceSensor();
    var sensorRotation = _model.camera?.sensor ?? 0;
    var rotation = _adjustRotation(
        sensorRotation, devRotation, _model.camera?.facing == 'Front');
    var size = _model.camera?.size;
    var ratio = 1.0;
    if (size != null) {
      if (size.width > size.height) {
        ratio = size.width / size.height;
      } else {
        ratio = size.height / size.width;
      }
      // ratio = size.height / size.width;
      // ratio = size.width / size.height;
    }
    _model.setSurfaceLayout(SurfaceLayout(rotation: rotation, ratio: ratio));
    logDebug(
        'BTEST:2 rotation=$rotation, devRotation=$devRotation, sensorRotation=$sensorRotation');
    // }();
    // logDebug(
    //     'BTEST, rotation=${context.watch<RecordModel>().rotation} ratio=$ratio, width=${size?.width},height=${size?.height},orientation=$orientation');
  }

  int _adjustRotation(int sensorRotation, int deviceRotation, bool front) {
    // 1
    // // Calculate the rotation values in terms of quarter turns.
    // int sensorQuarterTurn = (sensorRotation ~/ 90) % 4; // 0 to 3
    // int deviceQuarterTurn = (deviceRotation ~/ 90) % 4; // 0 to 3

    // // Combine the two to get the final rotation.
    // // Since both values represent a rotation, we could just add them.
    // int adjustedTurn = (sensorQuarterTurn + deviceQuarterTurn) % 4;

    // return adjustedTurn; // Return a value between 0 and 3

    //// 2
    // Combine sensor and device rotation
    if (front) {
      int combinedRotation = (sensorRotation + deviceRotation) % 360;
      return combinedRotation ~/ 90;
    } else {
      int combinedRotation = (sensorRotation - deviceRotation + 360) % 360;
      return combinedRotation ~/ 90;
    }

    // // 3
    // // Combine sensor and device rotations
    // int combinedRotation = (sensorRotation + deviceRotation) % 360;

    // // Convert degrees to quarterTurns
    // return combinedRotation ~/ 90;
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<RecordModel>();
    return Scaffold(
        backgroundColor: Constants.colorBar,
        // backgroundColor: Colors.transparent,
        body: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: SizedBox(
                      height: kToolbarHeight,
                      child: Row(children: [
                        const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Capture',
                                style: TextStyle(fontSize: 25))),
                        const Spacer(),
                        CircleButton(
                            color: Colors.transparent,
                            iconColor:
                                Constants.colorTextAccent.withOpacity(0.8),
                            size: 70,
                            // margin: EdgeInsets.only(bottom: 10),
                            vertTransform: true,
                            iconData: Icons.arrow_back_ios_new,
                            // iconData: Icons.arrow_back_ios,
                            onPressed: (p0) {
                              var model = context.read<AppModel>();
                              model.setCollapse(!model.collapse);
                            })
                      ]))),
              SliverFillRemaining(child: _camera())
            ]));
  }

  Widget _camera() {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Container(
              decoration: const BoxDecoration(
                  color: Constants.colorTextAccent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: double.infinity,
              child: Stack(alignment: Alignment.center, children: [
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: -(NavigatorRep().size.height + 20 / 3),
                    child: Builder(builder: (context) {
                      //   var rotation = context.read<RecordModel>().rotation;
                      // _updateRotation();
                      // var rotation =
                      //     context.watch<RecordModel>().rotation;
                      // var camera = context
                      //     .select<RecordModel, Camera?>((v) => v.camera);
                      // var rotation = 0;
                      // var camera = context.read<RecordModel>().camera;
                      var model = context.watch<RecordModel>();
                      // var rotation = _model.rotation;
                      logDebug(
                          'BTEST: rotation=${model.surfaceLayout.rotation}, ratio=${model.surfaceLayout.ratio}');
                      return Column(children: [
                        Flexible(
                            child: RotatedBox(
                                quarterTurns: model.surfaceLayout.rotation,
                                child: AspectRatio(
                                    aspectRatio: model.surfaceLayout.ratio,
                                    child: Opacity(
                                        opacity: model.orientationpWait ? 0 : 1,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: const AndroidView(
                                                viewType: 'my_gl_surface_view',
                                                creationParams: null,
                                                creationParamsCodec:
                                                    StandardMessageCodec()))))))
                      ]);
                    })),
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Builder(builder: (context) {
                      var model = context.watch<RecordModel>();
                      if (model.orientationpWait) {
                        return const Center(
                            child: SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator()));
                      }
                      return const SizedBox();
                    })),
                // camera
                Positioned(
                    left: 0,
                    right: 0,
                    top: 20,
                    child: Builder(builder: (context) {
                      var model = context.watch<RecordModel>();
                      return Container(
                          color: Colors.black26,
                          child: Center(
                              child: Text(
                                  'Camera: ${model.camera?.facing}:${model.camera?.id}\nrotation=${model.surfaceLayout.rotation}\nratio=${model.surfaceLayout.ratio}\nsensor=${model.camera?.sensor}\nsize=${model.camera?.size}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15))));
                    })),

                Positioned(
                    left: 0,
                    bottom: 50,
                    right: 0,
                    child: Container(
                        height: 200,
                        // color: Colors.amber,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) {
                                    return HoverClick(
                                        onPressedL: (_) {
                                          // var model = context.read<RecordModel>();
                                          // model.setModeMenuVisible(!model.modeMenuVisible);
                                          _playAnimation();
                                        },
                                        child: Container(
                                            width: width.value,
                                            height: height.value,
                                            decoration: BoxDecoration(
                                                // color: Colors.pink,
                                                color: Constants
                                                    .colorBgUnderCard
                                                    .withOpacity(0.3),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        _borderRadius.value),
                                                    topRight: Radius.circular(
                                                        _borderRadius.value),
                                                    bottomLeft: Radius.circular(
                                                        _borderRadius.value),
                                                    bottomRight:
                                                        Radius.circular(
                                                            _borderRadius
                                                                .value)))));
                                  }),
                              CircleButton(
                                  color: Constants.colorBgUnderCard
                                      .withOpacity(0.3),
                                  iconColor:
                                      Constants.colorCard.withOpacity(0.8),
                                  size: 70,
                                  useScaleAnimation: true,
                                  iconData: Icons.photo_camera,
                                  onPressed: (v) {
                                    MyRep().takeImage();
                                  }),
                              AnimatedRotation(
                                  turns: context
                                              .watch<RecordModel>()
                                              .camera
                                              ?.facing ==
                                          Constants.defaultCamera
                                      ? 0
                                      : 0.5,
                                  duration: Constants.duration * 2,
                                  child: CircleButton(
                                      color: Constants.colorBgUnderCard
                                          .withOpacity(0.3),
                                      iconColor:
                                          Constants.colorCard.withOpacity(0.8),
                                      size: 55,
                                      useScaleAnimation: true,
                                      iconData: Icons.flip_camera_android,
                                      onPressed: (v) async {
                                        if (_model.flipWait) return;
                                        var camera = _cameraToFlit();
                                        if (camera == null) return;
                                        _model.flipTurns =
                                            camera.facing == 'Font' ? 0.5 : 0;
                                        _model.setFlipWait(true);
                                        await _flip();
                                        _model.setFlipWait(false);
                                      }))
                            ])))
              ]));
        });
  }
}
