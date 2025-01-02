import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';

class HistoryItemThumbnail extends StatefulWidget {
  const HistoryItemThumbnail(
      {required this.history,
      required this.onPressed,
      this.size,
      this.padding,
      super.key});

  final HistoryRecord history;
  final Function() onPressed;
  final Size? size;
  final EdgeInsets? padding;
  @override
  State<HistoryItemThumbnail> createState() => HistoryItemThumbnailState();
}

class HistoryItemThumbnailState extends State<HistoryItemThumbnail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Constants.colorCard,
        child: Container(
            margin: const EdgeInsets.only(left: 5),
            decoration: const BoxDecoration(
                color: Constants.colorCard,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(children: [
              Row(children: [
                Padding(
                    padding: widget.padding ??
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Image.file(File(widget.history.path),
                        cacheWidth: widget.size?.width.toInt() ?? 100,
                        cacheHeight: widget.size?.height.toInt() ?? 100))
              ])
            ])));
  }
}
