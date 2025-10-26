import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/item_in_menu_list.dart';
import 'package:flutter_demo/pages/alert/alert_model.dart';
import 'package:flutter_demo/pages/settings/settings_about.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/utils/converter.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late AlertModel _model;
  final _itemHeight = 60.0;
  final tag = 'settingsPage';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      _model.initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<AlertModel>();
    return Scaffold(
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
          CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [
            SliverAppBar(
                backgroundColor: Constants.colorBar,
                automaticallyImplyLeading: false,
                flexibleSpace: _sliverAppBar()),
            SliverToBoxAdapter(child: _header()),
            DecoratedSliver(
                decoration: const BoxDecoration(
                  color: Constants.colorBgUnderCard,
                ),
                sliver: _list())
          ])
        ]));
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
                        const Text('Settings', style: TextStyle(fontSize: 25))),
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

  Widget _list() {
    return SliverList.list(children: [
      //
      _account(),
      //
      _others()
    ]);
  }

  Widget _account() {
    return Builder(builder: (context) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 30, left: 25, right: 25),
                child: Row(children: [
                  Text('Account',
                      style: TextStyle(
                          color: Constants.menuFontColor1,
                          fontSize: Constants.menuFontSize1,
                          fontWeight: FontWeight.w400))
                ])),
            //
            // data
            ItemInMenuList(
                height: _itemHeight,
                useBorderTop: true,
                useBorderBot: true,
                onClicked: () {
                  showModalBottomSheet(
                      context: context,
                      barrierColor: Colors.black26,
                      builder: (BuildContext context) {
                        return Container(
                            height: 200,
                            color: Constants.colorBgUnderCard,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Want to free data?',
                                      style: TextStyle(
                                          color: Constants.menuFontColor1,
                                          fontSize: Constants.menuFontSize1,
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 30),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RoundButton(
                                            color: Constants.colorButtonRed
                                                .withValues(alpha: 0.8),
                                            iconColor: Constants.colorCard
                                                .withValues(alpha: 0.8),
                                            size: 55,
                                            radius: 20,
                                            useScaleAnimation: true,
                                            iconData: Icons.delete,
                                            onPressed: (v) async {
                                              Navigator.of(context).pop();
                                              MyRep().freeData();
                                            }),
                                        const SizedBox(width: 15),
                                        RoundButton(
                                            color: Constants.colorSecondary
                                                .withValues(alpha: 0.8),
                                            iconColor: Constants.colorCard
                                                .withValues(alpha: 0.8),
                                            size: 55,
                                            radius: 20,
                                            useScaleAnimation: true,
                                            iconData: Icons.close,
                                            onPressed: (v) {
                                              Navigator.of(context).pop();
                                            })
                                      ])
                                ]));
                      });
                },
                child: Row(children: [
                  const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Used disk',
                            style: TextStyle(
                                color: Constants.menuFontColor1,
                                fontSize: Constants.menuFontSize2,
                                fontWeight: FontWeight.w400))
                      ]),
                  const Spacer(),
                  const SizedBox(width: 20),
                  StreamBuilder(
                      stream: MyRep().onHistoryDataSize,
                      initialData: MyRep().onHistoryDataSize.valueOrNull,
                      builder: (context, snapshot) {
                        var size = snapshot.data ?? Int64.ZERO;
                        return Text(' ${Converter.convertBytesToKbMbGb(size)}',
                            style: const TextStyle(
                                color: Constants.menuFontColor1,
                                fontSize: Constants.menuFontSize2,
                                fontWeight: FontWeight.w400));
                      }),
                  const SizedBox(width: 20),
                  const Icon(Icons.delete_rounded,
                      color: Constants.colorPrimary)
                ]))
          ]);
    });
  }

  Widget _others() {
    return Builder(builder: (context) {
      return Column(children: [
        const Padding(
            padding: EdgeInsets.only(top: 40, bottom: 30, left: 25, right: 25),
            child: Row(children: [
              Text('Others',
                  style: TextStyle(
                      color: Constants.menuFontColor2,
                      fontSize: Constants.menuFontSize1,
                      fontWeight: FontWeight.w400))
            ])),
        //
        // share
        ItemInMenuList(
            useBorderTop: true,
            useBorderBot: false,
            onClicked: () {
              MyRep().shareApp();
            },
            height: _itemHeight,
            child: const Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Share this app',
                        style: TextStyle(
                            color: Constants.menuFontColor1,
                            fontSize: Constants.menuFontSize2,
                            fontWeight: FontWeight.w400))
                  ]),
              Spacer(),
              Icon(Icons.link, color: Constants.colorPrimary)
            ])),
        //
        // about the app
        ItemInMenuList(
            useBorderTop: true,
            useBorderBot: false,
            onClicked: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      settings: const RouteSettings(),
                      builder: (context) {
                        return const SettingsAbout();
                      }));
            },
            height: _itemHeight,
            child: const Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About',
                        style: TextStyle(
                            color: Constants.menuFontColor1,
                            fontSize: Constants.menuFontSize2,
                            fontWeight: FontWeight.w400)),
                  ]),
              Spacer(),
              Icon(Icons.info_rounded, color: Constants.colorPrimary)
            ])),
        //
        // lincenses
        // licenses page
        ItemInMenuList(
            useBorderTop: true,
            useBorderBot: true,
            onClicked: () {
              showLicensePage(context: context);
            },
            height: _itemHeight,
            child: const Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Licenses',
                        style: TextStyle(
                            color: Constants.menuFontColor1,
                            fontSize: Constants.menuFontSize2,
                            fontWeight: FontWeight.w400))
                  ]),
              Spacer(),
              Icon(Icons.description, color: Constants.colorPrimary)
            ])),
        //
        // version
        ItemInMenuList(
            useBorderTop: false,
            useBorderBot: false,
            height: 170,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Column(children: [
                  const SizedBox(height: 30),
                  Text('${Constants.appName} ${Constants.appVersion}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Constants.menuFontColor2,
                          fontSize: Constants.menuFontSize3,
                          fontWeight: FontWeight.w400))
                ])
              ]),
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  'assets/logo.png',
                  width: 60,
                  height: 60,
                  cacheWidth: 150,
                )
              ])
            ]))
      ]);
    });
  }
}
