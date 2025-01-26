import 'package:flutter/cupertino.dart';
import 'package:flutter_demo/resource/constants.dart';

class ItemInMenuList extends StatelessWidget {
  const ItemInMenuList(
      {required this.useBorderTop,
      required this.useBorderBot,
      required this.height,
      required this.child,
      super.key});
  final bool useBorderTop;
  final bool useBorderBot;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.only(left: 25, right: 25),
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
        child: child);
  }
}
