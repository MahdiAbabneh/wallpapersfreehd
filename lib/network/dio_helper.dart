import 'package:dio/dio.dart';

class DioHelper {
  static Dio dio=Dio();

  static init()
  {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.pexels.com/v1/',
        receiveDataWhenStatusError: true,

      ),
    );
  }

  static Future<Response> getData({
    required String url,
  }) async
  {
    dio.options.headers =
    {
      'Authorization':'3TDCtNcGheyNuWloH8Dd7cda0G9l0WqR4BYJfYYD8X0FgQkwaO3DlxXA',
    };

    return await dio.get(
      url,
    );
  }

}