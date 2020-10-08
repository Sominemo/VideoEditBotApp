import 'package:flutter/cupertino.dart';

class CupertinoCheckmark extends StatefulWidget {
  CupertinoCheckmark({this.defaultValue = false, this.onChanged});
  final bool defaultValue;
  final void Function(bool value) onChanged;

  @override
  _CupertinoCheckmarkState createState() =>
      _CupertinoCheckmarkState(defaultValue: defaultValue, onChanged: onChanged);
}

class _CupertinoCheckmarkState extends State<CupertinoCheckmark> {
  _CupertinoCheckmarkState({this.defaultValue = false, this.onChanged});
  final bool defaultValue;
  final void Function(bool value) onChanged;

  bool _value;
  bool get value => _value;
  set value(bool v) {
    final t = value == v;

    setState(() {
      _value = v;
    });

    if (!t) onChanged(v);
  }

  @override
  void initState() {
    _value = defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          value = !value;
        },
        child: Icon(
          value
              ? CupertinoIcons.checkmark_alt_circle_fill
              : CupertinoIcons.circle,
          color: (value ? null : CupertinoColors.inactiveGray),
        ),
      ),
    );
  }
}
