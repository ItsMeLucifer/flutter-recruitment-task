import 'package:flutter/material.dart';

class BorderedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget child;

  const BorderedButton({
    this.height,
    this.width,
    required this.child,
    super.key,
  });

  static const EdgeInsets padding = EdgeInsets.all(8.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.black12,
      ),
      padding: padding,
      child: child,
    );
  }
}
