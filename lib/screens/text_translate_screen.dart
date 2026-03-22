import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../services/api_service.dart';
import '../services/history_manager.dart';
import '../services/tts_manager.dart';

/// Converted from TextTranslateActivity.kt + activity_text_translate.xml
class TextTranslateScreen extends StatefulWidget {
  const TextTranslateScreen({super.key});

  @override
  State<TextTranslateScreen> createState() => _TextTranslateScreenState();
}

class _TextTranslateScreenState extends State<TextTranslateScreen> {
  final _api = ApiService();
  final _tts = TtsManager();
  final _controller = TextEditingController();

  bool _isLoading = false;
  String? _resultText;
  String? _metaText;
  String? _errorText;

  @override
  void dispose() {
    _tts.shutdown();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    FocusScope.of(context).unfocus();
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pakisulat muna ang text.')),
      );
      return;
    }
    setState(() { _isLoading = true; _errorText = null; _resultText = null; });
    try {
      final result = await _api.translateText(text);
      await HistoryManager.instance.save(result, 'text');
      setState(() {
        _resultText = result.tagalog;
        _metaText = '${result.detectedLanguage}  ·  Original: ${result.originalText.length > 80 ? result.originalText.substring(0, 80) : result.originalText}';
      });
    } catch (e) {
      setState(() { _errorText = 'May error. Suriin ang internet connection.'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _clear() {
    _controller.clear();
    _tts.stop();
    setState(() { _resultText = null; _errorText = null; });
  }

  void _copy() {
    if (_resultText == null) return;
    Clipboard.setData(ClipboardData(text: _resultText!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nakopya!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textTranslateBg,
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
                      'TEXT TRANSLATE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.white),
                    onPressed: _clear,
                  ),
                ],
              ),
            ),

            // ── CONTENT ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // INPUT FIELD
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder, width: 2),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 16, color: AppColors.cardBorder),
                        decoration: const InputDecoration(
                          hintText: 'Isulat ang text dito...',
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TRANSLATE BUTTON
                    GestureDetector(
                      onTap: _translate,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'I-TRANSLATE',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LOADING
                    if (_isLoading)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Isinasalin...'),
                            ],
                          ),
                        ),
                      ),

                    // ERROR
                    if (_errorText != null)
                      Card(
                        color: AppColors.errorBg,
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
                              // Header row
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
                                    icon: const Icon(Icons.volume_up),
                                    onPressed: () => _tts.speak(_resultText!),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
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
                              if (_metaText != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _metaText!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
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
