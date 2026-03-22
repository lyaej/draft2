import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../app_colors.dart';
import '../services/api_service.dart';
import '../services/history_manager.dart';
import '../services/tts_manager.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  final _api = ApiService();
  final _tts = TtsManager();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool _isTranslating = false;
  bool _isClosed = false;
  String _resultText = 'Waiting for text...';
  String _scannedText = '';   // ✅ OCR result — ipapakita agad
  String _lastTranslatedText = '';
  bool _isTranslationPending = false;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _api.preWarm();
    _initCamera();
  }

  @override
  void dispose() {
    _isClosed = true;
    _cooldownTimer?.cancel();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _recognizer.close();
    _tts.shutdown();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
    _cameraController!.startImageStream(_processFrame);
  }

  void _processFrame(CameraImage image) {
    if (_isTranslating || _isClosed) return;

    final bytes = image.planes.length == 1
        ? image.planes[0].bytes
        : Uint8List.fromList(image.planes.expand((p) => p.bytes).toList());

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    _runOcr(inputImage);
  }

  Future<void> _runOcr(InputImage inputImage) async {
    if (_isTranslating || _isClosed) return;

    try {
      final result = await _recognizer.processImage(inputImage);
      final text = result.text.trim();

      if (text.isEmpty || text == _lastTranslatedText) return;

      _isTranslating = true;
      _lastTranslatedText = text;

      // ✅ Ipakita AGAD ang nakitang text habang nag-ta-translate
      if (mounted) {
        setState(() {
          _scannedText = text;
          _resultText = 'Nagsasalin...';
          _isTranslationPending = true;
        });
      }

      try {
        final translated = await _api.translateTextFast(text);
        await HistoryManager.instance.save(translated, 'camera');
        if (mounted && !_isClosed) {
          setState(() {
            _resultText = translated.tagalog;
            _isTranslationPending = false;
          });
        }
      } catch (_) {
        if (mounted && !_isClosed) {
          setState(() {
            _resultText = 'Waiting for text...';
            _isTranslationPending = false;
          });
        }
        _lastTranslatedText = '';
      } finally {
        _cooldownTimer = Timer(const Duration(milliseconds: 1500), () {
          if (!_isClosed) _isTranslating = false;
        });
      }
    } catch (_) {
      _isTranslating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scanBg,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'SCAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // CAMERA PREVIEW
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _cameraController != null &&
                      _cameraController!.value.isInitialized
                      ? CameraPreview(_cameraController!)
                      : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ OCR TEXT — ipinakita agad bago pa lumabas ang salin
            if (_scannedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _scannedText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // RESULT CARD
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'TRANSLATION:',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: AppColors.cardBorder,
                            ),
                          ),
                        ),
                        // ✅ Loading indicator habang nag-ta-translate
                        if (_isTranslationPending)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.scanBg,
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.volume_up,
                                color: AppColors.scanBg),
                            onPressed: () => _tts.speak(_resultText),
                          ),
                      ],
                    ),
                    const Divider(color: AppColors.cardBorder),
                    Expanded(
                      child: Text(
                        _resultText,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: _isTranslationPending
                              ? Colors.grey
                              : AppColors.cardBorder,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
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