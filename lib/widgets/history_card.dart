import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../models/history_item.dart';
import '../services/tts_manager.dart';

/// Converted from item_history.xml + HistoryAdapter.kt ViewHolder
class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final TtsManager tts;

  const HistoryCard({super.key, required this.item, required this.tts});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: item.tagalogText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nakopya!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOURCE + DATE row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  color: const Color(0xFFEEF4FF),
                  child: Text(
                    item.sourceType.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.scanBg,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.formattedDate(),
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ORIGINAL TEXT (max 2 lines)
            Text(
              item.originalText.length > 120
                  ? '${item.originalText.substring(0, 120)}…'
                  : item.originalText,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // DETECTED LANGUAGE
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Text(
                'Wika: ${item.detectedLanguage}',
                style: const TextStyle(
                  color: AppColors.textTranslateBg,
                  fontSize: 11,
                ),
              ),
            ),

            const Divider(color: Color(0xFFF0F0F0), height: 1),
            const SizedBox(height: 8),

            // TAGALOG TRANSLATION
            Text(
              item.tagalogText,
              style: const TextStyle(
                color: AppColors.cardBorder,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // COPY + SPEAK buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _copy(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Kopyahin',
                      style: TextStyle(
                        color: AppColors.scanBg,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => tts.speak(item.tagalogText),
                  child: const Icon(
                    Icons.volume_up,
                    color: AppColors.scanBg,
                    size: 26,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
