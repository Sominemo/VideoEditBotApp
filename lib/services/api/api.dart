import 'dart:async';
import 'dart:io';
import 'package:videoeditbot_app/services/api/utils.dart';

import 'types.dart';

class VebApi {
  VebApi({
    HttpClient client,
    this.domain,
    this.onError,
    this.version,
  }) : client = client ?? HttpClient();

  final String domain;
  final HttpClient client;
  final void Function(dynamic thrown) onError;
  final String version;

  final List<_QueueElement> _queue =
      List.generate(3, (_) => _QueueElement(DateTime(1970)), growable: false);

  final List<VebRequest> _cart = [];

  Future<VebResponse> call(String method, Map<String, dynamic> data,
      {String httpMethod = 'GET'}) {
    final request = VebRequest(
      method,
      data,
      httpMethod: httpMethod,
    );
    _cart.add(request);
    _runner();
    return request.completer.future;
  }

  bool _isRunnerBusy = false;

  void _runner({bool isRecursive = false}) async {
    if (_isRunnerBusy && !isRecursive) return;

    _isRunnerBusy = true;

    while (_cart.isNotEmpty) {
      try {
        if (!_queue.any(
          (element) =>
              DateTime.now().difference(element.time) > Duration(seconds: 1) &&
              !element.isBusy,
        )) {
          final delays = _queue
              .map((element) => DateTime.now()
                  .difference(element.isBusy ? DateTime.now() : element.time))
              .toList();
          final max = delays
              .reduce((value, element) => value > element ? value : element);
          Timer(Duration(seconds: 1) - max, () {
            _runner(isRecursive: true);
          });
          return;
        }

        final r = _cart.removeAt(0);

        final delays = _queue
            .map((element) => DateTime.now()
                .difference(element.isBusy ? DateTime.now() : element.time))
            .toList();

        final max = delays
            .reduce((value, element) => value > element ? value : element);

        final qIndex = delays.indexOf(max);
        _queue[qIndex].isBusy = true;

        _executeRequest(r, qIndex);
      } catch (e) {
        onError(e);
      }
    }

    _isRunnerBusy = false;
  }

  void _executeRequest(VebRequest r, int qIndex) async {
    try {
      var uri = Uri.parse(domain).replace(pathSegments: [
        ...Uri.parse(domain).pathSegments,
        version,
        r.method,
      ]);
      if (r.httpMethod == 'GET' && r.data.isNotEmpty) {
        uri = uri.replace(queryParameters: r.data);
      }

      final response = await VebUtils.request(
        client,
        uri,
        bodyFields: r.data,
        method: r.httpMethod,
        onConnectionEstablished: () {
          _queue[qIndex] = _QueueElement(DateTime.now());
        },
      );

      final result =
          VebResponse(response, await VebUtils.responseToString(response));

      try {
        final json = result.asJson;

        if (json is Map<String, dynamic> && json.containsKey('error')) {
          r.completer.completeError(json);
        } else {
          r.completer.complete(result);
        }
      } catch (e) {
        r.completer.completeError(result);
      }
    } catch (e) {
      _queue[qIndex] = _QueueElement(DateTime.now());
      r.completer.completeError(e);
      rethrow;
    }
  }
}

class _QueueElement {
  _QueueElement(this.time, {this.isBusy = false});
  final DateTime time;
  bool isBusy;
}
