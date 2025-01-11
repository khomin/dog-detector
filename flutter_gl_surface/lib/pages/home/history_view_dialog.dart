import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/home/history_item.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:flutter/material.dart';

class HistoryViewBoxDialog {
  Future<HistoryViewBox?> show(
      {required BuildContext context,
      GlobalKey? key,
      // required TickerProvider animationTicker,
      required List<HistoryRecord> models,
      int initialIndex = 0}) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.8),
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Column(
          children: [
            Expanded(
              child: HistoryViewBox(
                  history: models,
                  initialIndex: initialIndex,
                  // animationTicker: animationTicker,
                  key: key),
            ),
          ],
        );
      },
    );
  }
}

class HistoryViewBox extends StatefulWidget {
  const HistoryViewBox(
      {required this.history,
      required this.initialIndex,
      // required this.animationTicker,
      super.key});
  final List<HistoryRecord> history;
  final int initialIndex;
  // final TickerProvider animationTicker;

  @override
  State<HistoryViewBox> createState() => HistoryViewBoxState();
}

class Current {
  Current({required this.index, required this.model});
  int index;
  HistoryRecord model;
}

class ScrollTouch with ChangeNotifier {
  final Set<int> _touchPositions = {};
  var zoom = false;

  void savePointerPosition(int index) {
    _touchPositions.add(index);
    notifyListeners();
  }

  void clearPointerPosition(int index) {
    _touchPositions.remove(index);
    notifyListeners();
  }

  void setZoom(bool v) {
    if (zoom != v) {
      zoom = v;
      notifyListeners();
    }
  }
}

class HistoryViewBoxState extends State<HistoryViewBox> {
  late Current _current;
  var _doNotScroollToPreviewItem = false;
  final _scrollTouch = ScrollTouch();
  late PageController pageController;
  final List<TransformationController> _controllerList = [];
  final FocusNode _rawKeyLister = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late ListObserverController _observerController;
  late final PageController _controller;
  Timer? _testTimer;
  final tag = 'mediaView';

  @override
  void initState() {
    super.initState();

    var startModel = widget.history[widget.initialIndex];
    _current = Current(index: 0, model: startModel);
    _current.index = widget.initialIndex;
    _current.model = startModel;

    _observerController = ListObserverController(controller: _scrollController);
    for (int i = 0; i < widget.history.length; ++i) {
      _controllerList.add(TransformationController());
    }
    _controller = PageController(initialPage: _current.index);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _rawKeyLister.dispose();
    _testTimer?.cancel();
  }

  void _saveFile() async {
    // var model = _current.model;
    // if (model == null) return;
    // var path = await FileUtils.getDowloadPath(model.record.fileRec.fileName);
    // if (path == null) return;
    // if (await MsgRep.saveFileToDir(record: model.record, path: path)) {
    //   if (mounted) {
    //     UiHelper.showToast(context, 'Saved in $path', type: ToastType.normal);
    //   }
    // } else {
    //   if (mounted) UiHelper.showToast(context, 'Error');
    // }
  }

  void _scrollTo(int index) {
    _observerController.jumpTo(index: _current.index);
  }

  void _changeItem({required bool fromLine}) {
    if (fromLine) {
      _doNotScroollToPreviewItem = true;
    }
    _controller.jumpToPage(_current.index);
  }

  void _onInteractionStart(ScaleStartDetails details) {}

  void _onInteractionUpdate(ScaleUpdateDetails details, int index) {}

  void _onInteractionEnd(ScaleEndDetails details, int index) {
    final controller = _controllerList[index];
    double correctScaleValue = controller.value.getMaxScaleOnAxis();

    if (correctScaleValue == 1.0) {
      _scrollTouch.setZoom(false);
    } else {
      _scrollTouch.setZoom(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // surfaceTintColor: Theme.of(context).colorScheme.baseColor1,
            // backgroundColor: Theme.of(context).colorScheme.baseColor1,
            // centerTitle: true,
            // shadowColor: Theme.of(context).colorScheme.titel3,
            // foregroundColor: Theme.of(context).colorScheme.iconColor,
            automaticallyImplyLeading:
                false, //context.watch<AppModel>().drawerOn,
            titleSpacing: 0,
            //     (Platform.isIOS || Platform.isAndroid) ? 0 : null,
            title: _header()),
        body: Column(children: [
          // TOOD: header
          // DialogHeader(
          //     isCollapsed: true,
          //     height: UiHelper.isMobile()
          //         ? ConstValues.dialogHeaderLargeHeight
          //         : ConstValues.dialogHeaderMiddle,
          //     color: Colors.black.withOpacity(0.9),
          //     close: () {
          //       Navigator.pop(context);
          //     },
          //     child: _header()),
          //
          // pageBuilder
          _page()
        ]));
  }

