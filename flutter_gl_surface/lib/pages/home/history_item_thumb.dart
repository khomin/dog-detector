import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/hover_click.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';

class HistoryItemThumbnail extends StatefulWidget {
  const HistoryItemThumbnail(
      {required this.history,
      required this.onPressed,
      required this.size,
      this.padding,
      super.key});

  final HistoryRecord history;
  final Function() onPressed;
  final int size;
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
        child: HoverClick(
            onPressedL: (p0) {
              widget.onPressed();
            },
            child: Column(children: [
              Row(children: [
                Padding(
                    padding: widget.padding ??
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Stack(children: [
                      Icon(Icons.image,
                          color: Colors.black12, size: widget.size.toDouble()),
                      Image.file(
                        File(widget.history.path),
                        width: widget.size.toDouble(),
                        height: widget.size.toDouble(),
                        cacheWidth: widget.size * 2,
                        // cacheHeight: widget.size ?? 100,
                        // fit: BoxFit.fitWidth
                        fit: BoxFit.cover,
                        // fit: BoxFit.scaleDown
                        //
                      )
                    ]))
              ])
            ])));
  }
}
