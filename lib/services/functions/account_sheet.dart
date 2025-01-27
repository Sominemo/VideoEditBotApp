import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:videoeditbot_app/app/video_welcome.dart';
import 'package:videoeditbot_app/services/icons/veb_icons.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:videoeditbot_app/services/settings/settings.dart';

class AccountSheet {
  static void show(BuildContext context) async {
    final discord = Settings.prefs.getString('saved_discord_server_id');
    final twitter = Settings.prefs.getString('saved_username');

    var changed = false;

    await showModalBottomSheet(
        context: context,
        builder: (context) {
          FlutterStatusbarcolor.setNavigationBarColor(
              Theme.of(context).scaffoldBackgroundColor,
              animate: false);
          FlutterStatusbarcolor.setStatusBarColor(Colors.transparent,
              animate: false);

          List<Widget> content;
          int length;

          void checkNClose() {
            length -= 1;
            if (length <= 0) Navigator.pop(context);
            changed = true;
          }

          content = <Widget>[
            if (twitter != null)
              Dismissible(
                key: UniqueKey(),
                child: ListTile(
                  leading: CircleAvatar(
                      child: Icon(
                    VebIcons.twitter,
                  )),
                  title: Text('Twitter'),
                  subtitle: Text(twitter),
                ),
                onDismissed: (direction) {
                  Settings.prefs.remove('saved_username');
                  checkNClose();
                },
                background: Container(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            if (discord != null)
              Dismissible(
                key: UniqueKey(),
                child: ListTile(
                  leading: CircleAvatar(
                      child: Icon(
                    VebIcons.discord,
                  )),
                  title: Text('Discord'),
                  subtitle: Text(discord),
                ),
                onDismissed: (direction) {
                  Settings.prefs.remove('saved_discord_server_id');
                  checkNClose();
                },
                background: Container(
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ];

          length = content.length;

          if (content.isEmpty) {
            content.add(
              ListTile(
                leading: Icon(Icons.turned_in_not),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                title: Center(
                  child: Text(AppLocalizations.of(context).noSignedInAccounts),
                ),
              ),
            );
          } else if (Settings.getFlag('promo_how_to_unlogin', def: true)) {
            content.insert(
              0,
              Card(
                clipBehavior: Clip.antiAlias,
                child: DismissiblePromo(
                  Icon(Icons.delete_sweep),
                  AppLocalizations.of(context).howToUnloginTitle,
                  AppLocalizations.of(context).howToUnloginText,
                  'promo_how_to_unlogin',
                  () {},
                  isThreeLine: false,
                  useAccountCircle: false,
                ),
              ),
            );
          }

          return Container(
            child: Wrap(
              children: content,
            ),
          );
        });

    // ignore: unawaited_futures
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).bottomAppBarColor,
        animate: true);
    // ignore: unawaited_futures
    FlutterStatusbarcolor.setStatusBarColor(
        Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        animate: true);

    // ignore: unawaited_futures
    if (changed) Navigator.popAndPushNamed(context, '/');
  }
}
