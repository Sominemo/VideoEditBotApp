import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';
import 'package:videoeditbot_app/services/api/types.dart';
import 'package:videoeditbot_app/services/functions/download_video.dart';
import 'package:videoeditbot_app/services/functions/get_video.dart';
import 'package:videoeditbot_app/services/functions/share.dart';
import 'package:videoeditbot_app/services/icons/veb_icons.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class VideoScreen extends StatefulWidget {
  VideoScreen(this.data, this.username, this.isDiscordMode,
      {this.thumb, this.backToOut})
      : type = data['type'];
  final Map<String, dynamic> data;
  final Image thumb;
  final String username, type;
  final bool isDiscordMode, backToOut;

  @override
  _VideoScreenState createState() =>
      _VideoScreenState(data, username, isDiscordMode,
          thumb: thumb, backToOut: backToOut, type: type);
}

class _VideoScreenState extends State<VideoScreen> {
  _VideoScreenState(this.data, this.username, this.isDiscordMode,
      {this.thumb, this.backToOut, this.type});
  final Map<String, dynamic> data;
  final Image thumb;
  final String username, type;
  final bool isDiscordMode, backToOut;

  Future<VebResponse> _videoInfoWait;

  @override
  void initState() {
    _videoInfoWait = getVideo(isDiscordMode, username, data);

    sheetController = PanelController();

    super.initState();
  }

  PanelController sheetController;

  void sheet() {
    if (sheetController.isPanelShown) {
      sheetController.hide();
    } else {
      sheetController.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).bottomAppBarColor,
        animate: true);

    final sheet = SlidingUpPanel(
      controller: sheetController,
      backdropTapClosesPanel: true,
      backdropEnabled: true,
      color: Theme.of(context).bottomAppBarColor,
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      body: ListView(
        children: [
          VideoPlayerScreen(
            data,
            username,
            isDiscordMode,
            sheetController,
            thumb: thumb,
            backToOut: backToOut,
            type: type,
          ),
        ],
      ),
      parallaxEnabled: true,
      minHeight: 70,
      maxHeight: MediaQuery.of(context).size.height / 2,
      panel: Column(
        children: [
          Container(
            constraints: BoxConstraints.tight(Size(
              MediaQuery.of(context).size.width,
              70,
            )),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Row(
                  children: [
                    SizedBox(width: 10),
                    OutlineButton.icon(
                      icon: PlatformWidget(
                        material: (_, __) => Icon(Icons.file_download),
                        cupertino: (_, __) =>
                            Icon(CupertinoIcons.square_arrow_down),
                      ),
                      label:
                          PlatformText(AppLocalizations.of(context).download),
                      onPressed: () {
                        downloadVideoLink(data);
                      },
                      shape: StadiumBorder(),
                    ),
                    SizedBox(width: 10),
                    OutlineButton.icon(
                      icon: Icon(PlatformIcons(context).share),
                      label: PlatformText(AppLocalizations.of(context).share),
                      onPressed: () {
                        shareVideoLink(data);
                      },
                      shape: StadiumBorder(),
                    ),
                    SizedBox(width: 10),
                    OutlineButton.icon(
                      icon: Icon(PlatformIcons(context).info),
                      label:
                          PlatformText(AppLocalizations.of(context).videoInfo),
                      onPressed: () {
                        if (sheetController.isPanelClosed) {
                          sheetController.open();
                        } else {
                          sheetController.close();
                        }
                      },
                      shape: StadiumBorder(),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
          Card(
            elevation: 2,
            color: Theme.of(context).backgroundColor,
            child: ListTile(
              leading: CircleAvatar(
                child:
                    Icon(isDiscordMode ? VebIcons.discord : VebIcons.twitter),
              ),
              title: PlatformText(username),
              subtitle: PlatformText(isDiscordMode ? 'Discord' : 'Twitter'),
            ),
          ),
          FutureBuilder(
            future: _videoInfoWait,
            builder: (context, AsyncSnapshot<VebResponse> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: PlatformText(
                          AppLocalizations.of(context).videoUnknownErrorTitle),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: LinearProgressIndicator(),
                  ),
                );
              }

              double createdAt = snapshot.data.asJson['timeCreated'];
              final passed = DateTime.now().difference(
                  DateTime.fromMillisecondsSinceEpoch(createdAt.truncate()));
              final days = 30 - passed.inDays;

              String del;

              if (days == 0) {
                del = AppLocalizations.of(context).willBeDeletedSoon;
              } else if (days > 0) {
                del = AppLocalizations.of(context).willBeDeletedIn(
                  AppLocalizations.of(context).days(
                    days,
                  ),
                );
              } else {
                del = AppLocalizations.of(context).notDeletedDaysAgo(
                  AppLocalizations.of(context).days(
                    -days,
                  ),
                );
              }

              return Column(
                children: [
                  Card(
                    elevation: 2,
                    color: Theme.of(context).backgroundColor,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.timelapse),
                      ),
                      title: PlatformText(
                        del,
                      ),
                      subtitle: PlatformText(AppLocalizations.of(context)
                          .willBeDeletedInExplainer),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText(AppLocalizations.of(context).videoTitle),
      ),
      body: sheet,
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen(
      this.data, this.username, this.isDiscordMode, this.sheetController,
      {Key key, this.thumb, this.backToOut, this.type = 'video'})
      : super(key: key);
  final Map<String, dynamic> data;
  final Image thumb;
  final String username, type;
  final bool isDiscordMode, backToOut;
  final PanelController sheetController;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState(
      data, thumb, username, isDiscordMode, sheetController, type);
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  _VideoPlayerScreenState(this.data, this.thumb, this.username,
      this.isDiscordMode, this.sheetController, this.type);
  final Map<String, dynamic> data;
  final Image thumb;
  final String username, type;
  final bool isDiscordMode;
  final PanelController sheetController;

  FlickManager flickManager;
  VideoPlayerController controller;
  Future<void> initVideo;
  bool _isPlaying = false;

  void _videoPlayingListener() {
    if (_isPlaying != flickManager.flickVideoManager.isPlaying) {
      _isPlaying = flickManager.flickVideoManager.isPlaying;
      if (!_isPlaying) {
        sheetController.show();
      } else {
        sheetController.hide();
      }
    }
  }

  @override
  void initState() {
    if (type == 'video') {
      controller = VideoPlayerController.network(
        data['url'],
      );

      flickManager = FlickManager(
        videoPlayerController: controller,
        autoInitialize: false,
        autoPlay: false,
      );

      flickManager.flickVideoManager.addListener(_videoPlayingListener);

      initVideo = controller.initialize();
    }

    super.initState();
  }

  @override
  void dispose() {
    flickManager?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget media = Container();

    if (type == 'video') {
      media = FlickVideoPlayer(
        flickManager: flickManager,
        flickVideoWithControls: FlickVideoWithControls(
          controls: FlickPortraitControls(),
        ),
        flickVideoWithControlsFullscreen: FlickVideoWithControls(
          controls: FlickLandscapeControls(),
        ),
      );
    } else if (type == 'image') {
      media = Image.network(data['url']);
    }
    return FutureBuilder(
      future: (type == 'video' ? initVideo : Future.value()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return media;
        } else {
          return Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image(
                  image: thumb.image,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  errorBuilder: (context, object, stack) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 240,
                      ),
                    );
                  },
                ),
                CircularProgressIndicator(),
              ],
            ),
          );
        }
      },
    );
  }
}
