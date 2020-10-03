import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:videoeditbot_app/app/screen.dart';
import 'package:videoeditbot_app/app/statistics.dart';
import 'package:videoeditbot_app/app/video_list.dart';
import 'package:videoeditbot_app/app/video_welcome.dart';
import 'package:videoeditbot_app/services/functions/account_sheet.dart';
import 'package:videoeditbot_app/services/functions/get_video.dart';
import 'package:videoeditbot_app/services/icons/veb_icons.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:videoeditbot_app/services/settings/settings.dart';
import 'package:uni_links/uni_links.dart';
import 'package:videoeditbot_app/video.dart';

Uri _initLink;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  await FlutterDownloader.initialize(debug: false);
  _initLink = await getInitialUri();

  runApp(VebApp());
}

class VebApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VebAppState();
}

class _VebAppState extends State<VebApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        accentColor: Colors.amber,
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      home: InitLinkRouter(),
    );
  }
}

class InitLinkRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final link = _initLink;

    if (link == null) return VebHomescreen();

    // If body is present
    if (link.pathSegments.isNotEmpty) {
      // If it's just one segment
      if (link.pathSegments.length == 1) {
        // And if this segment is discord, then it's Discord category
        if (link.pathSegments[0] == 'discord') {
          return VebHomescreen(defaultTab: 1);
        }

        return VideoListView(link.pathSegments[0], false);
      } else if (link.pathSegments.length == 2) {
        if (link.pathSegments[0] == 'discord') {
          return VideoListView(link.pathSegments[1], true);
        }

        return FutureBuilder(
          future: () async {
            final data = await getVideo(
                false, link.pathSegments[0], {'id': link.pathSegments[1]});

            return VideoScreen(
              data.asJson,
              link.pathSegments[0],
              false,
              thumb: Image.network(data.asJson['thumbnailUrl']),
              backToOut: true,
            );
          }(),
          builder: (context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasData) {
              return snapshot.data;
            }
            return VebHomescreen();
          },
        );
      } else if (link.pathSegments.length == 3) {
        if (link.pathSegments[0] == 'discord') {
          return FutureBuilder(
            future: () async {
              final data = await getVideo(
                  false, link.pathSegments[1], {'id': link.pathSegments[1]});

              return VideoScreen(
                data.asJson,
                link.pathSegments[1],
                false,
                thumb: Image.network(data.asJson['thumbnailUrl']),
                backToOut: true,
              );
            }(),
            builder: (context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasData) {
                return snapshot.data;
              }
              return VebHomescreen();
            },
          );
        }
      }
    } else {
      if (link.hasFragment) {
        if (link.fragment == 'discord') {
          return VebHomescreen(
            defaultTab: 1,
          );
        } else if (link.fragment == 'statistics') {
          return VebHomescreen(
            defaultTab: 2,
          );
        } else {
          return VebHomescreen(
            defaultTab: 0,
          );
        }
      }
    }

    return VebHomescreen();
  }
}

class VebHomescreen extends StatefulWidget {
  VebHomescreen({this.defaultTab = 0});
  final int defaultTab;

  @override
  _VebHomescreenState createState() => _VebHomescreenState(defaultTab);
}

class _VebHomescreenState extends State<VebHomescreen>
    with TickerProviderStateMixin {
  _VebHomescreenState(this.defaultTab);

  final int defaultTab;
  TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: defaultTab,
    );
    super.initState();
  }

  static bool initial = false;

  @override
  Widget build(BuildContext context) {
    if (!initial) {
      FlutterStatusbarcolor.setStatusBarColor(Theme.of(context).primaryColor,
          animate: true);
      FlutterStatusbarcolor.setNavigationBarColor(Theme.of(context).bottomAppBarColor,
          animate: true);
      initial = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Edit Bot'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => AccountSheet.show(context),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 1,
        color: Theme.of(context).bottomAppBarColor,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.transparent,
          tabs: [
            Tab(
              icon: Icon(Icons.video_library),
              text: AppLocalizations.of(context).yourVideos,
            ),
            Tab(
              icon: Icon(VebIcons.discord),
              text: AppLocalizations.of(context).discordMode,
            ),
            Tab(
              icon: Icon(Icons.assessment),
              text: AppLocalizations.of(context).statistics,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          VebScreen((transitionMethod) {
            return VideosWelcome(
              transitionMethod,
              false,
            );
          }),
          VebScreen((transitionMethod) {
            return VideosWelcome(
              transitionMethod,
              true,
            );
          }),
          VebScreen((transitionMethod) {
            return Statistics(
              transitionMethod,
            );
          }),
        ],
      ),
    );
  }
}
