import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/pages/home/view_item1.dart';
import 'package:flutter_demo/pages/home/view_item2.dart';
import 'package:flutter_demo/pages/home/history_view_dialog.dart';
import 'package:flutter_demo/pages/model/grid_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/selection_repo.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class GridDialog {
  Future<FullViewItem?> show(
      {required BuildContext context,
      GlobalKey? key,
      // required TickerProvider animationTicker,
      required HistoryRecord history,
      int initialIndex = 0}) {
    // TODO: too much black noise
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
                  history: history,
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
  final HistoryRecord history;
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
  late final SelectionRep _selectRep;
  var _model = GridModel();
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

    _selectRep = SelectionRep();

    Timer(const Duration(milliseconds: 100), () async {
      var history = await MyRep().getHistory();
      if (!mounted || history.firstOrNull == null) return;
      var v = history.firstWhereOrNull((element) {
        return element.folderName == widget.history.folderName;
      });
      if (v != null && v.items.isNotEmpty) {
        _model.setHistory(v.items);
      }
      if (_model.history.isEmpty) {
        Navigator.of(context).pop();
      }
    });

    Future.microtask(() {
      _dispStream.add(MyRep().onHistory.listen((history) {
        var v = history.firstWhereOrNull((element) {
          return element.folderName == widget.history.folderName;
        });
        if (v != null && v.items.isNotEmpty) {
          _model.setHistory(v.items);
          _selectRep.history = v.items;
        }
      }));

      _dispStream.add(_selectRep.selectedStream.listen((value) {
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
    });

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

    // _current = Current(index: 0, model: startModel);
    // _current.index = widget.initialIndex;
    // _current.model = startModel;

    // _observerController = ListObserverController(controller: _scrollController);
    // for (int i = 0; i < widget.models.length; ++i) {
    //   _controllerList.add(TransformationController());
    // }
    // _controller = PageController(initialPage: _current.index);

    // MyRep().historyCache;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _testTimer?.cancel();
    _dispStream.dispose();
    _selectRep.dispose();
    _model.dispose();
    super.dispose();
  }

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
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Builder(builder: (context) {
            return Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    title: _header()),
                body: Column(children: [_view()]));
          });
        });
  }

  Widget _view() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate the width of each grid item by dividing the screen width by 3
    final itemWidth = screenWidth / 3;
    return Builder(builder: (context) {
      var history = context.watch<GridModel>().history;
      return Expanded(
          child: Column(children: [
        Expanded(
            child: GridView.builder(
                itemCount: history.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  var model = history[index];
                  // return Container(color: Colors.pink, width: 100, height: 100);
                  return ViewItem2(
                      history: model,
                      size: itemWidth.toInt() - 2,
                      selectionRep: _selectRep,
                      padding: const EdgeInsets.all(1),
                      onPressed: () {
                        // TODO: use report for history
                        FullViewDialog().show(
                            context: context,
                            models: history,
                            initialIndex: index);
                      });
                }))
      ]));
    });
  }

  Widget _header() {
    return SizedBox(
        height: kToolbarHeight,
        child: StreamBuilder(
            stream: _selectRep.selectedStream,
            builder: (context, snapshot) {
              var cnt = snapshot.data ?? 0;
              var model = context.watch<GridModel>();
              var label = model.history.firstOrNull?.dateHeader ?? '';
              return Row(children: [
                Row(children: [
                  const SizedBox(width: 25),
                  SizedBox(
                      width: 110,
                      child: cnt == 0
                          ? Text(label, style: const TextStyle(fontSize: 22))
                          : Text('$cnt', style: const TextStyle(fontSize: 18))),
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
                            onPressed: (v) async {
                              // TODO: full delete check
                              var v = _selectRep.getSelected(
                                  type: SearchType.media,
                                  resetSelection: false);
                              await MyRep().deleteHistory2(v);
                            }),
                        const SizedBox(width: 15),
                        RoundButton(
                            color: Constants.colorSecondary.withOpacity(0.8),
                            iconColor: Constants.colorCard.withOpacity(0.8),
                            size: 45,
                            radius: 20,
                            iconData: Icons.share,
                            useScaleAnimation: true,
                            onPressed: (_) {
                              var v = _selectRep.getSelected(
                                  type: SearchType.media, resetSelection: true);
                              MyRep().share(v);
                            })
                      ]))
                ]),
                const Spacer(),
                RoundButton(
                    color: Colors.transparent,
                    iconColor: Constants.colorTextAccent.withOpacity(0.8),
                    size: 50,
                    radius: 18,
                    vertTransform: true,
                    iconData: Icons.close,
                    onPressed: (p0) {
                      if (cnt > 0) {
                        _selectRep.stopSelection();
                      } else {
                        Navigator.of(context).pop();
                      }
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
  }
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
