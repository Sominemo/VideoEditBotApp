import 'package:videoeditbot_app/services/api/global_queue.dart';
import 'package:videoeditbot_app/services/api/types.dart';

Future<VebResponse> getVideo(
    bool isDiscordMode, String username, Map<String, dynamic> data) {
  return Queue.api.call('video.json', {
    ...(isDiscordMode ? {'guild': username} : {'username': username}),
    'video': data['id'].toString(),
  });
}
