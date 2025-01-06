import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/components/custom_checkbox.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/pages/model/camera_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';

class CameraSettingsPage extends StatefulWidget {
  const CameraSettingsPage({super.key});
  @override
  State<CameraSettingsPage> createState() => CameraSettingsPageState();
}

class CameraSettingsPageState extends State<CameraSettingsPage> {
  final _dispStream = DisposableStream();
  // late final CameraModel _model;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {});
  }

  @override
  void dispose() {
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _model = context.read<CameraModel>();
    return Scaffold(
        backgroundColor: Constants.colorBar,
        body: Stack(children: [
          Column(children: [
            Container(
                color: Constants.colorBar,
                height: kToolbarHeight,
                child: Row(children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text('Camera settings',
                          style: TextStyle(
                            // fontFamily: 'Sulphur',
                            fontSize: 25,
                            // color: Colors.black38,
                            // fontWeight: FontWeight.bold
                          ))),
                  const Spacer(),
                  CircleButton(
                      color: Colors.transparent,
                      iconColor: Constants.colorTextAccent.withOpacity(0.8),
                      size: 70,
                      iconData: Icons.close_sharp,
                      onPressed: (p0) async {
                        var model = context.read<AppModel>();
                        model.setCollapse(!model.collapse);
                      })
                ])),
            Container(
                margin: const EdgeInsets.only(top: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //
                      // min area
                      Row(children: [
                        const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Min area',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Constants.colorTextAccent))),
                        Expanded(child: Builder(builder: (context) {
                          var minArea = context
                              .select<CameraModel, int>((v) => v.minArea);
                          return Slider(
                              value: minArea.toDouble(),
                              min: 100.0,
                              max: 100000.0,
                              divisions: 100,
                              activeColor: Constants.colorSecondary,
                              inactiveColor: Constants.colorSecondary,
                              thumbColor: Constants.colorPrimary,
                              label: minArea.toString(),
                              onChanged: (double newValue) {
                                context
                                    .read<CameraModel>()
                                    .setMinArea(newValue.toInt());
                              });
                        }))
                      ]),
                      //
                      // capture image interval
                      Row(children: [
                        const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Capture interval',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Constants.colorTextAccent))),
                        Expanded(child: Builder(builder: (context) {
                          var captureSec = context.select<CameraModel, int>(
                              (v) => v.captureIntervalSec);
                          return Slider(
                              value: captureSec.toDouble(),
                              min: 1.0,
                              max: 30.0,
                              divisions: 100,
                              activeColor: Constants.colorSecondary,
                              inactiveColor: Constants.colorSecondary,
                              thumbColor: Constants.colorPrimary,
                              label: captureSec.toString(),
                              onChanged: (double newValue) {
                                context
                                    .read<CameraModel>()
                                    .setCaptureImageIntVal(newValue.toInt());
                              });
                        }))
                      ]),
                      // enable area on images
                      Row(children: [
                        const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Show area on captured images',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Constants.colorTextAccent))),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child:
                                CustomCheckBox(value: true, onChanged: () {}))
                      ]),
                    ])),
            Builder(builder: (context) {
              var collapse = context.select<AppModel, bool>((v) => v.collapse);
              if (collapse) {
                return Container(
                    margin: EdgeInsets.only(
                        top: (NavigatorRep().size.height / 3) - kToolbarHeight),
                    height: 50,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        spreadRadius: 10,
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      )
                    ]));
              }
              return const SizedBox();
            })
          ])
        ]));
  }
}
