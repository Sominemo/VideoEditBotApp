import 'package:flutter/material.dart';

typedef methodCallback = Widget Function(void Function(Widget) f);

class VebScreen extends StatefulWidget {
  VebScreen(this.widget, [Key key]) : super(key: key ?? UniqueKey());
  final methodCallback widget;

  @override
  VebScreenState createState() => VebScreenState(widget);
}

class VebScreenState extends State<VebScreen> {
  VebScreenState(this.widgetConstructor);
  final methodCallback widgetConstructor;
  Widget w;

  void replace(Widget widget) {
    if (mounted) {
      setState(() {
        w = widget;
      });
    }
  }

  @override
  void initState() {
    w = widgetConstructor(replace);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: w,
        switchInCurve: Curves.easeInOut,
      ),
    );
  }
}
