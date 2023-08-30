import 'package:dio/dio.dart';

enum Method { get, post, put, delete }

class HttpRequest {
  static HttpRequest? _instance;
  late Dio dio;

  factory HttpRequest() {
    _instance ??= HttpRequest._();
    return _instance!;
  }

  HttpRequest._() {
    dio = Dio();
    // dio.interceptors.add(LogInterceptor(request: true, responseBody: true));
  }

  get({required String url, Map<String, dynamic>? params}) {
    return _request(url: url, params: params, method: Method.get);
  }

  post(String url, Map<String, dynamic>? params) {
    return _request(url: url, params: params, method: Method.post);
  }

  put(String url, Map<String, dynamic>? params) {
    return _request(url: url, params: params, method: Method.put);
  }

  delete(String url, Map<String, dynamic>? params) {
    return _request(url: url, params: params, method: Method.delete);
  }

  _request(
      {required String url,
      Map<String, dynamic>? params,
      required Method method}) async {
    try {
      Response response;
      switch (method) {
        case Method.get:
          if (params != null && params.isNotEmpty) {
            response = await dio.get(url, queryParameters: params);
          } else {
            response = await dio.get(url);
          }
          break;
        case Method.post:
          if (params != null && params.isNotEmpty) {
            response = await dio.post(url, queryParameters: params);
          } else {
            response = await dio.post(url);
          }
          break;
        case Method.put:
          if (params != null && params.isNotEmpty) {
            response = await dio.put(url, queryParameters: params);
          } else {
            response = await dio.put(url);
          }
          break;
        case Method.delete:
          if (params != null && params.isNotEmpty) {
            response = await dio.delete(url, queryParameters: params);
          } else {
            response = await dio.delete(url);
          }
          break;
        default:
          response = await dio.get(url, queryParameters: params);
      }
      return response.data;
    } catch (e) {
      print('错误：${e.toString()}');
    }
  }
}
