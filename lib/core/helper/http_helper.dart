// dart http helper class

import 'dart:io';

import 'package:dio/dio.dart';

class HttpHelper {
  static Future<String> get(String url) async {
    String responseJson;
    try {
      final response = await Dio().get(url,
          options: Options(
            headers: {
              "Access-Control-Allow-Origin": "*",
            },
          ));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
    return responseJson;
  }

  static dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = (response.data.toString());
        return responseJson;
      case 400:
        throw Exception(response.data.toString());
      case 401:
      case 403:
        throw Exception(response.data.toString());
      case 500:
      default:
        throw Exception(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
