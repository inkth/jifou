import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/record_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import 'auth_provider.dart';

final recordsProvider = StateNotifierProvider<RecordsNotifier, AsyncValue<List<RecordModel>>>((ref) {
  return RecordsNotifier(ref);
});

class RecordsNotifier extends StateNotifier<AsyncValue<List<RecordModel>>> {
  final Ref _ref;
  final _uuid = const Uuid();

  RecordsNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchRecords();
    
    // 监听登录状态变化，登录后自动同步
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        fetchRecords();
      }
    });
  }

  Future<void> fetchRecords() async {
    final authState = _ref.read(authProvider);
    final userId = authState.isAuthenticated && authState.user != null
        ? authState.user!['id'] as String?
        : null;

    // 1. 先从本地加载
    final localRecords = await LocalDbService.getRecords(userId: userId);
    state = AsyncValue.data(localRecords);

    // 2. 如果已登录，尝试同步
    if (authState.isAuthenticated) {
      try {
        await syncUnsyncedRecords();
        final cloudRecords = await apiService.getRecentRecords();
        
        // 更新本地缓存
        final syncedRecords = cloudRecords.map((r) => r.copyWith(isSynced: true, userId: userId)).toList();
        await LocalDbService.saveRecords(syncedRecords);
        
        // 重新加载
        final updatedRecords = await LocalDbService.getRecords(userId: userId);
        state = AsyncValue.data(updatedRecords);
      } catch (e) {
        // 网络错误不影响本地显示
      }
    }
  }

  Future<void> syncUnsyncedRecords() async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) return;
    
    final userId = authState.user?['id'];
    final unsynced = await LocalDbService.getUnsyncedRecords();
    
    for (final record in unsynced) {
      try {
        final syncedRecord = await apiService.createRecord(record.content, type: record.recordType);
        await LocalDbService.deleteRecord(record.id);
        await LocalDbService.saveRecord(syncedRecord.copyWith(isSynced: true, userId: userId));
      } catch (e) {
        // 忽略单个同步失败
      }
    }
  }

  Future<void> addRecord(String content, String type) async {
    final authState = _ref.read(authProvider);
    final userId = authState.isAuthenticated && authState.user != null
        ? authState.user!['id'] as String?
        : null;
    
    final newRecord = RecordModel(
      id: _uuid.v4(),
      content: content,
      recordType: type,
      createdAt: DateTime.now(),
      emotionScore: 0,
      categories: [],
      isSynced: false,
      userId: userId,
      localCreatedAt: DateTime.now(),
    );

    // 1. 保存到本地并更新 UI
    await LocalDbService.saveRecord(newRecord);
    state.whenData((records) {
      state = AsyncValue.data([newRecord, ...records]);
    });

    // 2. 尝试同步
    if (authState.isAuthenticated) {
      try {
        final syncedRecord = await apiService.createRecord(content, type: type);
        await LocalDbService.deleteRecord(newRecord.id);
        final finalRecord = syncedRecord.copyWith(isSynced: true, userId: userId);
        await LocalDbService.saveRecord(finalRecord);
        
        state.whenData((records) {
          final updatedRecords = records.map((r) => r.id == newRecord.id ? finalRecord : r).toList();
          state = AsyncValue.data(updatedRecords);
        });
      } catch (e) {
        // 同步失败，保持本地
      }
    }
  }

  Future<void> deleteRecord(String id) async {
    final authState = _ref.read(authProvider);
    
    // 1. 本地删除
    await LocalDbService.deleteRecord(id);
    state.whenData((records) {
      state = AsyncValue.data(records.where((r) => r.id != id).toList());
    });

    // 2. 尝试云端删除
    if (authState.isAuthenticated) {
      try {
        await apiService.deleteRecord(id);
      } catch (e) {
        // 忽略云端删除失败
      }
    }
  }

  Future<void> updateRecord(String id, String content, {String? type}) async {
    final authState = _ref.read(authProvider);
    final userId = authState.isAuthenticated && authState.user != null
        ? authState.user!['id'] as String?
        : null;

    state.whenData((records) async {
      final index = records.indexWhere((r) => r.id == id);
      if (index != -1) {
        final oldRecord = records[index];
        final updatedRecord = oldRecord.copyWith(
          content: content,
          recordType: type ?? oldRecord.recordType,
          isSynced: false,
        );

        // 1. 本地更新
        await LocalDbService.saveRecord(updatedRecord);
        final newRecords = List<RecordModel>.from(records);
        newRecords[index] = updatedRecord;
        state = AsyncValue.data(newRecords);

        // 2. 尝试云端更新
        if (authState.isAuthenticated) {
          try {
            final syncedRecord = await apiService.updateRecord(id, content, type: type);
            final finalRecord = syncedRecord.copyWith(isSynced: true, userId: userId);
            await LocalDbService.saveRecord(finalRecord);
            
            state.whenData((records) {
              final updatedList = records.map((r) => r.id == id ? finalRecord : r).toList();
              state = AsyncValue.data(updatedList);
            });
          } catch (e) {
            // 同步失败
          }
        }
      }
    });
  }
}
