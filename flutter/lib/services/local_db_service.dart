import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/record_model.dart';

class LocalDbService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar == null) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [RecordModelSchema],
        directory: dir.path,
      );
    }
    return _isar!;
  }

  static Future<void> saveRecords(List<RecordModel> records) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.recordModels.putAll(records);
    });
  }

  static Future<void> saveRecord(RecordModel record) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.recordModels.put(record);
    });
  }

  static Future<List<RecordModel>> getRecords({String? userId}) async {
    final isar = await instance;
    if (userId == null) {
      return await isar.recordModels.filter().userIdIsNull().sortByCreatedAtDesc().findAll();
    } else {
      return await isar.recordModels.filter().userIdEqualTo(userId).sortByCreatedAtDesc().findAll();
    }
  }

  static Future<List<RecordModel>> getUnsyncedRecords() async {
    final isar = await instance;
    return await isar.recordModels.filter().isSyncedEqualTo(false).findAll();
  }

  static Future<void> updateSyncStatus(List<String> ids, bool synced, {String? userId}) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      for (final id in ids) {
        final record = await isar.recordModels.filter().idEqualTo(id).findFirst();
        if (record != null) {
          // Use copyWith to update fields while keeping isarId
          final updated = record.copyWith(isSynced: synced, userId: userId);
          updated.isarId = record.isarId;
          await isar.recordModels.put(updated);
        }
      }
    });
  }

  static Future<void> deleteRecord(String id) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.recordModels.filter().idEqualTo(id).deleteAll();
    });
  }

  static Future<void> clearAll() async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.recordModels.clear();
    });
  }
}
