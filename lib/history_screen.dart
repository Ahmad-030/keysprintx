import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/test_result.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<TestResult> _results = [];
  String _filter = 'all'; // all | test | practice
  String _sort = 'date'; // date | wpm | accuracy

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _results = _storage.getAllResults());

  List<TestResult> get _filtered {
    var list = _filter == 'all'
        ? _results
        : _results.where((r) => r.mode == _filter).toList();
    switch (_sort) {
      case 'wpm':
        list.sort((a, b) => b.wpm.compareTo(a.wpm));
        break;
      case 'accuracy':
        list.sort((a, b) => b.accuracy.compareTo(a.accuracy));
        break;
      default:
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return list;
  }

  Future<void> _delete(TestResult r) async {
    await _storage.deleteResult(r.id);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result deleted'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History'),
        content: const Text('Delete all test results? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _storage.clearAll();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter + Sort bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Mode filter chips
                Row(
                  children: [
                    _FilterChip('All', 'all', _filter, (v) => setState(() => _filter = v)),
                    const SizedBox(width: 8),
                    _FilterChip('Speed Test', 'test', _filter, (v) => setState(() => _filter = v)),
                    const SizedBox(width: 8),
                    _FilterChip('Practice', 'practice', _filter, (v) => setState(() => _filter = v)),
                  ],
                ),
                const SizedBox(height: 8),
                // Sort row
                Row(
                  children: [
                    Text('Sort by:', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 8),
                    _SortChip('Date', 'date', _sort, (v) => setState(() => _sort = v)),
                    const SizedBox(width: 6),
                    _SortChip('WPM', 'wpm', _sort, (v) => setState(() => _sort = v)),
                    const SizedBox(width: 6),
                    _SortChip('Accuracy', 'accuracy', _sort, (v) => setState(() => _sort = v)),
                    const Spacer(),
                    Text('${list.length} results', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: list.isEmpty
                ? _EmptyState()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _ResultCard(
                result: list[i],
                index: i,
                onDelete: () => _delete(list[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final TestResult result;
  final int index;
  final VoidCallback onDelete;
  const _ResultCard({required this.result, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: r.gradeColor.withOpacity(0.07), blurRadius: 14)],
        ),
        child: Row(
          children: [
            // Grade circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: r.gradeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(r.grade,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: r.gradeColor)),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${r.wpm} WPM',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: AppTheme.textDark)),
                      const SizedBox(width: 8),
                      _ModeBadge(r.mode),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${r.accuracy.toStringAsFixed(1)}% acc · ${r.mistakes} mistakes · ${r.totalChars} chars',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy · h:mm a').format(r.timestamp),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            Icon(Icons.swipe_left_rounded, size: 16, color: AppTheme.textLight),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.08, end: 0);
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Lottie.asset(
              AppConstants.lottieEmpty,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.history_rounded, size: 80, color: AppTheme.textLight),
            ),
          ),
          const SizedBox(height: 16),
          Text('No results yet', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: AppTheme.textMid)),
          const SizedBox(height: 8),
          Text('Complete a test to see your history here.',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _FilterChip(this.label, this.value, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 8)] : [],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppTheme.textMid)),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _SortChip(this.label, this.value, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTheme.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppTheme.primary : AppTheme.textMid)),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final String mode;
  const _ModeBadge(this.mode);

  @override
  Widget build(BuildContext context) {
    final isTest = mode == 'test';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isTest ? AppTheme.primarySoft : AppTheme.accentSoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isTest ? '⚡ Test' : '✏️ Practice',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isTest ? AppTheme.primary : AppTheme.accent),
      ),
    );
  }
}

// color helpers
extension on AppTheme {
  static const primarySoft = Color(0xFFEEF2FF);
  static const accentSoft  = Color(0xFFE8FDF6);
  static const textDark    = Color(0xFF1A1F3C);
  static const textMid     = Color(0xFF6B7280);
  static const textLight   = Color(0xFFB0B7C3);
  static const divider     = Color(0xFFEEF1FF);
}