class RecordModel {
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
      'content': content,
      'record_type': recordType,
    };
  }
}
