import 'dart:async';
import 'dart:convert';
import 'dart:io';

class VebRequest {
  VebRequest(this.method, this.data, {this.httpMethod = 'GET'})
      : completer = Completer();

  final Completer<VebResponse> completer;
  final String method, httpMethod;
  final Map<String, dynamic> data;
}

class VebResponse {
  VebResponse(this.response, this.body);

  final HttpClientResponse response;
  final String body;
  dynamic get asJson => jsonDecode(body);
}
