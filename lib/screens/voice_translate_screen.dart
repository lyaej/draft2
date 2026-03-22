import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../app_colors.dart';
import '../services/api_service.dart';
import '../services/history_manager.dart';
import '../services/tts_manager.dart';

/// Converted from VoiceTranslateActivity.kt + activity_voice_translate.xml
class VoiceTranslateScreen extends StatefulWidget {
  const VoiceTranslateScreen({super.key});

  @override
  State<VoiceTranslateScreen> createState() => _VoiceTranslateScreenState();
}

class _VoiceTranslateScreenState extends State<VoiceTranslateScreen> {
  final _api = ApiService();
  final _tts = TtsManager();
  final _speech = SpeechToText();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isLoading = false;

  String? _heardText;
  String? _resultText;
  String? _detectedLang;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _tts.shutdown();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) => setState(() {
        _errorText = 'May error sa speech recognition. Subukan ulit.';
        _isListening = false;
      }),
    );
    setState(() {});
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      setState(() => _errorText = 'Hindi available ang speech recognition.');
      return;
    }

    setState(() {
      _isListening = true;
      _errorText = null;
      _heardText = null;
      _resultText = null;
    });

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final spokenText = result.recognizedWords;
          setState(() => _isListening = false);
          if (spokenText.isNotEmpty) {
            setState(() => _heardText = spokenText);
            _translateSpoken(spokenText);
          } else {
            setState(() => _errorText = 'Hindi marinig ang sinabi. Subukan ulit.');
          }
        }
      },
      localeId: 'und', // auto-detect language
    );
  }

  Future<void> _translateSpoken(String text) async {
    setState(() { _isLoading = true; _errorText = null; });
    try {
      final result = await _api.translateText(text);
      await HistoryManager.instance.save(result, 'voice');
      setState(() {
        _resultText = result.tagalog;
        _detectedLang = 'Wika: ${result.detectedLanguage}';
      });
    } catch (e) {
      setState(() => _errorText = 'May error sa pagsasalin. Suriin ang internet connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copy() {
    if (_resultText == null) return;
    Clipboard.setData(ClipboardData(text: _resultText!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nakopya! ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'VOICE TRANSLATE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // MIC BUTTON
                    GestureDetector(
                      onTap: _toggleListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? Colors.red
                              : AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(4, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 56,
                          color: _isListening ? AppColors.white : AppColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MIC LABEL
                    Text(
                      _isListening
                          ? 'Nakikinig… (pindutin para itigil)'
                          : 'Pindutin para magsalita',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // LISTENING INDICATOR (blinking dot)
                    if (_isListening) ...[
                      const SizedBox(height: 8),
                      const _BlinkingDot(),
                    ],
                    const SizedBox(height: 24),

                    // HEARD TEXT CARD
                    if (_heardText != null)
                      Card(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.cardBorder, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Narinig:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _heardText!,
                                style: const TextStyle(fontSize: 16, color: AppColors.cardBorder),
                              ),
                              if (_detectedLang != null && _isLoading) ...[
                                const SizedBox(height: 4),
                                const Text(
                                  'Isinasalin sa Tagalog…',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // LOADING
                    if (_isLoading)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 12),
                              Text('Isinasalin…'),
                            ],
                          ),
                        ),
                      ),

                    // ERROR
                    if (_errorText != null)
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),

                    // RESULT
                    if (_resultText != null)
                      Card(
                        color: AppColors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.cardBorder, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      '🇵🇭  TAGALOG / FILIPINO',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, color: AppColors.green),
                                    onPressed: () => _tts.speak(_resultText!),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: AppColors.green),
                                    onPressed: _copy,
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text(
                                _resultText!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              if (_detectedLang != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _detectedLang!,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Blinking dot widget (replaces AlphaAnimation from Android)
class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.2, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
