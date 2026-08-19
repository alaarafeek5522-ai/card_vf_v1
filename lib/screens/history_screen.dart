import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await HistoryService.getHistory();
    if (mounted) setState(() { _history = h; _loading = false; });
  }

  Future<void> _clear() async {
    await HistoryService.clearHistory();
    if (mounted) setState(() => _history = []);
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('سجل العمليات', style: TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.offWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.redVF),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: const Text('مسح السجل', style: TextStyle(color: AppTheme.offWhite)),
                  content: const Text('هل تريد مسح كل السجل؟', style: TextStyle(color: AppTheme.grey)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppTheme.grey))),
                    TextButton(onPressed: () { Navigator.pop(context); _clear(); }, child: const Text('مسح', style: TextStyle(color: AppTheme.redVF))),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.redVF))
          : _history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, color: AppTheme.grey, size: 64),
                      SizedBox(height: 16),
                      Text('لا يوجد سجل بعد', style: TextStyle(color: AppTheme.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) {
                    final item = _history[i];
                    final success = item['success'] == true;
                    final statusColor = success ? Colors.green : AppTheme.redVF;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: statusColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['card'] ?? '', style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
                                Text(item['phone'] ?? '', style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
                                Text(_formatDate(item['date'] ?? ''), style: const TextStyle(color: AppTheme.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(
                            '${item['charge']} ج',
                            style: const TextStyle(color: AppTheme.redVF, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (i * 40).ms).slideX(begin: 0.1);
                  },
                ),
    );
  }
}
