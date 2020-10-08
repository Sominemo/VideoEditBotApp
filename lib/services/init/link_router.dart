import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:videoeditbot_app/app/video_list.dart';
import 'package:videoeditbot_app/main.dart';
import 'package:videoeditbot_app/services/functions/get_video.dart';
import 'package:videoeditbot_app/video.dart';

class InitLinkRouter extends StatelessWidget {
  InitLinkRouter(this.link);
  final Uri link;

  @override
  Widget build(BuildContext context) {
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
              return PlatformScaffold(
                body: Center(
                  child: PlatformCircularProgressIndicator(),
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
                return PlatformScaffold(
                  body: Center(
                    child: PlatformCircularProgressIndicator(),
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
            defaultTab: 0,
          );
        } else if (link.fragment == 'statistics') {
          return VebHomescreen(
            defaultTab: 2,
          );
        }
      }
    }

    return VebHomescreen();
  }
}
