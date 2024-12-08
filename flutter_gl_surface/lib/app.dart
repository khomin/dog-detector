import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  static const _methodChannel = MethodChannel('dev/cmd');

  Future<void> _startRendering() async {
    try {
      await _methodChannel.invokeMethod('startRendering');
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
      SizedBox(
          height: 300,
          child: AndroidView(
            viewType: 'my_gl_surface_view',
            creationParams: null,
            creationParamsCodec: const StandardMessageCodec(),
          )),
      //
      // 2
      ElevatedButton(child: const Text("Start"), onPressed: _startRendering)
    ])));
  }
}
