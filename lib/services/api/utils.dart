import 'dart:async';
import 'dart:io';
import 'dart:convert' show jsonDecode, utf8;

class VebUtils {
  static Future<HttpClientResponse> request(
    HttpClient client,
    Uri url, {
    String method = 'POST',
    String body,
    Map<String, dynamic> bodyFields,
    Map<String, String> headers,
    void Function() onConnectionEstablished,
  }) async {
    var request = await client.openUrl(
      method,
      url,
    );

    if (headers != null) {
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });
    }

    if (bodyFields != null) {
      request.headers.add('Content-Type', 'application/x-www-form-urlencoded');

      final queryBody = <String>[];
      bodyFields.forEach((key, value) {
        queryBody.add(
          Uri.encodeQueryComponent(key) +
              '=' +
              Uri.encodeQueryComponent(value.toString()),
        );
      });

      body = queryBody.join('&');
    }

    if (body != null) {
      final encodedBody = utf8.encode(body);
      request.headers.set('Content-Length', encodedBody.length.toString());
      if (body != null) request.write(body);
    }

    if (onConnectionEstablished != null) Timer.run(onConnectionEstablished);

    var response = await request.close();

    return response;
  }

  static Future<String> responseToString(HttpClientResponse response) async {
    final responseData = <int>[];
    await for (var i in response) {
      responseData.addAll(i);
    }

    return utf8.decode(responseData);
  }

  dynamic parseJson(s) => jsonDecode(s);
}
