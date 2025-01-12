import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';

enum SlideDirection { left, right }

class SlidableItem extends StatefulWidget {
  const SlidableItem(
      {required this.child,
      required this.controller,
      required this.onSlided,
      required this.button,
      required this.direction,
      super.key});
  final Widget child;
  final Function() onSlided;
  final SlidableController? controller;
  final Widget button;
  final SlideDirection direction;

  @override
  State<SlidableItem> createState() => SlidableItemState();
}

class SlidableItemState extends State<SlidableItem> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: ValueKey(widget.child.hashCode),
        controller: widget.controller,
        startActionPane: widget.direction == SlideDirection.left
            ? ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.40,
                children: [
                    CustomSlidableAction(
                        backgroundColor: Colors.transparent,
                        onPressed: (context) {
                          widget.onSlided();
                        },
                        child: widget.button)
                  ])
            : null,
        endActionPane: widget.direction == SlideDirection.right
            ? ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.40,
                children: [
                    CustomSlidableAction(
                        backgroundColor: Colors.transparent,
                        onPressed: (context) {
                          widget.onSlided();
                        },
                        child: widget.button)
                  ])
            : null,
        child: widget.child);
  }

  void doNothing(BuildContext context) {}
}
