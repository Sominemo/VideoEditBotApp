import 'package:flutter/material.dart';

class InkWrapper extends StatelessWidget {
  final Color splashColor;
  final Widget child;
  final VoidCallback onTap, onLongPress;

  InkWrapper({
    this.splashColor,
    @required this.child,
    @required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: splashColor,
              onTap: onTap,
              onLongPress: onLongPress ?? () {},
              
            ),
          ),
        ),
      ],
    );
  }
}