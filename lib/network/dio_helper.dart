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
      'Authorization':'563492ad6f9170000100000174dda4707e934bc58524e21b8e440b15',
    };

    return await dio.get(
      url,
    );
  }

}