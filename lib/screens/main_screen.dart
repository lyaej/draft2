import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'scan_screen.dart';
import 'text_translate_screen.dart';
import 'voice_translate_screen.dart';
import 'history_screen.dart';

/// Converted from MainActivity.kt + activity_main.xml
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOrange,
      body: Stack(
        children: [
          // ── MAIN CONTENT ──────────────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  Image.asset(
                    'assets/images/tagalook_logo.png',
                    height: 163,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),

                  // QR SCAN BUTTON (Blue) - button7
                  _MenuButton(
                    color: AppColors.scanBg,
                    shadowColor: AppColors.btnBlueShadow,
                    height: 110,
                    title: 'SCAN',
                    subtitle: 'ISALIN ANG ANUMANG WIKA SA FILIPINO GAMIT ANG I-SCAN',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ScanScreen())),
                  ),
                  const SizedBox(height: 20),

                  // TEXT TRANSLATE BUTTON (Red) - button6
                  _MenuButton(
                    color: AppColors.textTranslateBg,
                    shadowColor: AppColors.btnRedShadow,
                    height: 130,
                    title: 'TEXT TRANSLATE',
                    subtitle: 'ISALIN ANG ANUMANG WIKA SA FILIPINO GAMIT ANG TEXT',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TextTranslateScreen())),
                  ),
                  const SizedBox(height: 20),

                  // VOICE TRANSLATE BUTTON (Green) - button8
                  _MenuButton(
                    color: AppColors.green,
                    shadowColor: AppColors.btnGreenShadow,
                    height: 110,
                    title: 'VOICE TRANSLATE',
                    subtitle: 'MAGSALITA AT ISALIN SA FILIPINO',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VoiceTranslateScreen())),
                  ),
                ],
              ),
            ),
          ),

          // ── HISTORY BUTTON (bottom-right) - button5 ───────────────────────
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen())),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.history,
                  size: 26,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Menu Button Widget ───────────────────────────────────────────────
/// Converted from btn_blue_shadow / btn_red_shadow / btn_green_shadow drawables
class _MenuButton extends StatelessWidget {
  final Color color;
  final Color shadowColor;
  final double height;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.color,
    required this.shadowColor,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    letterSpacing: 0.08,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
