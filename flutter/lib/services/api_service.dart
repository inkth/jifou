import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/record_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000', // MVP 联调地址
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

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
}

final apiService = ApiService();
