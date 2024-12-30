import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/repo/my_rep.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});
  @override
  State<RecordPage> createState() => RecordPageState();
}

// TODO: here is main page
// 1 start recording button
// 2 an optioon to see previous videos -> delete, ListView
// NavigationBar -> Settings

class RecordPageState extends State<RecordPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Hello'),
      Container(color: Colors.purple),
      //
      // 1
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
      }),
      //
      // 2
      ElevatedButton(
        child: const Text("Start0"),
        onPressed: () {
          MyRep().startRender('0');
        },
      ),
      ElevatedButton(
          child: const Text("Start1"),
          onPressed: () {
            MyRep().startRender('1');
          })
    ]);
  }
}
