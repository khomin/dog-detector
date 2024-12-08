// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  static const _methodChannel = MethodChannel('dev/cmd');
  var _frameSize = Size(0, 0);

  Future<void> _startRendering(String id) async {
    try {
      var r = await _methodChannel
          .invokeMethod('start_camera', <String, dynamic>{'id': id});
      setState(() {
        _frameSize = Size((r['size_width'] as int).toDouble(),
            (r['size_height'] as int).toDouble());
      });
    } on PlatformException catch (e) {
      print("Error starting rendering: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(children: [
      const Text('Hello'),
      Container(color: Colors.purple),
      //
      // 1
      Builder(builder: (context) {
        final size = _frameSize;
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
      }),
      //
      // 2
      ElevatedButton(
        child: const Text("Start0"),
        onPressed: () {
          _startRendering('0');
        },
      ),
      ElevatedButton(
          child: const Text("Start1"),
          onPressed: () {
            _startRendering('1');
          })
    ])));
  }
}
