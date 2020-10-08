import 'package:videoeditbot_app/services/functions/download.dart';

void downloadVideoLink(Map<String, dynamic> data) {
  Download.startDownload(
    Uri.parse(data['url']),
    fileName: Uri.parse(data['url']).pathSegments.last,
  );
}
