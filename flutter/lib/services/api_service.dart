import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/record_model.dart';
import 'dio_client.dart';

class ApiService {
  final Dio _dio = DioClient.instance;
  String get baseUrl => _dio.options.baseUrl;

  Future<RecordModel> createRecord(String content, {String type = 'text'}) async {
    try {
      final response = await _dio.post('/records/', data: {
        'content': content,
        'record_type': type,
      });
      return RecordModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RecordModel>> getRecentRecords() async {
    try {
      final response = await _dio.get('/records/');
      return (response.data as List)
          .map((json) => RecordModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _dio.get('/reports/daily/$dateStr');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _dio.delete('/records/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<RecordModel> updateRecord(String id, String content, {String? type}) async {
    try {
      final response = await _dio.put('/records/$id', data: {
        'content': content,
        if (type != null) 'record_type': type,
      });
      return RecordModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _dio.post('/send-otp', data: {'phone_number': phoneNumber});
    } catch (e) {
      rethrow;
    }
  }

  Future<String> login(String phoneNumber, String code) async {
    try {
      final response = await _dio.post('/login', data: {
        'phone_number': phoneNumber,
        'code': code,
      });
      return response.data['access_token'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final apiService = ApiService();
