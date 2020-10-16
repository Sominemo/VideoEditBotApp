import 'package:flutter/cupertino.dart';

class CupertinoCard extends StatelessWidget {
  CupertinoCard({this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        color: CupertinoTheme.of(context).barBackgroundColor,
        child: child,
      ),
    );
  }
}
