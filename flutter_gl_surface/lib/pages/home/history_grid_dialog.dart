import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/home/history_item.dart';
import 'package:flutter_demo/pages/home/history_item_thumb.dart';
import 'package:flutter_demo/pages/home/history_view_dialog.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:flutter/material.dart';

class HistoryGridDialog {
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

class HistoryBoxDialogState extends State<HistoryGridBox> {
  // late Current _current;
  // var _doNotScroollToPreviewItem = false;
  // final _scrollTouch = ScrollTouch();
  // late PageController pageController;
  // final List<TransformationController> _controllerList = [];
  // final FocusNode _rawKeyLister = FocusNode();
  final ScrollController _scrollController = ScrollController();
  // late ListObserverController _observerController;
  // late final PageController _controller;
  Timer? _testTimer;
  final tag = 'mediaView';

  @override
  void initState() {
    super.initState();

    var startModel = widget.history[widget.initialIndex];
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
    // _rawKeyLister.dispose();
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
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                var model = widget.history[index];
                // return Container(color: Colors.pink, width: 100, height: 100);
                return HistoryItemThumbnail(
                    history: model,
                    size: itemWidth.toInt() - 2,
                    // padding: EdgeInsets.zero,
                    padding: EdgeInsets.all(1),
                    onPressed: () {
                      HistoryViewBoxDialog().show(
                          context: context,
                          models: widget.history,
                          initialIndex: index);
                    });
                // return HistoryViewBox(
                //     history: widget.history,
                //     // animationTicker: this,
                //     initialIndex: index);
              }))

      // Expanded(
      // child: ScrollConfiguration(
      //     behavior: NoGlowBehavior(),
      //     child: GridView.builder(
      //         itemCount: widget.history.length,
      //         padding: EdgeInsets.zero,
      //         // shrinkWrap: true,
      //         physics: const ClampingScrollPhysics(),
      //         gridDelegate:
      //             const SliverGridDelegateWithFixedCrossAxisCount(
      //           crossAxisCount: 3,
      //         ),
      //         itemBuilder: (context, index) {
      //           // var model = widget.history[index];
      //           return Container(
      //               color: Colors.pink, width: 100, height: 100);
      //           return HistoryViewBox(
      //               history: widget.history,
      //               // animationTicker: this,
      //               initialIndex: index);
      //           // .then((value) {});
      //           // return MenuClick(
      //           //     model: model,
      //           //     type: ClickType.search,
      //           //     room: widget.controller.room,
      //           //     child: MsgBodyThumbnailGalery(
      //           //         model: model,
      //           //         room: widget.room,
      //           //         key: ValueKey('${model.record.sendId}-galery'),
      //           //         selectedStream: selectedStream,
      //           //         width: itemWidth,
      //           //         height: itemWidth));
      //         })))
    ]));
    // });
  }

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
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
