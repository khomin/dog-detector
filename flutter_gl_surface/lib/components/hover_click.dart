import 'package:flutter/material.dart';

class HoverClick extends StatelessWidget {
  const HoverClick(
      {super.key,
      this.onPressedL,
      this.onPressedR,
      this.onHover,
      this.onHoverPos,
      this.onDragPos,
      this.onLongPress,
      this.activity,
      this.cursor = SystemMouseCursors.click,
      this.child});
  final Function(bool on)? onHover;
  final Function(Offset)? onHoverPos;
  final Function(DragUpdateDetails)? onDragPos;
  final Function(Offset)? onPressedL;
  final Function(Offset)? onPressedR;
  final Function(Offset)? onLongPress;
  final Widget? child;
  final Function()? activity;
  final MouseCursor? cursor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) {
          onPressedL?.call(details.globalPosition);
        },
        onLongPressStart: (details) {
          onLongPress?.call(details.globalPosition);
        },
        onSecondaryTapUp: (details) {
          onPressedR?.call(details.globalPosition);
        },
        onPanUpdate: onDragPos,
        child: MouseRegion(
            onHover: (pos) {
              activity?.call();
              onHoverPos?.call(pos.position);
            },
            cursor: cursor ?? SystemMouseCursors.basic,
            onEnter: (event) {
              onHover?.call(true);
            },
            onExit: (event) {
              onHover?.call(false);
            },
            child: child));
  }
}
