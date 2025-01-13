import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/subjects.dart';

enum SearchStatus { off, on }

enum GoToResultType { showInChat, showInView }

enum SearchType {
  //text,
  media
//, file, links
}

class GoToResult {
  GoToResult({required this.type, required this.model, this.page});
  GoToResultType type;
  HistoryRecord model;
  List<HistoryRecord>? page;
}

class SelectionRep {
  SelectionRep({this.history = const []});
  final onResult = BehaviorSubject<List<HistoryRecord>>();
  final onStatus = BehaviorSubject<SearchStatus>()..add(SearchStatus.off);
  final onBusy = BehaviorSubject<bool>();
  final onGoToResult = PublishSubject<GoToResult>();
  final onAllMsgCount = BehaviorSubject<int>();
  final onMediaMsgCount = BehaviorSubject<int>();
  final onFileMsgCount = BehaviorSubject<int>();
  final onLinkMsgCount = BehaviorSubject<int>();
  final selectedStream = BehaviorSubject<int>();
  final onForward = BehaviorSubject<List<HistoryRecord>>();
  final searchNode = FocusNode();
  List<HistoryRecord> history;
  bool active = false;

  // private
  Timer? typeDelay;

  // List<HistoryRecord> get fullList => _scan?.fullList ?? [];
  // List<HistoryRecord> get mediaList => _scan?.mediaList ?? [];
  // List<HistoryRecord> get fileList => _scan?.fileList ?? [];
  // List<HistoryRecord> get linkList => _scan?.linkList ?? [];
  // List<HistoryRecord> get textResult => _scan?.textList ?? [];
  // String? get query => _scan?.query;
  int get selectedCnt => selectedStream.valueOrNull ?? 0;

  // Future<PageResultMessage> Function(
  //     {required Int64 idm,
  //     required int count,
  //     required MoveTo moveTo})? getMessage;

  // SearchScan? _scan;

  final tag = 'selectionRep';

  void dispose() {
    for (var it in history) {
      it.selection = false;
    }
    searchNode.dispose();
    onResult.close();
    onStatus.close();
    onBusy.close();
    onGoToResult.close();
    onAllMsgCount.close();
    onMediaMsgCount.close();
    onFileMsgCount.close();
    onLinkMsgCount.close();
  }

  // void searchQuery(String? query) async {
  //   typeDelay?.cancel();
  //   typeDelay = Timer(const Duration(milliseconds: 500), () async {
  //     typeDelay = null;
  //     _scan?.searchQuery(query);
  //   });
  // }

  // void startSearch() async {
  //   try {
  //     active = true;
  //     onStatus.add(SearchStatus.on);
  //     _scan = SearchScan(
  //       room: room,
  //       getMessage: getMessage,
  //       onBusy: (v) {
  //         onBusy.add(v);
  //       },
  //       onResult: (v) {
  //         onResult.add(v);
  //       },
  //       onAllMsgCount: (v) {
  //         onAllMsgCount.add(v);
  //       },
  //       onFileMsgCount: (v) {
  //         onFileMsgCount.add(v);
  //       },
  //       onLinkMsgCount: (v) {
  //         onLinkMsgCount.add(v);
  //       },
  //       onMediaMsgCount: (v) {
  //         onMediaMsgCount.add(v);
  //       },
  //     );
  //     await _scan?.scanAll(force: true);
  //     Future.delayed(const Duration(milliseconds: 100), () {
  //       searchNode.requestFocus();
  //     });
  //   } catch (ex) {
  //     logWarning('$tag: start, ex: [$ex]');
  //   }
  // }

  Future stopSelection({bool mounted = true}) async {
    try {
      // _scan?.clear();
      // _scan?.stop();
      onBusy.add(false);
      // _scan?.onAllMsgCount = null;
      // _scan?.onBusy = null;
      // _scan?.onMediaMsgCount = null;
      // _scan?.onFileMsgCount = null;
      // _scan?.onLinkMsgCount = null;
      // _scan?.onResult = null;
      for (var it in history) {
        it.selection = false;
      }
      active = false;
      onStatus.add(SearchStatus.off);
      onForward.add([]);
      selectedStream.add(0);
    } catch (ex) {
      logWarning('$tag: stop, ex: [$ex]');
    }
  }

  List<HistoryRecord> getSelected(
      {required SearchType type, bool resetSelection = false}) {
    var list = <HistoryRecord>[];
    switch (type) {
      // case SearchType.text:
      //   list = textResult.where((it) => it.isSelected);
      //   break;
      case SearchType.media:
        list = history.where((it) => it.selection).toList();
        break;
      // case SearchType.file:
      //   list = fileList.where((it) => it.isSelected);
      //   break;
      // case SearchType.links:
      //   list = linkList.where((it) => it.isSelected);
      //   break;
    }
    if (list.isEmpty) return [];
    selectedStream.add(0);
    // onForward.add(list.toList());
    if (resetSelection) {
      for (var it in list) {
        it.selection = false;
      }
    }
    return list;
  }

  // void forwardSelected(SearchType type) {
  //   Iterable<HistoryRecord> list;
  //   switch (type) {
  //     // case SearchType.text:
  //     //   list = textResult.where((it) => it.isSelected);
  //     //   break;
  //     case SearchType.media:
  //       list = history.where((it) => it.selection);
  //       break;
  //     // case SearchType.file:
  //     //   list = fileList.where((it) => it.isSelected);
  //     //   break;
  //     // case SearchType.links:
  //     //   list = linkList.where((it) => it.isSelected);
  //     //   break;
  //   }
  //   if (list.isEmpty) return;
  //   selectedStream.add(0);
  //   onForward.add(list.toList());
  //   for (var it in list) {
  //     it.selection = false;
  //   }
  // }

  void releaseSelection() {
    var v = selectedStream.valueOrNull ?? 0;
    if (v > 0) {
      selectedStream.add(v - 1);
    }
  }

  void addSelection() {
    var v = selectedStream.valueOrNull ?? 0;
    selectedStream.add(v + 1);
  }
}