  Widget _page() {
    return Builder(builder: (context) {
      var screen = MediaQuery.of(context).size;
      return Expanded(
          child: Container(
              color: Constants.colorCard,
              width: screen.width,
              height: screen.height - 100,
              child: Listener(
                  onPointerDown: (opm) {
                    _scrollTouch.savePointerPosition(opm.pointer);
                  },
                  onPointerMove: (opm) {
                    _scrollTouch.savePointerPosition(opm.pointer);
                  },
                  onPointerCancel: (opc) {
                    _scrollTouch.clearPointerPosition(opc.pointer);
                  },
                  onPointerUp: (opc) {
                    _scrollTouch.clearPointerPosition(opc.pointer);
                  },
                  child: ChangeNotifierProvider.value(
                      value: _scrollTouch,
                      builder: (context, child) {
                        var scroll = context.watch<ScrollTouch>();

                        return PageView.builder(
                            physics:
                                scroll._touchPositions.length > 1 || scroll.zoom
                                    ? const NeverScrollableScrollPhysics()
                                    : const CustomPageViewScrollPhysics(),
                            onPageChanged: _onPageChange,
                            controller: _controller,
                            itemCount: widget.history.length,
                            itemBuilder: (context, index) {
                              var model = widget.history[index];
                              return InteractiveViewer(
                                  maxScale: 5.0,
                                  minScale: 1.0,
                                  panEnabled: scroll.zoom,
                                  panAxis: PanAxis.free,
                                  onInteractionStart: _onInteractionStart,
                                  onInteractionUpdate: (details) =>
                                      _onInteractionUpdate(details, index),
                                  onInteractionEnd: (details) =>
                                      _onInteractionEnd(details, index),
                                  transformationController:
                                      _controllerList[index],
                                  child: _item());
                              // history: model,
                              // onPressed: () {},
                              // animationTicker: widget.animationTicker,
                              // isNextAwailable: _current.index <
                              //     widget.models.length - 1,
                              // isPreviousAwailable: _current.index > 0,
                              // onNext: () {
                              //   if (_current.index + 1 <
                              //       widget.models.length) {
                              //     _current.index++;
                              //     _changeItem(fromLine: false);
                              //   }
                              // },
                              // onPrevious: () {
                              //   if ((_current.index - 1) >= 0) {
                              //     _current.index--;
                              //     _changeItem(fromLine: false);
                              //   }
                              // },
                              // model: model
                            });
                      }))));
    });
  }

  void _onPageChange(int index) {
    _controllerList[index].value = Matrix4.identity();
    _current.index = index;
    var model = widget.history[index];
    var current = Current(index: index, model: model);
    setState(() {
      _current = current;
    });
    if (_doNotScroollToPreviewItem) {
      _doNotScroollToPreviewItem = false;
    } else {
      Future.microtask(() {
        _scrollTo(index);
      });
    }
  }

  // Widget _header() {
  //   return Builder(builder: (context) {
  //     // var fileRec = _current.model?.record.fileRec;
  //     return Expanded(
  //         child: Row(children: [
  //       //
  //       // file name
  //       Expanded(
  //           child: Text(
  //         'TODO',
  //         // fileRec?.fileName ?? '',
  //         maxLines: 1,
  //         overflow: TextOverflow.ellipsis,
  //         style: TextStyle(
  //             // color: Theme.of(context).colorScheme.white,
  //             fontSize: 15,
  //             fontWeight: FontWeight.w400),
  //       )),
  //       //
  //       // save file
  //       // Button2(
  //       //     iconData: Icons.download,
  //       //     iconColor: Theme.of(context).colorScheme.white,
  //       //     onPressed: () {
  //       //       _saveFile();
  //       //     })
  //     ]));
  //   });
  // }

  Widget _header() {
    return Builder(builder: (context) {
      return Container(
          height: kToolbarHeight,
          child: Row(children: [
            Row(children: [
              const SizedBox(width: 25),
              Text(widget.history.first.dateHeader,
                  style: const TextStyle(fontSize: 25)),
              const SizedBox(width: 25),
              Text(widget.history.first.dateSub,
                  style: const TextStyle(fontSize: 18))
            ]),
            const Spacer(),
            CircleButton(
                color: Colors.transparent,
                iconColor: Constants.colorTextAccent.withOpacity(0.8),
                size: 70,
                // margin: EdgeInsets.only(bottom: 10),
                vertTransform: true,
                iconData: Icons.close,
                // iconData: Icons.arrow_back_ios,
                onPressed: (p0) {
                  Navigator.of(context).pop();
                  // var model = context.read<AppModel>();
                  // model.setCollapse(!model.collapse);
                })
          ]));
      //   //
      //   // save file
      //   // Button2(
      //   //     iconData: Icons.download,
      //   //     iconColor: Theme.of(context).colorScheme.white,
      //   //     onPressed: () {
      //   //       _saveFile();
      //   //     })
      // ]));
    });
  }

