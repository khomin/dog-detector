import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonRoundCorner extends StatelessWidget {
  const ButtonRoundCorner(
      {required this.colorIcon,
      required this.icon,
      required this.color,
      required this.onPressed,
      required this.radious,
      required this.width,
      this.borderColor,
      super.key});
  final Icon icon;
  final Function() onPressed;
  final double width;
  final Color color;
  final Color colorIcon;
  final Color? borderColor;
  final BorderRadiusGeometry radious;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        // width: 150 / 2,
        // width: 30,
        alignment: Alignment.center,
        // color: Colors.amber,
        // child: Container(
        // height: widget.size,
        // width: widget.size,
        // margin: widget.margin,
        child: Stack(children: [
          // 2
          ElevatedButton(
              onPressed: () => onPressed.call(),
              autofocus: false,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: radious,
                      side: borderColor != null
                          ? BorderSide(width: 1.5, color: borderColor!)
                          : BorderSide.none),
                  padding: null,
                  alignment: Alignment.center,
                  // ap
                  backgroundColor: color,
                  // maximumSize: Size(150 / 2, 70),
                  // fixedSize: Size(150 / 2, 70),
                  shadowColor: Colors.transparent,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    // color: Theme.of(context).colorScheme.baseColor1,
                  )),
              child: Center(child: icon

                  // child: Center(child: Text('1') //icon)
                  ))
        ]));
  }
}
