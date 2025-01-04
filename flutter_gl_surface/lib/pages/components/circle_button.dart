import 'package:flutter/material.dart';

class CircleButton extends StatefulWidget {
  const CircleButton(
      {required this.iconData,
      required this.color,
      required this.iconColor,
      required this.onPressed,
      this.padding,
      this.margin,
      this.iconSize,
      this.vertTransform = false,
      this.size,
      super.key});
  final IconData iconData;
  final Color iconColor;
  final Color color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? size;
  final double? iconSize;
  final bool vertTransform;
  final Function(Offset)? onPressed;

  @override
  CircleButtonState createState() => CircleButtonState();
}

class CircleButtonState extends State<CircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: _button());
  }

  Widget _button() {
    var size2 = widget.size;
    return Container(
        height: widget.size,
        width: widget.size,
        margin: widget.margin,
        child: Stack(children: [
          // 2
          ElevatedButton(
              onPressed: () async {
                _controller.forward();
                await Future.delayed(const Duration(milliseconds: 50));
                _controller.reverse();
                widget.onPressed?.call(Offset.zero);
              },
              key: widget.key,
              style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  animationDuration: const Duration(milliseconds: 20),
                  shadowColor: widget.color,
                  fixedSize:
                      size2 != null ? Size(size2, size2) : const Size(50, 50),
                  padding: EdgeInsets.zero,
                  backgroundColor: widget.color),
              child: Center(
                  child: widget.vertTransform
                      ? Transform.rotate(
                          angle: -90 *
                              3.1415927 /
                              180, // Rotate -90 degrees in radians
                          child: Icon(widget.iconData,
                              color: widget.iconColor,
                              size: widget.iconSize ?? 30))
                      : Icon(widget.iconData,
                          color: widget.iconColor,
                          size: widget.iconSize ?? 30)))
        ]));
  }
}
