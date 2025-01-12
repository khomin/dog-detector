import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/home/view_item1.dart';
import 'package:flutter_demo/pages/home/view_item2.dart';
import 'package:flutter_demo/pages/home/history_view_dialog.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/selection_repo.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:flutter/material.dart';

class GridDialog {
  Future<FullViewItem?> show(
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
              child: HistoryGridBox(
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

class HistoryGridBox extends StatefulWidget {
  const HistoryGridBox(
      {required this.history,
      required this.initialIndex,
      // required this.animationTicker,
      super.key});
  final List<HistoryRecord> history;
  final int initialIndex;
  // final TickerProvider animationTicker;

  @override
  State<HistoryGridBox> createState() => HistoryBoxDialogState();
}

class HistoryBoxDialogState extends State<HistoryGridBox>
    with TickerProviderStateMixin {
  // late Current _current;
  // var _doNotScroollToPreviewItem = false;
  // final _scrollTouch = ScrollTouch();
  // late PageController pageController;
  // final List<TransformationController> _controllerList = [];
  // final FocusNode _rawKeyLister = FocusNode();
  final _scrollController = ScrollController();
  late final SelectionRep _selectionRep;
  // late ListObserverController _observerController;
  // late final PageController _controller;
  late AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  var _selectionActive = false;
  final _dispStream = DisposableStream();
  Timer? _testTimer;
  final tag = 'mediaView';

  @override
  void initState() {
    super.initState();

    _selectionRep = SelectionRep(history: widget.history);
    // var startModel = widget.history[widget.initialIndex];

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animationController.addStatusListener((status) {
      //   if (status == AnimationStatus.completed) {
      //     _controller.reverse();
      //   }
    });

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _animationController.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _dispStream.add(_selectionRep.selectedStream.listen((value) {
      if (value == 0) {
        _animationController.reverse().orCancel;
      } else {
        if (!_selectionActive) {
          if (_animationController.isForwardOrCompleted) {
            _animationController.reverse().orCancel;
          } else {
            _animationController.forward().orCancel;
          }
        }
      }
      _selectionActive = value > 0;
    }));

    // _current = Current(index: 0, model: startModel);
    // _current.index = widget.initialIndex;
    // _current.model = startModel;

    // _observerController = ListObserverController(controller: _scrollController);
    // for (int i = 0; i < widget.models.length; ++i) {
    //   _controllerList.add(TransformationController());
    // }
    // _controller = PageController(initialPage: _current.index);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _testTimer?.cancel();
    _dispStream.dispose();
  }

  // void _animation() {
  // if (_animationController.isForwardOrCompleted) {
  //   _animationController.reverse().orCancel;
  // } else {
  //   _animationController.forward().orCancel;
  // }
  // }

  // void _saveFile() async {
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
  // }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      // var fileRec = _current.model?.record.fileRec;
      // if (fileRec == null || fileRec.width == 0 || fileRec.height == 0) {
      //   logError('$tag: invalid width or height');
      // }
      // return Text('ddjd');
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
            // Text('ddjd'),
            // TOOD: header
            // _header(),
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
            _view()
            // _page()
          ]));
    });
  }

  Widget _view() {
    // return Builder(builder: (context) {
    // var data = widget.controller.mediaList; // Get the width of the screen
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate the width of each grid item by dividing the screen width by 3
    final itemWidth = screenWidth / 3;
    return Expanded(
        child: Column(children: [
      Expanded(
          child: GridView.builder(
              itemCount: widget.history.length,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) {
                var model = widget.history[index];
                // return Container(color: Colors.pink, width: 100, height: 100);
                return ViewItem2(
                    history: model,
                    size: itemWidth.toInt() - 2,
                    selectionRep: _selectionRep,
                    padding: const EdgeInsets.all(1),
                    onPressed: () {
                      FullViewDialog().show(
                          context: context,
                          models: widget.history,
                          initialIndex: index);
                    });
              }))
    ]));
  }

  Widget _header() {
    return Builder(builder: (context) {
      return SizedBox(
          height: kToolbarHeight,
          child: StreamBuilder(
              stream: _selectionRep.selectedStream,
              builder: (context, snapshot) {
                var cnt = snapshot.data ?? 0;

                return Row(children: [
                  Row(children: [
                    const SizedBox(width: 25),
                    SizedBox(
                        width: 110,
                        child: cnt == 0
                            ? Text(widget.history.first.dateHeader,
                                style: const TextStyle(fontSize: 22))
                            : Text('$cnt',
                                style: const TextStyle(fontSize: 18))),
                    const SizedBox(width: 10),
                    ScaleTransition(
                        scale: _scaleAnimation,
                        child: Row(children: [
                          RoundButton(
                              color: Constants.colorButtonRed.withOpacity(0.8),
                              iconColor: Constants.colorCard.withOpacity(0.8),
                              size: 45,
                              radius: 20,
                              useScaleAnimation: true,
                              iconData: Icons.delete_outline,
                              onPressed: (v) {
                                MyRep().delete(widget.history);
                              }),
                          const SizedBox(width: 15),
                          RoundButton(
                              color: Constants.colorSecondary.withOpacity(0.8),
                              iconColor: Constants.colorCard.withOpacity(0.8),
                              size: 45,
                              radius: 20,
                              iconData: Icons.share,
                              useScaleAnimation: true,
                              onPressed: (v) {
                                MyRep().share(widget.history);
                              })
                        ]))
                  ]),
                  const Spacer(),
                  RoundButton(
                      color: Colors.transparent,
                      iconColor: Constants.colorTextAccent.withOpacity(0.8),
                      size: 50,
                      radius: 18,
                      // margin: EdgeInsets.only(bottom: 10),
                      vertTransform: true,
                      iconData: Icons.close,
                      // iconData: Icons.arrow_back_ios,
                      onPressed: (p0) {
                        Navigator.of(context).pop();
                        // var model = context.read<AppModel>();
                        // model.setCollapse(!model.collapse);
                      }),
                  const SizedBox(width: 8)
                ]);
              }));
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
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
