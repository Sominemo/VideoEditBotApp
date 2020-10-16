import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:videoeditbot_app/services/settings/settings.dart';
import 'package:videoeditbot_app/widgets/icon_tile.dart';

class DismissiblePromo extends StatelessWidget {
  DismissiblePromo(this.icon, this.title, this.subtitle, this.id, this.tap,
      {this.isThreeLine = true, this.useAccountCircle = true});
  final Widget icon;
  final String title, subtitle, id;
  final Function tap;
  final bool isThreeLine, useAccountCircle;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tap,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Dismissible(
          onDismissed: (dir) {
            Settings.prefs.setBool(id, false);
          },
          key: UniqueKey(),
          background: PlatformWidget(
            material: (_, __) => Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryTextTheme.bodyText1.color,
                  ),
                ),
              ),
            ),
            cupertino: (_, __) => Container(
              color: CupertinoTheme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Icon(
                    CupertinoIcons.delete,
                    color: CupertinoTheme.of(context).primaryContrastingColor,
                  ),
                ),
              ),
            ),
          ),
          child: IconTile(
            icon,
            Text(title),
            Text(subtitle),
            useAccountCircle: useAccountCircle,
          ),
        ),
      ),
    );
  }
}
