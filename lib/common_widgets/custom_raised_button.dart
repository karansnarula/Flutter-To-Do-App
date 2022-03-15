import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final VoidCallback? onPressed;
  final double height;

  CustomRaisedButton(
      {required this.child,
      required this.color,
      this.borderRadius: 2.0,
      this.height: 40.0,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RaisedButton(
          child: child,
          color: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          disabledColor: color,
          onPressed: onPressed),
    );
  }
}
