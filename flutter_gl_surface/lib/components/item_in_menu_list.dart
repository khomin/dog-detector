import 'package:flutter/material.dart';
import 'package:flutter_demo/resource/constants.dart';

class ItemInMenuList extends StatelessWidget {
  const ItemInMenuList(
      {required this.useBorderTop,
      required this.useBorderBot,
      required this.height,
      required this.child,
      this.onClicked,
      super.key});
  final bool useBorderTop;
  final bool useBorderBot;
  final double height;
  final Widget child;
  final Function()? onClicked;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
            border: Border(
                top: useBorderTop
                    ? const BorderSide(
                        color: Constants.menuBorderColor, width: 1)
                    : BorderSide.none,
                bottom: useBorderBot
                    ? const BorderSide(
                        color: Constants.menuBorderColor, width: 1)
                    : BorderSide.none)),
        child: onClicked != null
            ? ElevatedButton(
                onPressed: () {
                  onClicked?.call();
                },
                autofocus: false,
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none),
                    padding: null,
                    alignment: Alignment.center,
                    animationDuration: Duration.zero,
                    shadowColor: Colors.transparent,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w300, fontSize: 12)),
                child: child)
            : child);
  }
}
