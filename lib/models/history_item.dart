import 'package:intl/intl.dart';

/// Converted from HistoryItem data class in HistoryManager.kt
class HistoryItem {
  final String id;
  final String originalText;
  final String tagalogText;
  final String detectedLanguage;
  final int timestamp;
  final String sourceType; // "text", "image", "camera", "voice"

  const HistoryItem({
    required this.id,
    required this.originalText,
    required this.tagalogText,
    required this.detectedLanguage,
    required this.timestamp,
    required this.sourceType,
  });

  /// Equivalent of formattedDate() in Kotlin
  String formattedDate() {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatter = DateFormat('MMM d, yyyy · h:mm a');
    return formatter.format(date);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalText': originalText,
    'tagalogText': tagalogText,
    'detectedLanguage': detectedLanguage,
    'timestamp': timestamp,
    'sourceType': sourceType,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    id: json['id'] as String,
    originalText: json['originalText'] as String,
    tagalogText: json['tagalogText'] as String,
    detectedLanguage: json['detectedLanguage'] as String,
    timestamp: json['timestamp'] as int,
    sourceType: (json['sourceType'] as String?) ?? 'text',
  );
}

/// Converted from TranslationResult data class in Api.kt
class TranslationResult {
  final String detectedLanguage;
  final String originalText;
  final String tagalog;

  const TranslationResult({
    required this.detectedLanguage,
    required this.originalText,
    required this.tagalog,
  });
}
