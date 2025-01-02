import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';

class HistoryItem extends StatefulWidget {
  const HistoryItem(
      {required this.history,
      required this.onPressed,
      this.size,
      this.padding,
      this.showText = true,
      super.key});

  final HistoryRecord history;
  final Function() onPressed;
  final Size? size;
  final EdgeInsets? padding;
  final bool showText;
  @override
  State<HistoryItem> createState() => HistoryItemState();
}

class HistoryItemState extends State<HistoryItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Constants.colorCard,
        // padding: const EdgeInsets.only(top: 20),
        child: Container(
            margin: const EdgeInsets.only(left: 30, right: 30, top: 15),
            decoration: const BoxDecoration(
                color: Constants.colorCard,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(children: [
              if (widget.showText)
                Container(
                    // margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text('${widget.history.dateNice}')),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Constants.colorCard,
                            elevation: 0),
                        child: Row(children: [
                          Container(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 4, bottom: 4),
                              child:
                                  Text('${widget.size?.width.toInt()} images')),
                          Icon(Icons.arrow_forward_ios),
                          const SizedBox(width: 15)
                        ]),
                        // const SizedBox(width: 50),
                        // ElevatedButton(
                        //     onPressed: () {},
                        //     style: ElevatedButton.styleFrom(
                        //         padding: EdgeInsets.zero,
                        //         backgroundColor: Constants.colorCard,
                        //         elevation: 0),
                        //     child: Icon(Icons.arrow_forward_ios))
                        // Text('${widget.size?.width.toInt()} images')
                      )
                    ])),
              Padding(
                  padding: widget.padding ??
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: ElevatedButton(
                      onPressed: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        widget.onPressed();
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const LinearBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLow),
                      child: Image.file(File(widget.history.path),
                          cacheWidth: widget.size?.width.toInt() ?? 100,
                          cacheHeight: widget.size?.height.toInt() ?? 100)))
            ])));
  }
}

// NavigatorRep().size.width.toInt()
// NavigatorRep().size.width / 2