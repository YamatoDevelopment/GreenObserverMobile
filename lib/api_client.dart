import 'package:dio/dio.dart';

class ApiClient {
  Dio init() {
    Dio _dio = Dio();
    _dio.options.baseUrl = 'http://35.21.205.135:8000';
    return _dio;
  }
}
