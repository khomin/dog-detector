import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});
  @override
  State<RecordPage> createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  @override
  Widget build(BuildContext context) {
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
      Positioned(
          left: 0,
          bottom: 100,
          child: ElevatedButton(
              child: const Text("Start0"),
              onPressed: () {
                MyRep().startRender('0');
              })),
      Positioned(
          bottom: 10,
          left: 0,
          child: ElevatedButton(
              child: const Text("Start1"),
              onPressed: () {
                MyRep().startRender('1');
              })),
      Positioned(
          right: 40,
          bottom: 50,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Constants.colorCard.withOpacity(0.7),
                  fixedSize: const Size(50, 50),
                  elevation: 0),
              // child:
              child: Icon(Icons.flip_camera_android),
              onPressed: () {
                MyRep().startRender('0');
              })),
      //
      // 2
      // ElevatedButton(
      //   child: const Text("Start0"),
      //   onPressed: () {
      //     MyRep().startRender('0');
      //   },
      // ),
      // ElevatedButton(
      //     child: const Text("Start1"),
      //     onPressed: () {
      //       MyRep().startRender('1');
      //     })
    ]);
  }
}
