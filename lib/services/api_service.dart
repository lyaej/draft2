import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../models/history_item.dart';

class ApiService {

  // ✅ Singleton — isang instance sa buong app, persistent ang cache
  static final ApiService instance = ApiService._internal();
  ApiService._internal();
  factory ApiService() => instance;

  static const Map<String, String> _langNames = {
    'en': 'Ingles',      'zh': 'Tsino',       'ja': 'Hapon',
    'ko': 'Koreano',     'es': 'Espanyol',    'fr': 'Pranses',
    'de': 'Aleman',      'it': 'Italyano',    'pt': 'Portuges',
    'ar': 'Arabik',      'ru': 'Ruso',        'hi': 'Hindi',
    'tl': 'Filipino',    'id': 'Indonesyano', 'th': 'Thai',
    'vi': 'Biyetnamese', 'ms': 'Malay',       'nl': 'Olandes',
    'sv': 'Suweko',      'pl': 'Polako',      'tr': 'Turko',
    'uk': 'Ukraniyano',  'ro': 'Rumano',      'cs': 'Tseko',
    'af': 'Afrikaans',   'bn': 'Bengali',     'el': 'Griyego',
    'sw': 'Swahili',     'ta': 'Tamil',       'te': 'Telugu',
  };

  final Map<String, OnDeviceTranslator> _translatorCache = {};
  final Set<String> _downloadedModels = {};

  // ✅ Pre-warm: i-load ng parallel ang mga common na wika
  Future<void> preWarm() async {
    await Future.wait([
      _ensureModelReady('en'),
      _ensureModelReady('ja'),
      _ensureModelReady('ko'),
    ], eagerError: false);
  }

  Future<void> _ensureModelReady(String langCode) async {
    try { await _getOrCreateTranslator(langCode); } catch (_) {}
  }

  Future<OnDeviceTranslator> _getOrCreateTranslator(String langCode) async {
    if (_translatorCache.containsKey(langCode)) {
      return _translatorCache[langCode]!;
    }
    final sourceLang = _toMlKitLang(langCode);
    const targetLang = TranslateLanguage.tagalog;
    final modelManager = OnDeviceTranslatorModelManager();
    if (!_downloadedModels.contains(langCode)) {
      final results = await Future.wait([
        modelManager.isModelDownloaded(sourceLang.bcpCode),
        modelManager.isModelDownloaded(targetLang.bcpCode),
      ]);
      if (!results[0]) await modelManager.downloadModel(sourceLang.bcpCode);
      if (!results[1]) await modelManager.downloadModel(targetLang.bcpCode);
      _downloadedModels.add(langCode);
    }
    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );
    _translatorCache[langCode] = translator;
    return translator;
  }

  // ✅ PARA SA SCAN — walang language detection, default English
  // Isang step lang (translate) kaya mas mabilis
  Future<TranslationResult> translateTextFast(String text) async {
    try {
      final translator = await _getOrCreateTranslator('en');
      final translated = await translator.translateText(text);
      return TranslationResult(
        detectedLanguage: 'Ingles',
        originalText: text,
        tagalog: translated,
      );
    } catch (_) {
      throw Exception('Hindi ma-translate.');
    }
  }

  // Para sa Text Translate + Voice — may language detection
  Future<TranslationResult> translateText(String text) async {
    final detectedCode = await _detectLanguage(text);
    final langName = _langNames[detectedCode] ?? detectedCode.toUpperCase();
    if (detectedCode == 'tl') {
      return TranslationResult(detectedLanguage: 'Filipino', originalText: text, tagalog: text);
    }
    final translator = await _getOrCreateTranslator(detectedCode);
    final translated = await translator.translateText(text);
    return TranslationResult(detectedLanguage: langName, originalText: text, tagalog: translated);
  }

  Future<TranslationResult> translateImage(InputImage inputImage) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(inputImage);
      final text = result.text.trim();
      if (text.isEmpty) {
        return const TranslationResult(
          detectedLanguage: '—',
          originalText: 'Walang text na natagpuan sa larawan.',
          tagalog: 'Walang text na natagpuan sa larawan.',
        );
      }
      return translateText(text);
    } finally {
      recognizer.close();
    }
  }

  Future<String> _detectLanguage(String text) async {
    final identifier = LanguageIdentifier(confidenceThreshold: 0.5);
    try {
      final result = await identifier.identifyLanguage(text);
      return (result == 'und') ? 'en' : result;
    } catch (_) {
      return 'en';
    } finally {
      identifier.close();
    }
  }

  TranslateLanguage _toMlKitLang(String bcp47) {
    switch (bcp47) {
      case 'zh': case 'zh-CN': case 'zh-Hans':
      case 'zh-TW': case 'zh-Hant': return TranslateLanguage.chinese;
      case 'en':  return TranslateLanguage.english;
      case 'ja':  return TranslateLanguage.japanese;
      case 'ko':  return TranslateLanguage.korean;
      case 'es':  return TranslateLanguage.spanish;
      case 'fr':  return TranslateLanguage.french;
      case 'de':  return TranslateLanguage.german;
      case 'it':  return TranslateLanguage.italian;
      case 'pt':  return TranslateLanguage.portuguese;
      case 'ar':  return TranslateLanguage.arabic;
      case 'ru':  return TranslateLanguage.russian;
      case 'hi':  return TranslateLanguage.hindi;
      case 'id':  return TranslateLanguage.indonesian;
      case 'th':  return TranslateLanguage.thai;
      case 'vi':  return TranslateLanguage.vietnamese;
      case 'ms':  return TranslateLanguage.malay;
      case 'nl':  return TranslateLanguage.dutch;
      case 'sv':  return TranslateLanguage.swedish;
      case 'pl':  return TranslateLanguage.polish;
      case 'tr':  return TranslateLanguage.turkish;
      case 'uk':  return TranslateLanguage.ukrainian;
      case 'ro':  return TranslateLanguage.romanian;
      case 'cs':  return TranslateLanguage.czech;
      case 'da':  return TranslateLanguage.danish;
      case 'fi':  return TranslateLanguage.finnish;
      case 'af':  return TranslateLanguage.afrikaans;
      case 'bn':  return TranslateLanguage.bengali;
      case 'el':  return TranslateLanguage.greek;
      case 'sw':  return TranslateLanguage.swahili;
      case 'ta':  return TranslateLanguage.tamil;
      case 'te':  return TranslateLanguage.telugu;
      default:    return TranslateLanguage.english;
    }
  }
}