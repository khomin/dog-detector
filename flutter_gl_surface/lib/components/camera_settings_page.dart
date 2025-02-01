import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/custom_checkbox.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/capture/camera_model.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/repo/settings_rep.dart';
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
  late CameraModel _model;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _model.init(
          captureIntervalSec: await SettingsRep().getCaptureIntervalSec(),
          minArea: await SettingsRep().getCaptureMinArea(),
          showAreaOnCapture: await SettingsRep().getCaptureShowArea());
    });
  }

  @override
  void dispose() {
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<CameraModel>();
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
                  RoundButton(
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
                      Builder(builder: (context) {
                        var minArea =
                            context.select<CameraModel, int>((v) => v.minArea);
                        return Row(children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text('Min area [$minArea]',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Constants.colorTextAccent))),
                          Expanded(
                              child: Slider(
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
                                  }))
                        ]);
                      }),
                      //
                      // capture image interval
                      Builder(builder: (context) {
                        var captureSec = context.select<CameraModel, int>(
                            (v) => v.captureIntervalSec);
                        return Row(children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text('Capture filter [$captureSec] sec',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Constants.colorTextAccent))),
                          Expanded(
                              child: Slider(
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
                                        .setCaptureImageIntVal(
                                            newValue.toInt());
                                  }))
                        ]);
                      }),
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
                            child: Builder(builder: (context) {
                              var showArea = context.select<CameraModel, bool>(
                                  (v) => v.showAreaOnCapture);
                              return CustomCheckBox(
                                  value: showArea,
                                  onChanged: (v) {
                                    context.read<CameraModel>().setShowArea(v);
                                  });
                            }))
                      ]),
                    ]))
          ]),
          Positioned(
              top: (NavigatorRep().size.height / 3),
              left: 0,
              right: 0,
              child: Builder(builder: (context) {
                var collapse =
                    context.select<AppModel, bool>((v) => v.collapse);
                if (collapse) {
                  return Container(
                      height: 50,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            spreadRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 0))
                      ]));
                }
                return const SizedBox();
              }))
        ]));
  }
}
