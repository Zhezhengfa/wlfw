/// HTTP 请求客户端——封装"请求五要素"：方法 / URL / Header / Body / Timeout。
/// 只暴露两个入口：[getList] 和 [post]，页面层 Repository 调用。
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'app_exception.dart';
import 'constants.dart';

class ApiClient {
  const ApiClient(this._client);
  final http.Client _client;

  /// GET 返回列表
  Future<List<T>> getList<T>({
    required String url,
    required T Function(Map<String, dynamic>) fromJson,
    String mockAsset = AppFlags.mockWindowsAsset,
  }) async {
    final jsonString = await _readOrFetch(url, mockAsset: mockAsset);
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<String> _readOrFetch(String url, {required String mockAsset}) async {
    if (AppFlags.useMock) {
      return rootBundle.loadString(mockAsset);
    }
    http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url))
          .timeout(Duration(seconds: AppFlags.timeoutSeconds));
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutExceptionApp();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(response.statusCode);
    }
    return response.body;
  }
}
