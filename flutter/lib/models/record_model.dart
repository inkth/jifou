import 'package:isar/isar.dart';

part 'record_model.g.dart';

@collection
class RecordModel {
  Id? isarId; // Isar 内部 ID

  @Index(unique: true, replace: true)
  final String id;
  
  final String content;
  final String recordType;
  final DateTime createdAt;
  final double emotionScore;
  final List<String> categories;

  // 同步相关字段
  bool isSynced;
  String? userId;
  DateTime? localCreatedAt;

  RecordModel({
    required this.id,
    required this.content,
    required this.recordType,
    required this.createdAt,
    required this.emotionScore,
    required this.categories,
    this.isarId,
    this.isSynced = false,
    this.userId,
    this.localCreatedAt,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      id: json['id'],
      content: json['content'],
      recordType: json['record_type'],
      createdAt: DateTime.parse(json['created_at']),
      emotionScore: (json['emotion_score'] as num).toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      isSynced: json['is_synced'] ?? true, // 从云端获取的默认已同步
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'record_type': recordType,
      'created_at': createdAt.toIso8601String(),
      'emotion_score': emotionScore,
      'categories': categories,
    };
  }

  RecordModel copyWith({
    String? id,
    String? content,
    String? recordType,
    DateTime? createdAt,
    double? emotionScore,
    List<String>? categories,
    bool? isSynced,
    String? userId,
    DateTime? localCreatedAt,
  }) {
    return RecordModel(
      id: id ?? this.id,
      content: content ?? this.content,
      recordType: recordType ?? this.recordType,
      createdAt: createdAt ?? this.createdAt,
      emotionScore: emotionScore ?? this.emotionScore,
      categories: categories ?? this.categories,
      isarId: isarId,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    );
  }
}
