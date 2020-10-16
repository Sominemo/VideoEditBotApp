import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IconTile extends StatelessWidget {
  IconTile(this.icon, this.title, this.description,
      {this.useAccountCircle = true});
  final Widget icon;
  final Widget title, description;
  final bool useAccountCircle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          PlatformWidget(
            material: (_, __) => (useAccountCircle
                ? CircleAvatar(
                    child: icon,
                  )
                : Container(
                    constraints: BoxConstraints.tight(Size(35, 35)),
                    alignment: Alignment.center,
                    child: icon,
                  )),
            cupertino: (_, __) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: CupertinoTheme.of(context).primaryColor,
              ),
              constraints: BoxConstraints.tight(Size(40, 40)),
              alignment: Alignment.center,
              child: IconTheme(
                  child: icon,
                  data: IconThemeData(
                      color:
                          CupertinoTheme.of(context).primaryContrastingColor)),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: (isMaterial(context)
                      ? Theme.of(context).textTheme.subtitle1
                      : TextStyle(
                          fontSize: 16,
                        )),
                  child: title,
                ),
                Opacity(
                  opacity: 0.5,
                  child: DefaultTextStyle(
                    style: (isMaterial(context)
                        ? Theme.of(context).textTheme.bodyText2
                        : TextStyle(
                            fontSize: 14,
                          )),
                    child: description,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
