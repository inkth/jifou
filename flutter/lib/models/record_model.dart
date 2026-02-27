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

  RecordModel({
    required this.id,
    required this.content,
    required this.recordType,
    required this.createdAt,
    required this.emotionScore,
    required this.categories,
    this.isarId,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      id: json['id'],
      content: json['content'],
      recordType: json['record_type'],
      createdAt: DateTime.parse(json['created_at']),
      emotionScore: (json['emotion_score'] as num).toDouble(),
      categories: List<String>.from(json['categories']),
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
}
