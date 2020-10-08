import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:videoeditbot_app/app/screen.dart';
import 'package:videoeditbot_app/app/statistics.dart';
import 'package:videoeditbot_app/app/video_welcome.dart';
import 'package:videoeditbot_app/services/functions/account_sheet.dart';
import 'package:videoeditbot_app/services/icons/veb_icons.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:videoeditbot_app/services/init/link_router.dart';
import 'package:videoeditbot_app/services/settings/settings.dart';
import 'package:uni_links/uni_links.dart';

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
    return PlatformProvider(
      initialPlatform: TargetPlatform.iOS,
      builder: (context) => PlatformApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        material: (_, __) => MaterialAppData(
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
        ),
        cupertino: (_, __) => CupertinoAppData(
          theme: CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.systemOrange,
          ),
        ),
        home: InitLinkRouter(_initLink),
      ),
    );
  }
}

class VebHomescreen extends StatefulWidget {
  VebHomescreen({this.defaultTab = 1});
  final int defaultTab;

  @override
  _VebHomescreenState createState() => _VebHomescreenState(defaultTab);
}

class _VebHomescreenState extends State<VebHomescreen>
    with TickerProviderStateMixin {
  _VebHomescreenState(this.defaultTab);

  final int defaultTab;
  PlatformTabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = PlatformTabController(
      android: MaterialTabControllerData(),
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
      FlutterStatusbarcolor.setNavigationBarColor(
          Theme.of(context).bottomAppBarColor,
          animate: true);
      initial = true;
    }

    final sections = [
      BottomNavigationBarItem(
        icon: Icon(VebIcons.discord),
        label: AppLocalizations.of(context).discordMode,
        backgroundColor: Theme.of(context).bottomAppBarColor,
      ),
      BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => Icon(Icons.video_library),
          cupertino: (_, __) => Icon(CupertinoIcons.film),
        ),
        label: AppLocalizations.of(context).yourVideos,
        backgroundColor: Theme.of(context).bottomAppBarColor,
      ),
      BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => Icon(Icons.assessment),
          cupertino: (_, __) => Icon(CupertinoIcons.graph_circle),
        ),
        label: AppLocalizations.of(context).statistics,
        backgroundColor: Theme.of(context).bottomAppBarColor,
      ),
    ];
    final pages = [
      VebScreen((transitionMethod) {
        return VideosWelcome(
          transitionMethod,
          true,
        );
      }),
      VebScreen((transitionMethod) {
        return VideosWelcome(
          transitionMethod,
          false,
        );
      }),
      VebScreen((transitionMethod) {
        return Statistics(
          transitionMethod,
        );
      }),
    ];

    return PlatformTabScaffold(
      materialTabs: (_, __) => MaterialNavBarData(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Theme.of(context).textTheme.bodyText1.color,
        unselectedItemColor: Theme.of(context).textTheme.bodyText1.color,
      ),
      items: sections,
      tabController: _tabController,
      appBarBuilder: (_, __) => PlatformAppBar(
        title: PlatformText('Video Edit Bot'),
        trailingActions: [
          PlatformIconButton(
            padding: EdgeInsets.zero,
            materialIcon: Icon(Icons.account_circle),
            cupertinoIcon: Icon(CupertinoIcons.person_alt_circle),
            onPressed: () => AccountSheet.show(context),
          ),
        ],
      ),
      bodyBuilder: (context, index) => pages[index],
    );
  }
}
