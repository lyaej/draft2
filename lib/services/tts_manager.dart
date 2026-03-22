import 'package:flutter_tts/flutter_tts.dart';

class TtsManager {
  final FlutterTts _tts = FlutterTts();

  TtsManager() {
    _init(); // ignore: discarded_futures
  }

  Future<void> _init() async {
    try {
      await _tts.setLanguage('fil-PH');
    } catch (_) {
      try {
        await _tts.setLanguage('tl-PH');
      } catch (_) {}
    }
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (text == 'Waiting for text...' || text == 'Nagsasalin...') return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> shutdown() async {
    await _tts.stop();
  }
}