  Widget _item() {
    var history = _current.model;
    return Builder(builder: (context) {
      return Container(
          // color: Colors.pink,
          // margin:
          //     const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 5),
          // decoration: BoxDecoration(
          //     color: Constants.colorCard,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Constants.colorBar.withOpacity(0.5),
          //         blurRadius: 15,
          //         offset: const Offset(0, 0),
          //       )
          //     ],
          //     borderRadius: const BorderRadius.all(Radius.circular(20))),
          // height: 270,
          child: Column(children: [
        Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // header
          // Padding(
          //     padding: const EdgeInsets.only(left: 20, top: 10),
          //     child: Row(children: [
          //       // Container(
          //       //     width: 50,
          //       //     height: 50,
          //       //     // color: Colors.pink,
          //       //     decoration: const BoxDecoration(
          //       //         color: Constants.colorBgUnderCard,
          //       //         borderRadius: BorderRadius.all(Radius.circular(10))),
          //       //     child: Column(
          //       //         mainAxisAlignment: MainAxisAlignment.center,
          //       //         children: [
          //       //           //
          //       //           // day of month
          //       //           Text('${history.date.day}',
          //       //               style: TextStyle(
          //       //                   color: Constants.colorTextAccent
          //       //                       .withOpacity(0.5),
          //       //                   fontSize: 16,
          //       //                   // fontFamily: 'Salsa',
          //       //                   fontWeight: FontWeight.bold)),
          //       //           //
          //       //           // month in string [DEC]
          //       //           Text(history.dateMonth.toUpperCase().substring(0, 3),
          //       //               style: const TextStyle(
          //       //                   color: Constants.colorTextSecond,
          //       //                   fontSize: 12,
          //       //                   fontFamily: 'Salsa',
          //       //                   fontWeight: FontWeight.w600))
          //       //         ])),
          //       // Padding(
          //       //     padding: const EdgeInsets.only(left: 10),
          //       //     child:
          //       //         //
          //       //         SizedBox(
          //       //             height: 50,
          //       //             child: Column(
          //       //                 crossAxisAlignment: CrossAxisAlignment.start,
          //       //                 mainAxisAlignment: MainAxisAlignment.center,
          //       //                 children: [
          //       //                   //
          //       //                   // header (Yesterday, Today etc)
          //       //                   Text(history.dateHeader,
          //       //                       style: TextStyle(
          //       //                           color: Constants.colorTextAccent
          //       //                               .withOpacity(0.5),
          //       //                           fontSize: 16,
          //       //                           fontWeight: FontWeight.bold)),
          //       //                   //
          //       //                   // second line (Year)
          //       //                   Text(history.dateSub,
          //       //                       style: const TextStyle(
          //       //                           color: Constants.colorTextSecond,
          //       //                           fontSize: 12,
          //       //                           fontFamily: 'Salsa',
          //       //                           fontWeight: FontWeight.w600))
          //       //                 ]))),
          //       // const Spacer(),
          //       // Padding(
          //       //     padding: const EdgeInsets.only(right: 20),
          //       //     child: Row(children: [
          //       //       Icon(Icons.photo_library_sharp,
          //       //           size: 18,
          //       //           color: Constants.colorTextAccent.withOpacity(0.5)),
          //       //       const SizedBox(width: 4),
          //       //       //
          //       //       // count of photos
          //       //       Text('${history.items.length}',
          //       //           style: const TextStyle(
          //       //               color: Constants.colorTextSecond,
          //       //               fontSize: 12,
          //       //               // fontFamily: 'Salsa',
          //       //               fontWeight: FontWeight.bold)),
          //       //     ]))
          //     ])),
          Stack(alignment: Alignment.center, children: [
            Image.file(File(history.path),
                // width: double.infinity,
                // height: 180,
                // fit: BoxFit.cover
                fit: BoxFit.contain),
            // Positioned(
            //     right: 5,
            //     bottom: 0,
            //     // top: 0,
            //     child: Container(
            //         // margin: EdgeInsets.only(top: 20, bottom: 20),
            //         decoration: BoxDecoration(
            //             // color: Colors.yellow,
            //             // color: Constants.colorBackgroundUnderCard
            //             //     .withOpacity(0.2),
            //             borderRadius: BorderRadius.all(
            //                 Radius.circular(10))),
            //         child: Row(children: [
            //           // Icon(Icons.image, color: Colors.white),
            //           Image.file(File(history.first.path),
            //               width: 80, height: 80),
            //           Image.file(File(history.first.path),
            //               width: 80, height: 80),
            //           Image.file(File(history.first.path),
            //               width: 80, height: 80),
            //         ])))
            // Positioned(
            //     right: 0,
            //     bottom: 0,
            //     child: Image.file(File(history.first.path),
            //         width: 80, height: 80)),
            // Positioned(
            //     right: 0,
            //     bottom: 40,
            //     child: Image.file(File(history.first.path),
            //         width: 80, height: 80)),
            // Positioned(
            //     right: 0,
            //     bottom: 80,
            //     child: Image.file(File(history.first.path),
            //         width: 80, height: 80))
          ])
        ]))
      ]));
    });
  }
}

class PagingScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  const PagingScrollPhysics({required this.itemDimension, super.parent});

  @override
  PagingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PagingScrollPhysics(
        itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 100000,
        stiffness: 10,
        damping: 0.8,
      );

  double _getPage(ScrollMetrics position) {
    return position.pixels / itemDimension;
  }

  double _getPixels(double page) {
    return page * itemDimension;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    // ignore: deprecated_member_use
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (velocity.abs() > toleranceFor(position).velocity) {
      return null;
    }
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 100000,
        stiffness: 0.1,
        damping: 0.1,
      );
}
