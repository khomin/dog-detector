import 'package:flutter/material.dart';

class RoundBox extends StatelessWidget {
  const RoundBox(
      {required this.text,
      required this.color,
      required this.borderRadius,
      super.key});
  final String text;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 10),
        padding: const EdgeInsets.only(left: 14, right: 14, top: 3, bottom: 3),
        // width: 100,
        // height: 30,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        child: Center(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70))));
  }
}
