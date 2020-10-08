import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:videoeditbot_app/app/video_list.dart';
import 'package:videoeditbot_app/services/icons/veb_icons.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:videoeditbot_app/services/settings/settings.dart';
import 'package:videoeditbot_app/widgets/cupertino_ckechmark.dart';

class VideosWelcome extends StatefulWidget {
  VideosWelcome(this.transitionMethod, this.isDiscordMode);
  final bool isDiscordMode;
  final void Function(Widget w) transitionMethod;

  @override
  _VideosWelcomeState createState() => _VideosWelcomeState(
        transitionMethod,
        isDiscordMode,
      );
}

class _VideosWelcomeState extends State<VideosWelcome> {
  _VideosWelcomeState(this.transitionMethod, this.isDiscordMode);
  final bool isDiscordMode;
  final void Function(Widget w) transitionMethod;

  bool saveOnSubmit = false;
  String input = '';
  TextEditingController controller;

  @override
  void initState() {
    input = Settings.prefs.getString(
          isDiscordMode ? 'saved_discord_server_id' : 'saved_username',
        ) ??
        '';

    controller = TextEditingController(text: input);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void searchVideos() {
    input = input.trim();
    if (input.isEmpty) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: PlatformText(isDiscordMode
              ? AppLocalizations.of(context).discordEmptyUsernameError
              : AppLocalizations.of(context).emptyUsernameError),
        ),
      );
      return;
    }

    if (saveOnSubmit) {
      Settings.prefs.setString(
        isDiscordMode ? 'saved_discord_server_id' : 'saved_username',
        input,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoListView(input, isDiscordMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var promos = [
      if (isDiscordMode && Settings.getFlag('add_to_discord_promo', def: true))
        DismissiblePromo(
            Icon(Icons.add),
            AppLocalizations.of(context).discordWelcomeTitle,
            AppLocalizations.of(context).discordWelcomeDescription,
            'add_to_discord_promo', () {
          launch(
              'https://discord.com/oauth2/authorize?client_id=704169521509957703&permissions=8&scope=bot');
        }),
      if (isDiscordMode && Settings.getFlag('join_discord_promo', def: true))
        DismissiblePromo(
            Icon(Icons.group),
            AppLocalizations.of(context).discordServerPromoSign,
            AppLocalizations.of(context).discordServerPromoButton,
            'join_discord_promo', () {
          launch('https://discord.gg/cHjgTZ2');
        }),
      if (!isDiscordMode && Settings.getFlag('videos_twitter_promo', def: true))
        DismissiblePromo(
            Icon(VebIcons.twitter),
            AppLocalizations.of(context).botPromoSign,
            AppLocalizations.of(context).botPromoSignButton,
            'videos_twitter_promo', () {
          launch('https://twitter.com/videoeditbot');
        }),
      if (!isDiscordMode && Settings.getFlag('videos_commands_help', def: true))
        DismissiblePromo(
            Icon(Icons.help),
            AppLocalizations.of(context).commandsHelpSign,
            AppLocalizations.of(context).commandsHelpDescription,
            'videos_commands_help', () {
          launch(
              'https://github.com/GanerCodes/videoEditBot/blob/master/COMMANDS.md');
        }),
    ];

    final saved = Settings.prefs.getString(
        isDiscordMode ? 'saved_discord_server_id' : 'saved_username');
    saveOnSubmit = saveOnSubmit || saved != null;

    var content = [
      Padding(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: promos,
          ),
          margin: EdgeInsets.symmetric(vertical: promos.isNotEmpty ? 15.0 : 0),
        ),
        padding: EdgeInsets.only(bottom: promos.isNotEmpty ? 15.0 : 0),
      ),
      PlatformText(
        (isDiscordMode
            ? AppLocalizations.of(context).discordWelcomeTitle
            : AppLocalizations.of(context).welcomeTitle),
        style: TextStyle(
          fontSize: DefaultTextStyle.of(context).style.fontSize * 1.5,
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: PlatformText(isDiscordMode
            ? AppLocalizations.of(context).discordEnterIdDescription
            : AppLocalizations.of(context).welcomeDescription),
      ),
      Row(
        children: [
          Expanded(
            child: PlatformWidget(
              material: (context, target) {
                return TextFormField(
                  controller: controller,
                  onChanged: (v) {
                    setState(() {
                      input = v;
                    });
                  },
                  onFieldSubmitted: (v) {
                    setState(() {
                      input = v;
                    });
                    searchVideos();
                  },
                  decoration: InputDecoration(
                    labelText: (isDiscordMode
                        ? AppLocalizations.of(context).discordServerId
                        : AppLocalizations.of(context).twitterUsername),
                    border: OutlineInputBorder(borderSide: BorderSide()),
                  ),
                );
              },
              cupertino: (context, target) {
                return CupertinoTextField(
                  controller: controller,
                  onChanged: (v) {
                    setState(() {
                      input = v;
                    });
                  },
                  onSubmitted: (v) {
                    setState(() {
                      input = v;
                    });
                    searchVideos();
                  },
                  placeholder: (isDiscordMode
                      ? AppLocalizations.of(context).discordServerId
                      : AppLocalizations.of(context).twitterUsername),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: FloatingActionButton(
              child: Icon(Icons.arrow_forward),
              onPressed: () {
                searchVideos();
              },
            ),
          )
        ],
      ),
      PlatformWidget(
        material: (_, __) => CheckboxListTile(
          value: saveOnSubmit,
          onChanged: (v) {
            setState(() {
              saveOnSubmit = v;
            });
          },
          activeColor: Theme.of(context).accentColor,
          checkColor: Theme.of(context).accentIconTheme.color,
          title: PlatformText(AppLocalizations.of(context).rememberMe),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        cupertino: (_, __) => Row(
          children: [
            CupertinoCheckmark(
              defaultValue: saveOnSubmit,
              onChanged: (v) {
                setState(() {
                  saveOnSubmit = v;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: PlatformText(AppLocalizations.of(context).rememberMe),
            )
          ],
        ),
      ),
    ];

    return Center(
        child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: content,
        ),
      ),
    ));
  }
}

class DismissiblePromo extends StatelessWidget {
  DismissiblePromo(this.icon, this.title, this.subtitle, this.id, this.tap,
      {this.isThreeLine = true, this.useAccountCircle = true});
  final Icon icon;
  final String title, subtitle, id;
  final Function tap;
  final bool isThreeLine, useAccountCircle;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (dir) {
        Settings.prefs.setBool(id, false);
      },
      key: UniqueKey(),
      background: Container(
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
      child: ListTile(
        isThreeLine: isThreeLine,
        leading: (useAccountCircle
            ? CircleAvatar(
                child: icon,
              )
            : Padding(
                child: icon,
                padding: EdgeInsets.all(5),
              )),
        title: PlatformText(title),
        subtitle: PlatformText(subtitle),
        onTap: tap,
      ),
    );
  }
}
