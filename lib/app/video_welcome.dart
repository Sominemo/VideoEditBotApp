import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:videoeditbot_app/app/video_list.dart';
import 'package:videoeditbot_app/services/icons/veb_icons.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:videoeditbot_app/services/settings/settings.dart';
import 'package:videoeditbot_app/widgets/cupertino_card.dart';
import 'package:videoeditbot_app/widgets/dismissible.dart';

class VideosWelcome extends StatefulWidget {
  VideosWelcome(this.transitionMethod, this.isDiscordMode)
      : super(key: UniqueKey());
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

    final saved = Settings.prefs.getString(
        isDiscordMode ? 'saved_discord_server_id' : 'saved_username');
    saveOnSubmit = saveOnSubmit || saved != null;

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
          content: Text(isDiscordMode
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

    Navigator.of(context, rootNavigator: true).push(
      platformPageRoute(
        iosTitle: AppLocalizations.of(context).yourVideos,
        context: context,
        builder: (context) => VideoListView(input, isDiscordMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var promos = [
      if (isDiscordMode && Settings.getFlag('add_to_discord_promo', def: true))
        DismissiblePromo(
            PlatformWidget(
              material: (_, __) => Icon(Icons.add),
              cupertino: (_, __) => Icon(CupertinoIcons.add),
            ),
            AppLocalizations.of(context).discordWelcomeTitle,
            AppLocalizations.of(context).discordWelcomeDescription,
            'add_to_discord_promo', () {
          launch(
              'https://discord.com/oauth2/authorize?client_id=704169521509957703&permissions=8&scope=bot');
        }),
      if (isDiscordMode && Settings.getFlag('join_discord_promo', def: true))
        DismissiblePromo(
            PlatformWidget(
              material: (_, __) => Icon(Icons.group),
              cupertino: (_, __) => Icon(CupertinoIcons.group_solid),
            ),
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
            PlatformWidget(
              material: (_, __) => Icon(Icons.help),
              cupertino: (_, __) => Icon(CupertinoIcons.question_circle),
            ),
            AppLocalizations.of(context).commandsHelpSign,
            AppLocalizations.of(context).commandsHelpDescription,
            'videos_commands_help', () {
          launch(
              'https://github.com/GanerCodes/videoEditBot/blob/master/COMMANDS.md');
        }),
    ];

    var content = [
      PlatformWidget(
        material: (_, __) => Padding(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: promos,
            ),
            margin:
                EdgeInsets.symmetric(vertical: promos.isNotEmpty ? 15.0 : 0),
          ),
          padding: EdgeInsets.only(bottom: promos.isNotEmpty ? 15.0 : 0),
        ),
        cupertino: (_, __) => CupertinoCard(
            child: Column(
          children: promos,
        )),
      ),
      Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isDiscordMode
                  ? AppLocalizations.of(context).discordWelcomeTitle
                  : AppLocalizations.of(context).welcomeTitle),
              style: TextStyle(
                fontSize: DefaultTextStyle.of(context).style.fontSize * 1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(isDiscordMode
                  ? AppLocalizations.of(context).discordEnterIdDescription
                  : AppLocalizations.of(context).welcomeDescription),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  child: PlatformWidget(
                    material: (_, __) => FloatingActionButton(
                      child: Icon(Icons.arrow_forward),
                      onPressed: () {
                        searchVideos();
                      },
                    ),
                    cupertino: (_, __) => CupertinoButton(
                      child: Icon(CupertinoIcons.arrow_right),
                      onPressed: () {
                        searchVideos();
                      },
                    ),
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
                title: Text(AppLocalizations.of(context).rememberMe),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              cupertino: (_, __) => Row(
                children: [
                  PlatformSwitch(
                    activeColor: CupertinoTheme.of(context).primaryColor,
                    value: saveOnSubmit,
                    onChanged: (v) {
                      setState(() {
                        saveOnSubmit = v;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(AppLocalizations.of(context).rememberMe),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    ];

    return Center(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: content,
      ),
    ));
  }
}
