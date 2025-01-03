import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  const CircleButton(
      {required this.iconData,
      required this.color,
      required this.iconColor,
      required this.onPressed,
      this.padding,
      this.margin,
      this.iconSize,
      this.size,
      super.key});
  final IconData iconData;
  final Color iconColor;
  final Color color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? size;
  final double? iconSize;
  final Function(Offset)? onPressed;

  @override
  Widget build(BuildContext context) {
    var size2 = size;
    return Container(
        height: size,
        width: size,
        margin: margin,
        child: Stack(children: [
          // 2
          ElevatedButton(
              onPressed: () {
                onPressed?.call(Offset.zero);
              },
              key: key,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                shadowColor: color,
                fixedSize:
                    size2 != null ? Size(size2, size2) : const Size(50, 50),
                // alignment: Alignment.center,
                padding: EdgeInsets.zero,
                // backgroundColor: Colors.transparent,
              ),
              child: Icon(iconData, color: iconColor, size: iconSize ?? 30))
        ]));
  }
}
