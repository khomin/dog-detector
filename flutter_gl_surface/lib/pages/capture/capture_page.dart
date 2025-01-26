import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/components/animated_camera_button.dart';
import 'package:flutter_demo/components/animated_camera_buttons.dart';
import 'package:flutter_demo/components/animated_camera_menu.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/my_cliper.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/home/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/repo/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:rxdart/rxdart.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});
  @override
  State<CapturePage> createState() => CapturePageState();
}

class CapturePageState extends State<CapturePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _dispStream = DisposableStream();
  late RecordModel _model;
  late final AppLifecycleListener _listener;
  late final Animation<double> _slideHeight;
  late final Animation<double> _slideOpacity;
  late AnimationController _ctrSlideTop;
  final _onStopRecordStream = PublishSubject<bool>();
  Widget? _captured;
  bool _hasLastCapture = false;
  bool _onRightToLeft = false;
  bool _onLeftToGone = false;
  final tag = 'capturePage';

  @override
  void initState() {
    super.initState();

    _ctrSlideTop = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideHeight = Tween<double>(
      begin: kToolbarHeight,
      end: kToolbarHeight * 3,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _slideOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    Future.microtask(() async {
      // init first
      await MyRep().initRender();

      _listener = AppLifecycleListener(onStateChange: (value) {
        // logDebug('BTEST_STATE=$value');
        switch (value) {
          case AppLifecycleState.inactive:
          case AppLifecycleState.hidden:
          case AppLifecycleState.detached:
          case AppLifecycleState.paused:
            _model.setRun(run: false, camera: null);
            MyRep().stopCamera();
            break;
          case AppLifecycleState.resumed:
            _start(flip: false);
            break;
        }
      });

      _model.devRotation = await MyRep().getDeviceSensor();
      // _model.setOrientationWait(true);
      await MyRep().registerView();
      await MyRep().getCameras();
      await _start(flip: false);
      // await _updateRotation();
      // _model.setOrientationWait(false);
    });

    MyRep().onCapture = (path) {
      _updateLastFrame(path: path);
    };
    MyRep().onFirstFrame = () async {
      logDebug('BTEST_onFirstFrame');
      // await _updateRotation();
      // await Future.delayed(const Duration(milliseconds: 1000));
      // _model.setOrientationWait(false);
      // _model.setHideSurface(false);
      await Future.delayed(const Duration(milliseconds: 100));
      _model.setImgBlur(null);
      _model.setFlipWait(false);
    };
  }

  @override
  void dispose() {
    super.dispose();
    _listener.dispose();
    _dispStream.dispose();
    _onStopRecordStream.close();
    _model.setRun(run: false, camera: null, mounted: false);
    // if (!MyRep().captureActive) {
    () async {
      MyRep().setCaptureActive(false);
      MyRep().stopCamera();
      // }
      MyRep().onCapture = null;
      MyRep().onFirstFrame = null;
    }();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _start({required bool flip}) async {
    Camera? camera;
    if (flip) {
      camera = _cameraToFlit();
      var path = await MyRep().captureOneFrame(serviceFrame: true);
      _model.setBlurLayout(_model.layout);
      _model.setImgBlur(path);
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      var cameras = MyRep().cameraMap;
      var front = cameras['front'];
      var back = cameras['back'];
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
    }
    if (camera == null) return;
    _model.setRun(run: true, camera: camera);

    await MyRep().stopCamera();
    await MyRep().startCamera(
        id: camera.id,
        captureIntervalSec: await SettingsRep().getCaptureIntervalSec(),
        minArea: await SettingsRep().getCaptureMinArea(),
        showAreaOnCapture: await SettingsRep().getCaptureShowArea());

    _model.updateRotation();
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

  void _updateLastFrame({required String path}) async {
    if (_captured == null) {
      setState(() {
        if (path.isNotEmpty) {
          _captured = ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Stack(alignment: Alignment.center, children: [
                Image.memory(File(path).readAsBytesSync(),
                    cacheHeight: 100, cacheWidth: 100, fit: BoxFit.fill)
              ]));
        } else {
          _captured = ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child:
                  Stack(alignment: Alignment.center, children: [Container()]));
        }
        _onRightToLeft = true;
        _hasLastCapture = true;
      });
    } else {
      setState(() {
        _onLeftToGone = true;
        _hasLastCapture = true;
      });
      Timer(Constants.lastFrameDuration, () {
        setState(() {
          _onLeftToGone = false;
          _captured = null;
          _onRightToLeft = false;
        });
        Timer(Constants.lastFrameDuration, () {
          setState(() {
            if (path.isNotEmpty) {
              _captured = ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.memory(File(path).readAsBytesSync(),
                        cacheHeight: 100, cacheWidth: 100, fit: BoxFit.fill)
                  ]));
            } else {
              _captured = ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Stack(
                      alignment: Alignment.center, children: [Container()]));
            }
            _onRightToLeft = true;
          });
        });
      });
    }
  }

  void _handleOnSlide() {
    if (MyRep().onCaptureTime.valueOrNull == null) return;
    if (_ctrSlideTop.isForwardOrCompleted) {
      _ctrSlideTop.reverse().orCancel;
    } else {
      _ctrSlideTop.forward().orCancel;
    }
  }

  // @override
  // void didChangeMetrics() {
  //   super.didChangeMetrics();
  //   // Here you can detect orientation change
  //   // final orientation = MediaQuery.of(context).orientation;
  //   var view = View.of(context).platformDispatcher.views.first;
  //   var size = view.physicalSize / view.devicePixelRatio;
  //   // print("BTEST_Current size: $size");
  //   logDebug('BTEST: didChange');
  //   _model.setOrientationWait(true);
  //   _updateLayoutTm?.cancel();
  //   _updateLayoutTm = Timer(const Duration(milliseconds: 300), () async {
  //     await _updateRotation();
  //     Timer(const Duration(milliseconds: 100), () {
  //       _model.setOrientationWait(false);
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    _model = context.read<RecordModel>();
    return Scaffold(
        backgroundColor: Constants.colorBar,
        body: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              AnimatedBuilder(
                  animation: _ctrSlideTop,
                  builder: (context, child) {
                    return SliverAppBar(
                        backgroundColor: Constants.colorBar,
                        toolbarHeight: _slideHeight.value,
                        automaticallyImplyLeading: false,
                        flexibleSpace: _sliverAppBar());
                  }),
              SliverFillRemaining(child: _camera())
            ]));
  }

  Widget _sliverAppBar() {
    return Stack(children: [
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
              opacity: _slideOpacity.value,
              child: SizedBox(
                  height: _slideHeight.value / 1.5,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundButton(
                            color: Constants.colorButtonRed.withOpacity(0.8),
                            iconColor: Constants.colorCard.withOpacity(0.8),
                            size: 55,
                            radius: 20,
                            useScaleAnimation: true,
                            iconData: Icons.stop_circle_sharp,
                            onPressed: (v) async {
                              _handleOnSlide();
                              await MyRep().setCaptureActive(false);
                              _onStopRecordStream.add(true);
                              MyRep().stopCamera();
                            }),
                        const SizedBox(width: 15),
                        RoundButton(
                            color: Constants.colorSecondary.withOpacity(0.8),
                            iconColor: Constants.colorCard.withOpacity(0.8),
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
          child: Container(
              color: Constants.colorBar,
              height: kToolbarHeight,
              child: Row(children: [
                Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 25),
                    child:
                        const Text('Capture', style: TextStyle(fontSize: 25))),
                HoverClick(
                    onPressedL: (p0) async {
                      _handleOnSlide();
                    },
                    child: SizedBox(
                        width: 130,
                        height: 50,
                        child: RepaintBoundary(
                            child:
                                Stack(alignment: Alignment.center, children: [
                          StreamBuilder(
                              stream: MyRep().onCaptureTime,
                              initialData: MyRep().onCaptureTime.valueOrNull,
                              builder: (context, snapshot) {
                                var duration = snapshot.data;
                                return AnimatedContainer(
                                    duration: Duration.zero,
                                    width: duration == null ? 10 : 130,
                                    height: duration == null ? 10 : 30,
                                    child: RoundBox(
                                        text: duration?.duration.format() ?? '',
                                        color: const Color.fromARGB(
                                                255, 211, 19, 5)
                                            .withOpacity(0.8),
                                        borderRadius: 40));
                              })
                        ])))),
                const Spacer()
              ])))
    ]);
  }

  Widget _camera() {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Container(
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: double.infinity,
              child: Stack(alignment: Alignment.center, children: [
                //
                // surface
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: -(NavigatorRep().size.height + 20 / 3),
                    child: Builder(builder: (context) {
                      var layout = context
                          .select<RecordModel, SurfaceLayout>((v) => v.layout);
                      logDebug(
                          'BTEST: rotation-surface=${layout.rotation}, ratio=${layout.ratio}');
                      return Stack(children: [
                        Column(children: [
                          Flexible(
                              child: RotatedBox(
                                  quarterTurns: layout.rotation,
                                  child: AspectRatio(
                                      aspectRatio: layout.ratio,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: const AndroidView(
                                              viewType: 'my_gl_surface_view',
                                              creationParams: null,
                                              creationParamsCodec:
                                                  StandardMessageCodec())))))
                        ])
                      ]);
                    })),
                //
                // blur
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: -(NavigatorRep().size.height + 20 / 3),
                    child: _blurTransition()),
                //
                // progress
                Positioned.fill(
                    child: Stack(alignment: Alignment.center, children: [
                  RepaintBoundary(child: Builder(builder: (context) {
                    var wait = context
                        .select<RecordModel, bool>((v) => v.orientationpWait);
                    if (wait) {
                      return const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator());
                    }
                    return const SizedBox();
                  }))
                ])),
                //
                // buttons
                Positioned(left: 0, bottom: 0, right: 0, child: _buttons())
              ]));
        });
  }

  Widget _buttons() {
    return RepaintBoundary(
        child: Container(
            height: 130,
            decoration: const BoxDecoration(color: Constants.colorButtonBg),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //
                  // last captured frame
                  _lastCaptured(),
                  //
                  // center
                  AnimatedCameraButton(
                      activeDefault: MyRep().captureActive,
                      onStopOutsideStream: _onStopRecordStream,
                      onCapture: () async {
                        await MyRep().setCaptureActive(true);
                      },
                      onStop: () async {
                        await MyRep().setCaptureActive(false);
                      }),
                  //
                  // right
                  RepaintBoundary(child: Builder(builder: (context) {
                    var camera =
                        context.select<RecordModel, Camera?>((v) => v.camera);
                    return AnimatedRotation(
                        turns:
                            camera?.facing == Constants.defaultCamera ? 0 : 0.5,
                        duration: Constants.duration * 2,
                        child: RoundButton(
                            color: Constants.colorButton,
                            iconColor: Constants.colorCard.withOpacity(0.8),
                            size: 55,
                            useScaleAnimation: true,
                            iconData: Icons.flip_camera_android,
                            onPressed: (v) async {
                              if (_model.flipWait) return;
                              _model.setFlipWait(true);
                              _start(flip: true);
                            }));
                  }))
                ])));
  }

  Widget _blurTransition() {
    return Builder(builder: (context) {
      // return const SizedBox();
      var layout =
          context.select<RecordModel, SurfaceLayout>((v) => v.oldLayout);
      var imgBlur = context.select<RecordModel, String?>((v) => v.imgBlur);
      // var img = flipData.img1;
      // if (imgBlur == null) return const SizedBox();
      // var imgFile = File(imgBlur);
      // return RotatedBox(
      //     quarterTurns: layout.rotation,
      //     child:
      logDebug(
          'BTEST: rotation-blur=${layout.rotation}, ratio=${layout.ratio}');
      return Stack(children: [
        Column(children: [
          Flexible(
              child: RotatedBox(
                  quarterTurns: layout.rotation,
                  child: AspectRatio(
                      aspectRatio: layout.ratio,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Stack(children: [
                            Positioned.fill(
                                child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 50),
                                    opacity: imgBlur == null ? 0 : 1,
                                    child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                            sigmaX: 13, sigmaY: 13),
                                        child: imgBlur == null
                                            ? const SizedBox()
                                            : Image.memory(
                                                File(imgBlur).readAsBytesSync(),
                                                // color: Colors.yellow,
                                                // colorBlendMode: BlendMode.color,
                                                cacheHeight: 100,
                                                cacheWidth: 100,
                                                //     NavigatorRep().size.width.toInt(),
                                                // color: Colors.yellow,
                                                // fit: BoxFit.fitHeight,
                                                // fit: BoxFit.cover,
                                                fit: BoxFit.fill))))
                          ])))))
        ])
      ]);
    });
  }

  Widget _lastCaptured() {
    return Builder(builder: (context) {
      var item = _captured;
      return AnimatedOpacity(
          opacity: _hasLastCapture ? 1 : 0,
          duration: Constants.lastFrameDuration,
          child: Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                  color: Constants.colorButton,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Stack(alignment: Alignment.center, children: [
                    AnimatedPositioned(
                        duration: Constants.lastFrameDuration,
                        left: _onLeftToGone ? -55 : (_onRightToLeft ? 0 : 55),
                        bottom: 0,
                        top: 0,
                        child: SizedBox(
                            width: 55,
                            height: 55,
                            child: item ?? const SizedBox())),
                    // const Center(
                    //     child: Text('2', style: TextStyle(color: Colors.white)))
                  ]))));
    });
  }
}
