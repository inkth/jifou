import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/record_model.dart';
import '../../services/api_service.dart';

final recordsProvider = StateNotifierProvider<RecordsNotifier, AsyncValue<List<RecordModel>>>((ref) {
  return RecordsNotifier();
});

class RecordsNotifier extends StateNotifier<AsyncValue<List<RecordModel>>> {
  RecordsNotifier() : super(const AsyncValue.loading()) {
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    state = const AsyncValue.loading();
    try {
      final records = await apiService.getRecentRecords();
      state = AsyncValue.data(records);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addRecord(String content, String type) async {
    try {
      final newRecord = await apiService.createRecord(content, type: type);
      state.whenData((records) {
        state = AsyncValue.data([newRecord, ...records]);
      });
    } catch (e) {
      // 可以在这里处理错误，比如显示 SnackBar
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await apiService.deleteRecord(id);
      state.whenData((records) {
        state = AsyncValue.data(records.where((r) => r.id != id).toList());
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRecord(String id, String content, {String? type}) async {
    try {
      final updatedRecord = await apiService.updateRecord(id, content, type: type);
      state.whenData((records) {
        final index = records.indexWhere((r) => r.id == id);
        if (index != -1) {
          final newRecords = List<RecordModel>.from(records);
          newRecords[index] = updatedRecord;
          state = AsyncValue.data(newRecords);
        }
      });
    } catch (e) {
      rethrow;
    }
  }
}
