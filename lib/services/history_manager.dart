import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

/// Converted from HistoryManager.kt (Kotlin object → Dart singleton)
/// Uses SharedPreferences instead of Android SharedPreferences
class HistoryManager {
  HistoryManager._();
  static final HistoryManager instance = HistoryManager._();

  static const String _prefKey = 'history_list';
  static const int _maxItems = 50;

  // ── Save a new translation to history ────────────────────────────────────
  Future<void> save(TranslationResult result, String sourceType) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();

    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalText: result.originalText,
      tagalogText: result.tagalog,
      detectedLanguage: result.detectedLanguage,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sourceType: sourceType,
    );

    existing.insert(0, item); // newest first
    final capped = existing.take(_maxItems).toList();

    final jsonList = capped.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefKey, jsonList);
  }

  // ── Get all history items ─────────────────────────────────────────────────
  Future<List<HistoryItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefKey) ?? [];
    try {
      return jsonList
          .map((e) => HistoryItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Clear all history ─────────────────────────────────────────────────────
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
