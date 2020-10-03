import 'package:share/share.dart';

void shareVideoLink(Map<String, dynamic> data) {
  Share.share(Uri.parse(data['url'])
      .replace(host: 'videoedit.bot', query: 'video')
      .toString());
}
