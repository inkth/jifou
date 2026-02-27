import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL', fallback: 'http://localhost:8000'),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          // 统一错误处理逻辑
          String errorMessage = '网络请求失败';
          if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = '连接超时';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = '服务器响应超时';
          } else if (e.response?.statusCode == 401) {
            errorMessage = '未授权，请重新登录';
          } else if (e.response?.statusCode == 500) {
            errorMessage = '服务器内部错误';
          }
          
          // 这里可以抛出一个自定义异常或者通过某种方式通知 UI
          return handler.next(e);
        },
      ));
    }
    return _dio!;
  }
}
