import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/history_item.dart';
import '../services/history_manager.dart';
import '../services/tts_manager.dart';
import '../widgets/history_card.dart';

/// Converted from HistoryActivity.kt + activity_history.xml
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TtsManager _tts = TtsManager();
  List<HistoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  @override
  void dispose() {
    _tts.shutdown();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final items = await HistoryManager.instance.getAll();
    if (mounted) setState(() => _items = items);
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Burahin ang History?'),
        content: const Text(
            'Mabubura ang lahat ng nakaraang salin. Sigurado ka ba?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hindi'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HistoryManager.instance.clear();
              _loadHistory();
            },
            child: const Text(
              'Oo, Burahin',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _items.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.historyBg, // purple_700 = #E07B39
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Title
                  const Expanded(
                    child: Text(
                      'HISTORY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  // Clear all button (invisible when empty)
                  Opacity(
                    opacity: isEmpty ? 0.0 : 1.0,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.white),
                      onPressed: isEmpty ? null : _confirmClear,
                    ),
                  ),
                ],
              ),
            ),

            // ── BODY ────────────────────────────────────────────────────────
            Expanded(
              child: isEmpty
                  // EMPTY STATE
                  ? const Center(
                      child: Text(
                        '\n\nWalang history pa.\nMag-translate ka muna!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  // HISTORY LIST (RecyclerView → ListView)
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      itemBuilder: (context, index) => HistoryCard(
                        item: _items[index],
                        tts: _tts,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
