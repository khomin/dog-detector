import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';

class HistoryItem extends StatefulWidget {
  const HistoryItem({required this.history, super.key});

  final HistoryRecord history;
  @override
  State<HistoryItem> createState() => HistoryItemState();
}

class HistoryItemState extends State<HistoryItem> {
  @override
  void initState() {
    super.initState();
    // _fetch();
  }

  // void _fetch() async {
  //   var history = await MyRep().history();
  //   setState(() {
  //     _history = history;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Footer'),
      Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Image.file(File(widget.history.path),
              cacheWidth: NavigatorRep().size.width.toInt()))
    ]);
  }
}
