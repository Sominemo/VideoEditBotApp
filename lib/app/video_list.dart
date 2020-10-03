import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:videoeditbot_app/services/api/global_queue.dart';
import 'package:videoeditbot_app/services/api/types.dart';
import 'package:videoeditbot_app/services/functions/downloadVideo.dart';
import 'package:videoeditbot_app/services/functions/share.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:videoeditbot_app/video.dart';
import 'package:videoeditbot_app/widgets/ink_wrapper.dart';

class VideoListView extends StatefulWidget {
  VideoListView(this.username, this.isDiscordMode);
  final String username;
  final bool isDiscordMode;

  @override
  _VideoListViewState createState() =>
      _VideoListViewState(username, isDiscordMode);
}

class _VideoListViewState extends State<VideoListView> {
  _VideoListViewState(this.username, this.isDiscordMode);
  final String username;
  final bool isDiscordMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isDiscordMode
            ? AppLocalizations.of(context).discordMode
            : username + "'s " + AppLocalizations.of(context).yourVideos),
      ),
      body: VideoList(username, isDiscordMode),
    );
  }
}

class VideoList extends StatefulWidget {
  VideoList(this.username, this.isDiscordMode) : super(key: UniqueKey());
  final String username;
  final bool isDiscordMode;

  @override
  _VideoListState createState() => _VideoListState(username, isDiscordMode);
}

class _VideoListState extends State<VideoList> {
  _VideoListState(this.username, this.isDiscordMode);
  final String username;
  final bool isDiscordMode;

  final Map<int, Map<String, dynamic>> videoCache = {};
  int page = 0;
  int pageCount = 0;
  final Map<int, Future<VebResponse>> loadedPages = {};

  Future<VebResponse> _userRequest({
    int page = 0,
  }) async {
    if (loadedPages.containsKey(page)) return loadedPages[page];

    final resFuture = Queue.api.call(
      'user.json',
      {
        ...(isDiscordMode ? {'guild': username} : {'username': username}),
        'page': page.toString()
      },
    );

    loadedPages[page] = resFuture;

    final res = await resFuture;

    List c = res.asJson;
    final content = c.cast<Map<String, dynamic>>();

    final cache = content
        .asMap()
        .map((key, value) => MapEntry(pageCount * page + key, value));

    videoCache.addAll(cache);

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userRequest(),
      builder: (BuildContext context, AsyncSnapshot<VebResponse> snapshot) {
        if (snapshot.hasError) {
          var title = AppLocalizations.of(context).unknownErrorTitle;
          var subtitle = AppLocalizations.of(context).tryAgainLater;
          if (snapshot.error is VebResponse) {
            var error = snapshot.error as VebResponse;
            if (error.response.statusCode == HttpStatus.notFound ||
                error.response.statusCode == 418) {
              if (isDiscordMode) {
                title = AppLocalizations.of(context).discordNotFoundTitle;
                subtitle = AppLocalizations.of(context).discordNotFoundText;
              } else {
                title = AppLocalizations.of(context).notFoundTitle;
                subtitle = AppLocalizations.of(context).notFoundText;
              }
            }
          }

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 30),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          subtitle,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      if (ModalRoute.of(context)?.canPop ?? false)
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context).retry),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var count =
            int.parse(snapshot.data.response.headers.value('X-Video-Count'));

        pageCount =
            int.parse(snapshot.data.response.headers.value('X-Page-Length'));

        final orientation = MediaQuery.of(context).orientation;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
          ),
          itemBuilder: (context, i) {
            if (videoCache.containsKey(i)) {
              return VideoListItem(videoCache[i], username, isDiscordMode);
            }

            return FutureBuilder(
              future: _userRequest(
                page: (i / pageCount).truncate(),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 120,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return VideoListItem(videoCache[i], username, isDiscordMode);
              },
            );
          },
          itemCount: count,
        );
      },
    );
  }
}

class VideoListItem extends StatefulWidget {
  VideoListItem(this.data, this.username, this.isDiscordMode);

  final Map<String, dynamic> data;
  final String username;
  final bool isDiscordMode;

  @override
  _VideoListItemState createState() =>
      _VideoListItemState(data, username, isDiscordMode);
}

class _VideoListItemState extends State<VideoListItem> {
  _VideoListItemState(this.data, this.username, this.isDiscordMode);

  Map<String, dynamic> data;
  final String username;
  final bool isDiscordMode;

  @override
  Widget build(BuildContext context) {
    final thumb = Image.network(
      (data['type'] == 'image' ? data['url'] : data['thumbnailUrl']),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
      loadingBuilder: (context, widget, event) {
        if (event == null) return widget;

        return Center(
          child: CircularProgressIndicator(
            value: event.cumulativeBytesLoaded / event.cumulativeBytesLoaded,
          ),
        );
      },
      errorBuilder: (context, object, stack) => Center(
        child: Icon(
          Icons.broken_image,
          size: 120,
        ),
      ),
    );

    final color = Theme.of(context).bottomAppBarColor;

    return GridTile(
      child: InkWrapper(
        child: thumb,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VideoScreen(data, username, isDiscordMode, thumb: thumb),
            ),
          ).then((value) {
            FlutterStatusbarcolor.setNavigationBarColor(color, animate: true);
          });
        },
        onLongPress: () async {
          await showModalBottomSheet(
              context: context,
              builder: (context) {
                FlutterStatusbarcolor.setNavigationBarColor(
                    Theme.of(context).scaffoldBackgroundColor,
                    animate: false);
                FlutterStatusbarcolor.setStatusBarColor(Colors.transparent,
                    animate: false);
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                          leading: Icon(Icons.file_download),
                          title: Text(AppLocalizations.of(context).download),
                          onTap: () {
                            downloadVideoLink(data);
                          }),
                      ListTile(
                        leading: Icon(Icons.share),
                        title: Text(AppLocalizations.of(context).share),
                        onTap: () {
                          shareVideoLink(data);
                        },
                      ),
                    ],
                  ),
                );
              });

          // ignore: unawaited_futures
          FlutterStatusbarcolor.setNavigationBarColor(
              Theme.of(context).bottomAppBarColor,
              animate: true);
          // ignore: unawaited_futures
          FlutterStatusbarcolor.setStatusBarColor(
              Theme.of(context).primaryColor,
              animate: true);
        },
      ),
    );
  }
}
