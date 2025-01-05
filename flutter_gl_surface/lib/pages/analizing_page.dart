import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/pages/model/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});
  @override
  State<RecordPage> createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> with WidgetsBindingObserver {
  final _dispStream = DisposableStream();
  late RecordModel _model;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
// _dispStream.add(MyRep().onFrameSize.listen((size) {
//   _model.camera.
// }));

      WidgetsBinding.instance.addObserver(this);

      await MyRep().registerView();
      await MyRep().getCameras();
      _start();
    });
  }

  Future _start() async {
    if (_model.run) return;
    var cameras = MyRep().cameraMap;
    var front = cameras['front'];
    var back = cameras['back'];
    Camera? camera;
    // init first
    await MyRep().initRender();
    // start with front
    if (Constants.defaultCamera == front?.facing) {
      camera = front;
    } else if (back != null) {
      camera = back;
    }
    if (camera == null) return;
    await MyRep().startCamera(camera.id);
    _model.setRun(run: true, camera: camera);
  }

  Future<void> _flip() async {
    var camera = _cameraToFlit();
    if (camera == null) return;
    _model.setRun(run: true, camera: camera);
    await MyRep().stopCamera();
    // await MyRep().initRender();
    await MyRep().startCamera(camera.id);
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

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Here you can detect orientation change
    // final orientation = MediaQuery.of(context).orientation;
    // var view = View.of(context).platformDispatcher.views.first;
    // var size = view.physicalSize / view.devicePixelRatio;
    // print("BTEST_Current size: $size");
    // Timer(const Duration(milliseconds: 500), () {
    //   _updateRotation();
    // });
  }

  void _updateRotation() async {
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
        body: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: SizedBox(
                      height: kToolbarHeight,
                      child: Row(children: [
                        const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Analizing',
                                style: TextStyle(fontSize: 25))),
                        const Spacer(),
                        CircleButton(
                            color: Colors.transparent,
                            iconColor:
                                Constants.colorTextAccent.withOpacity(0.8),
                            size: 70,
                            vertTransform: true,
                            iconData: Icons.arrow_back_ios,
                            onPressed: (p0) {
                              var model = context.read<AppModel>();
                              model.setCollapse(!model.collapse);
                            })
                      ]))),
              SliverToBoxAdapter(
                  child: SizedBox(
                height: NavigatorRep().size.height - kToolbarHeight - 85,
                child: _camera(),
              ))
            ]));
  }

  Widget _camera() {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Container(
              decoration: const BoxDecoration(
                  color: Constants.colorBackgroundUnderCard,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: double.infinity,
              child: Stack(alignment: Alignment.center, children: [
                Positioned.fill(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: OrientationBuilder(builder: (context, orientation) {
                      _updateRotation();
                      return Builder(builder: (context) {
                        //   var rotation = context.read<RecordModel>().rotation;
                        // _updateRotation();
                        // var rotation =
                        //     context.watch<RecordModel>().rotation;
                        // var camera = context
                        //     .select<RecordModel, Camera?>((v) => v.camera);
                        // var rotation = 0;
                        // var camera = context.read<RecordModel>().camera;
                        var layout = context.watch<RecordModel>().surfaceLayout;
                        // var rotation = _model.rotation;
                        logDebug(
                            'BTEST: rotation=${layout.rotation}, ratio=${layout.ratio}');
                        return Column(children: [
                          Flexible(
                              child: RotatedBox(
                                  quarterTurns: layout.rotation,
                                  child: AspectRatio(
                                      aspectRatio: layout.ratio,
                                      child: const AndroidView(
                                          viewType: 'my_gl_surface_view',
                                          creationParams: null,
                                          creationParamsCodec:
                                              StandardMessageCodec())))),
                          // Flexible(
                          //     child: Text(
                          //         'ratio: ${layout.ratio}, rotation=${layout.rotation}',
                          //         style: const TextStyle(
                          //             color: Colors.purple, fontSize: 15)))
                        ]);
                      });
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
                    bottom: 50,
                    child: AnimatedRotation(
                        turns: context.watch<RecordModel>().flipWait ? 0 : 0.5,
                        duration: Constants.duration * 2,
                        child: CircleButton(
                            color: Constants.colorBackgroundUnderCard
                                .withOpacity(0.3),
                            iconColor: Constants.colorCard.withOpacity(0.8),
                            size: 70,
                            iconData: Icons.photo_camera,
                            onPressed: (v) async {
                              // if (_model.flipWait) return;
                              // _model.flipTurns = 4;
                              // _model.setFlipWait(true);
                              // // await _flip();
                              // await Future.delayed(const Duration(seconds: 1));
                              // _model.setFlipWait(false);
                              MyRep().getCameras();
                              setState(() {});
                            }))),
                Positioned(
                    right: 40,
                    bottom: 50,
                    child: AnimatedRotation(
                        turns: context.watch<RecordModel>().camera?.facing ==
                                Constants.defaultCamera
                            ? 0
                            : 0.5,
                        duration: Constants.duration * 2,
                        child: CircleButton(
                            color: Constants.colorBackgroundUnderCard
                                .withOpacity(0.3),
                            iconColor: Constants.colorCard.withOpacity(0.8),
                            size: 55,
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
                            })))
              ]));
        });
  }
}
