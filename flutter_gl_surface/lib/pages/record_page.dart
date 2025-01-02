import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/model/record_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:collection/collection.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});
  @override
  State<RecordPage> createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  final _dispStream = DisposableStream();
  final _model = RecordModel();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _dispStream.add(MyRep().onCameraChanged.listen((_) {
        if (_model.run) {
          return;
        }
        var camera = MyRep().cameraMap;
        var front = camera['front'];
        var back = camera['back'];

        // start with front
        if (front != null) {
          MyRep().startRender(front.id);
          _model.setRun(true, front);
        } else if (back != null) {
          MyRep().startRender(back.id);
          _model.setRun(true, back);
        }
      }));
    });
  }

  void _flip() async {
    var camera = MyRep().cameraMap;
    var front = camera['front'];
    var back = camera['back'];
    var cur = _model.camera;
    if (front == cur) {
      if (back != null) {
        MyRep().startRender(back.id);
        _model.setRun(true, back);
      }
    } else {
      if (front != null) {
        MyRep().startRender(front.id);
        _model.setRun(true, front);
      }
    }
  }

  // void _dd() async {
  //   // var cameras = await MyRep().getCameras();
  //   var cameras = MyRep().cameraMap;
  //   logDebug(cameras);
  // }

  @override
  void dispose() {
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Stack(alignment: Alignment.center, children: [
            Column(children: [
              //
              // render
              Builder(builder: (context) {
                final size = MyRep().frameSize;
                var ratio = 1.0;
                if (size.width > 0 && size.height > 0) {
                  ratio = size.width / size.height;
                }
                return Expanded(
                    child: AspectRatio(
                        aspectRatio: ratio,
                        child: AndroidView(
                          viewType: 'my_gl_surface_view',
                          creationParams: null,
                          creationParamsCodec: StandardMessageCodec(),
                        )));
              })
            ]),
            // camera
            Positioned(
                left: 0,
                right: 0,
                top: 20,
                child: Builder(builder: (context) {
                  var model = context.watch<RecordModel>();
                  return Text(
                      'Camera: ${model.camera?.facing}:${model.camera?.id}');
                })),
            // Positioned(
            //     left: 0,
            //     bottom: 100,
            //     child: ElevatedButton(
            //         child: const Text("Start0"),
            //         onPressed: () {
            //           MyRep().startRender('0');
            //         })),
            // Positioned(
            //     bottom: 10,
            //     left: 0,
            //     child: ElevatedButton(
            //         child: const Text("Start1"),
            //         onPressed: () {
            //           MyRep().startRender('1');
            //         })),
            Positioned(
                bottom: 50,
                child: CircleButton(
                    color: Constants.colorBackground,
                    iconColor: Constants.colorCard.withOpacity(0.8),
                    size: 70,
                    iconData: Icons.photo_camera,
                    onPressed: (v) {
                      _flip();
                    })),
            // TODO: animation
            Positioned(
                right: 40,
                bottom: 50,
                child: CircleButton(
                    color: Constants.colorBackground,
                    iconColor: Constants.colorCard.withOpacity(0.8),
                    size: 55,
                    iconData: Icons.flip_camera_android,
                    onPressed: (v) {
                      _flip();
                    }))
          ]);
        });
  }
}
