import 'package:flutter/material.dart';
import 'package:flutter_demo/components/hover_click.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox(
      {required this.value, required this.onChanged, super.key});
  final bool value;
  final Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: value,
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        });
    // return HoverClick(
    //     onPressedL: (_) {
    //       onChanged(false);
    //     },
    //     child: Container(
    //         margin: const EdgeInsets.only(left: 3, right: 3),
    //         width: 20,
    //         height: 20,
    //         decoration: BoxDecoration(
    //             shape: BoxShape.circle,
    //             border: Border.all(color: Colors.white, width: 2)),
    //         child: Container(
    //             padding: const EdgeInsets.all(3),
    //             child: Container(
    //               decoration: BoxDecoration(
    //                   color: value ? Colors.white : Colors.transparent,
    //                   shape: BoxShape.circle),
    //             ))));
  }
}
