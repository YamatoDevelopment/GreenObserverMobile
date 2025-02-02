import 'package:dio/dio.dart';

class ApiClient {
  Dio init() {
    Dio dio = Dio();
    dio.options.baseUrl = 'http://35.21.205.135:8000';
    return dio;
  }
}
