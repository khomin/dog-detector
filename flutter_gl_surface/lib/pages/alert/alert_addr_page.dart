import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/pages/alert/alert_model.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

class AlertAddrPage extends StatefulWidget {
  const AlertAddrPage({required this.model, super.key});
  final AlertModel model;

  @override
  State<AlertAddrPage> createState() => AlertAddrPageState();
}

class AlertAddrPageState extends State<AlertAddrPage> {
  final _focus = FocusNode();
  final _textCtr = TextEditingController();
  late final AlertModel _model;
  final tag = 'aletPageAddr';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _model = widget.model;
      _textCtr.text = widget.model.packetToAddr ?? '';
      _focus.requestFocus();
      _textCtr.addListener(() {
        var value = _textCtr.text;
        if (value.isEmpty) {
          _model.setPacketToAddr(v: null, saveConfig: true);
        } else if (isValidIP(value) || isValidURI(value)) {
          _model.setPacketToAddr(v: value, saveConfig: true);
        } else {
          _model.setPacketToAddr(v: null, saveConfig: true);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focus.dispose();
    _textCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: widget.model,
        builder: (context, child) {
          return Container(
              color: Constants.colorBar,
              child: SafeArea(
                  child: Scaffold(
                      backgroundColor: Constants.colorBar,
                      body: Stack(alignment: Alignment.center, children: [
                        Positioned(
                            top: (kToolbarHeight * 2) - 30,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                                decoration: const BoxDecoration(
                                    color: Constants.colorBgUnderCard,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20))))),
                        CustomScrollView(
                            physics: const ClampingScrollPhysics(),
                            slivers: [
                              SliverAppBar(
                                  backgroundColor: Constants.colorBar,
                                  automaticallyImplyLeading: false,
                                  flexibleSpace: _sliverAppBar()),
                              SliverToBoxAdapter(child: _header()),
                              DecoratedSliver(
                                  decoration: const BoxDecoration(
                                    color: Constants.colorBgUnderCard,
                                  ),
                                  sliver: SliverToBoxAdapter(child: _address()))
                            ])
                      ]))));
        });
  }

  Widget _sliverAppBar() {
    return Stack(children: [
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
                        const Text('Address', style: TextStyle(fontSize: 25))),
                const Spacer()
              ])))
    ]);
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 30,
        child: Stack(children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 40,
                  width: 100,
                  decoration: const BoxDecoration(
                      color: Constants.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)))))
        ]));
  }

  Widget _address() {
    return SizedBox(
        // margin: const EdgeInsets.only(top: 50),
        // color: Constants.colorBgUnderCard,
        // color: Colors.deepOrange,
        // width: double.infinity,
        height: NavigatorRep().size.height / 1.5,
        child: HoverClick(
            onPressedL: (_) {
              _focus.requestFocus();
            },
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Row(children: [
                    const Spacer(),
                    Flexible(
                        flex: 3,
                        child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                                color: Constants.colorCard,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                                child: TextFormField(
                                    controller: _textCtr,
                                    focusNode: _focus,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        hintText: 'ex: 192.168.1.1',
                                        hintStyle: TextStyle(
                                            color: Constants.colorTextAccent
                                                .withOpacity(0.3),
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                    style: const TextStyle(
                                        color: Constants.colorTextAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    textInputAction: TextInputAction.done,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a value';
                                      } else if (isValidIP(value)) {
                                        return null; // Valid IP
                                      } else if (isValidURI(value)) {
                                        return null; // Valid URI
                                      } else {
                                        return 'Invalid IP or URI';
                                      }
                                    },
                                    onChanged: (value) {},
                                    onFieldSubmitted: (value) {
                                      _model.setPacketToAddr(
                                          v: value, saveConfig: true);
                                    },
                                    onSaved: (value) {
                                      _model.setPacketToAddr(
                                          v: value, saveConfig: true);
                                    },
                                    scrollPadding: EdgeInsets.zero,
                                    cursorColor: Constants.colorTextAccent)))),
                    const Spacer()
                  ])),
              Positioned(
                  top: 220,
                  left: 20,
                  right: 20,
                  child: Builder(builder: (context) {
                    var model = context.watch<AlertModel>();
                    if (model.packetToAddr != null) {
                      return Column(children: [
                        const Text('Packet example:',
                            style: TextStyle(
                                color: Constants.colorTextAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 4),
                        Text(
                            '${model.packetToAddr}/${Constants.packet}/${DateTime.now().millisecondsSinceEpoch}',
                            style: const TextStyle(
                                color: Constants.colorTextSecond,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600))
                      ]);
                    }
                    return const SizedBox();
                  }))
            ])));
  }

  bool isValidIP(String ip) {
    try {
      InternetAddress(ip);
      return true; // Valid IP
    } catch (e) {
      return false; // Invalid IP
    }
  }

  bool isValidURI(String uri) {
    try {
      if (uri.startsWith('https://') || uri.startsWith('http://')) {
        var v = Uri.parse(uri);
        return v.host.isNotEmpty; // Valid URI
      }
    } catch (_) {}
    return false; // Invalid URI
  }
}
