import 'api.dart';

class Queue {
  static VebApi _api;
  static VebApi get api {
    _api ??= VebApi(
      domain: 'https://api.videoedit.bot',
      version: '1',
      onError: (e) {
        throw e;
      }
    );

    return _api;
  }
}
