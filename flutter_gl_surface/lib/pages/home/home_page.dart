import 'dart:async';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/page_transition.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/pages/home/grid_dialog.dart';
import 'package:flutter_demo/pages/home/search_page.dart';
import 'package:flutter_demo/pages/home/view_item1.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class HomePagePage extends StatefulWidget {
  const HomePagePage({super.key});

  @override
  State<HomePagePage> createState() => HomePagePageState();
}

class HomePagePageState extends State<HomePagePage>
    with TickerProviderStateMixin {
  final _scrollCtr = ScrollController();
  final _focus = FocusNode();
  late final Animation<double> _slideHeight;
  late final Animation<double> _slideOpacity;
  late AnimationController _ctrSlideTop;
  late AnimationController _ctrShakeIcon;
  late final Animation<double> _iconRotate;
  Timer? _scrollThrottleTm;
  final _onCloseSlide = BehaviorSubject<bool>.seeded(false);
  final _dispStream = DisposableStream();
  final tag = 'homePage';

  @override
  void initState() {
    super.initState();

    _ctrSlideTop = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideHeight = Tween<double>(
      begin: kToolbarHeight,
      end: kToolbarHeight * 3,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _slideOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _ctrShakeIcon = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _iconRotate = TweenSequence<double>([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.005, end: 0), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.005, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _ctrShakeIcon.view,
      curve: Curves
          .linear, // Use a linear curve for a consistent back-and-forth movement
    ));

    _scrollCtr.addListener(() {
      _scrollThrottleTm?.cancel();
      _scrollThrottleTm = Timer(const Duration(milliseconds: 50), () {
        _focus.unfocus();
        _onCloseSlide.add(true);
        if (_ctrSlideTop.isForwardOrCompleted) {
          _ctrSlideTop.reverse().orCancel;
        }
      });
    });

    _dispStream.add(MyRep().onHistory.listen((history) {
      if (!mounted) return;
      context.read<AppModel>().setHistory(history);
    }));

    Timer(const Duration(milliseconds: 100), () async {
      var history = await MyRep().getHistory();
      if (!mounted) return;
      var model = context.read<AppModel>();
      model.setHistory(history);
      if (model.history.isEmpty) {
        logInfo('$tag: no history');
        Timer(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          if (_ctrShakeIcon.isForwardOrCompleted) {
            _ctrShakeIcon.reverse().orCancel;
          } else {
            _ctrShakeIcon.forward().orCancel;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollCtr.dispose();
    _dispStream.dispose();
    _onCloseSlide.close();
    _scrollThrottleTm?.cancel();
    super.dispose();
  }

  void _handleOnSlide() {
    if (MyRep().onCaptureTime.valueOrNull == null) return;
    if (_ctrSlideTop.isForwardOrCompleted) {
      _ctrSlideTop.reverse().orCancel;
    } else {
      _ctrSlideTop.forward().orCancel;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          CustomScrollView(
              physics: const ClampingScrollPhysics(),
              controller: _scrollCtr,
              slivers: [
                AnimatedBuilder(
                    animation: _ctrSlideTop,
                    builder: (context, child) {
                      return SliverAppBar(
                          backgroundColor: Constants.colorBar,
                          toolbarHeight: _slideHeight.value,
                          automaticallyImplyLeading: false,
                          flexibleSpace: _sliverAppBar());
                    }),
                SliverToBoxAdapter(child: _header()),
                //
                DecoratedSliver(
                    decoration: const BoxDecoration(
                      color: Constants.colorBgUnderCard,
                    ),
                    sliver: SliverToBoxAdapter(child: _gallery()))
              ])
        ]));
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 60,
        child: Stack(children: [
          Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                  height: 40,
                  width: 100,
                  decoration: const BoxDecoration(
                      color: Constants.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))))),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  height: 50,
                  decoration: BoxDecoration(
                      color: Constants.colorBgUnderCard,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 0))
                      ]),
                  child: Row(children: [
                    const Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Icon(
                          Icons.search_outlined,
                          color: Constants.colorTextSecond,
                          size: 28,
                        )),
                    Flexible(
                        child: HoverClick(
                            onPressedL: (p0) {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    settings: const RouteSettings(),
                                    builder: (context) {
                                      return const SearchPage();
                                    },
                                  ));
                            },
                            child: Stack(children: [
                              const SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: Row(children: [
                                    Expanded(
                                        child: Text('Search',
                                            style: TextStyle(
                                                color:
                                                    Constants.colorTextSecond,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400))),
                                  ])),
                              Positioned(
                                  right: 15,
                                  bottom: 0,
                                  top: 0,
                                  child: StreamBuilder(
                                      stream: MyRep().onHistory,
                                      initialData:
                                          MyRep().onHistory.valueOrNull,
                                      builder: (context, snapshot) {
                                        var data = snapshot.data ?? [];
                                        var countDay =
                                            snapshot.data?.length ?? 0;
                                        var countAll = 0;
                                        for (var it in data) {
                                          countAll += it.items.length;
                                        }
                                        return Center(
                                            child: Text('$countDay/$countAll',
                                                style: const TextStyle(
                                                    color: Constants
                                                        .colorTextSecond,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400)));
                                      }))
                            ])))
                  ])))
        ]));
  }

  Widget _gallery() {
    return Builder(builder: (context) {
      var history =
          context.select<AppModel, List<HistoryRecord>>((v) => v.history);
      var size = MediaQuery.of(context).size;
      if (history.isEmpty) {
        return RotationTransition(
            turns: _iconRotate,
            child: SizedBox(
                // height: double.infinity, //((270 + 28) * history.length).toDouble(),
                // decoration: const BoxDecoration(color: Constants.colorBgUnderCard),
                height: size.height / 1.5,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RoundButton(
                          iconData: Icons.create_new_folder_rounded,
                          color: Constants.colorPrimary,
                          iconColor: Constants.colorBar,
                          size: (size.width / 5) + 15,
                          iconSize: size.width / 5,
                          useScaleAnimation: true,
                          useShadow: true,
                          onPressed: (p0) {
                            if (_ctrShakeIcon.isForwardOrCompleted) {
                              _ctrShakeIcon.reverse().orCancel;
                            } else {
                              _ctrShakeIcon.forward().orCancel;
                            }
                          }),
                      const SizedBox(height: 20),
                      const Text('There are no entries yet',
                          style: TextStyle(
                              color: Constants.colorTextAccent, fontSize: 18)),
                      // const SizedBox(height: 5),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Click',
                                style: TextStyle(
                                    color: Constants.colorTextAccent,
                                    fontSize: 18)),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Icon(Icons.create_new_folder_rounded,
                                    color: Constants.colorTextSecond
                                        .withOpacity(0.5))),
                            // Padding(
                            //     padding: EdgeInsets.only(left: 2, right: 8),
                            //     child: Text('Capture',
                            //         style: TextStyle(
                            //             color: Colors.black45, fontSize: 18))),
                            const Text('to start',
                                style: TextStyle(
                                    color: Constants.colorTextAccent,
                                    fontSize: 18))
                          ])
                    ])));
      }
      return SizedBox(
          height: ((270 + 28) * history.length).toDouble(),
          child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                SliverList.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      var model = history[index];
                      return ViewItem1(
                          history: model,
                          onCloseSlide: _onCloseSlide,
                          key: ValueKey('history-${model.items.lastOrNull}'),
                          onPressed: () {
                            GridDialog()
                                .show(
                                    context: context,
                                    history: model,
                                    initialIndex: index)
                                .then((value) {});
                          },
                          onDelete: () async {
                            await MyRep().deleteHistoryRoot([model]);
                          });
                    })
              ]));
    });
  }

  Widget _sliverAppBar() {
    return Stack(children: [
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
              opacity: _slideOpacity.value,
              child: SizedBox(
                  height: _slideHeight.value / 1.5,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundButton(
                            color: Constants.colorButtonRed.withOpacity(0.8),
                            iconColor: Constants.colorCard.withOpacity(0.8),
                            size: 55,
                            radius: 20,
                            useScaleAnimation: true,
                            iconData: Icons.stop_circle_sharp,
                            onPressed: (v) async {
                              _handleOnSlide();
                              await MyRep().setCaptureActive(false);
                              MyRep().stopCamera();
                            }),
                        const SizedBox(width: 15),
                        RoundButton(
                            color: Constants.colorSecondary.withOpacity(0.8),
                            iconColor: Constants.colorCard.withOpacity(0.8),
                            size: 55,
                            radius: 20,
                            useScaleAnimation: true,
                            iconData: Icons.close,
                            onPressed: (v) {
                              _handleOnSlide();
                            })
                      ])))),
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
                    child: const Text('Home', style: TextStyle(fontSize: 25))),
                //
                // duration
                HoverClick(
                    onPressedL: (p0) async {
                      _handleOnSlide();
                    },
                    child: SizedBox(
                        width: 130,
                        height: 50,
                        child: RepaintBoundary(
                            child:
                                Stack(alignment: Alignment.center, children: [
                          StreamBuilder(
                              stream: MyRep().onCaptureTime,
                              initialData: MyRep().onCaptureTime.valueOrNull,
                              builder: (context, snapshot) {
                                var duration = snapshot.data;
                                return AnimatedContainer(
                                    duration: Duration.zero,
                                    width: duration == null ? 10 : 130,
                                    height: duration == null ? 10 : 30,
                                    child: RoundBox(
                                        text: duration?.duration.format() ?? '',
                                        color: const Color.fromARGB(
                                                255, 211, 19, 5)
                                            .withOpacity(0.8),
                                        borderRadius: 40));
                              })
                        ])))),
                const Spacer()
              ])))
    ]);
  }
}
