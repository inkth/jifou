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

  static Future<List<RecordModel>> getRecords() async {
    final isar = await instance;
    return await isar.recordModels.where().sortByCreatedAtDesc().findAll();
  }

  static Future<void> clearAll() async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.recordModels.clear();
    });
  }
}
