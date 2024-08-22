import 'package:flutter/material.dart';

class BorderedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget child;
  final void Function()? onTap;

  const BorderedButton({
    this.height,
    this.width,
    required this.child,
    this.onTap,
    super.key,
  });

  static const EdgeInsets padding = EdgeInsets.all(8.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.black12,
        ),
        padding: padding,
        child: Center(child: child),
      ),
    );
  }
}
