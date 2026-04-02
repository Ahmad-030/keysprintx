import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:keysprintx/stat_card.dart';
import 'package:keysprintx/storage_service.dart';
import 'package:keysprintx/test_result.dart';
import 'package:lottie/lottie.dart';
import 'app_constants.dart';
import 'app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  final _storage = StorageService();
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = _storage.getAllResults();
    if (all.isEmpty) return const _EmptyStats();

    final best   = _storage.getBest()!;
    final avgWpm = _storage.avgWpm;
    final avgAcc = _storage.avgAccuracy;
    final total  = _storage.totalTests;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'WPM Trend'),
            Tab(text: 'Letters'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _OverviewTab(best: best, avgWpm: avgWpm, avgAcc: avgAcc, total: total),
          _WpmTrendTab(results: all),
          _LettersTab(mistakes: _storage.getMistakeLetters()),
        ],
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final TestResult best;
  final double avgWpm, avgAcc;
  final int total;

  const _OverviewTab({
    required this.best,
    required this.avgWpm,
    required this.avgAcc,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BestCard(result: best),
          const SizedBox(height: 20),
          Text('Averages', style: Theme.of(context).textTheme.titleLarge)
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(value: avgWpm.toStringAsFixed(0),        label: 'Avg WPM',      icon: Icons.speed_rounded,          color: AppTheme.primary, animDelay: 200),
              StatCard(value: '${avgAcc.toStringAsFixed(1)}%',  label: 'Avg Accuracy', icon: Icons.track_changes_rounded,  color: AppTheme.accent,  animDelay: 300),
              StatCard(value: '$total',                         label: 'Total Tests',  icon: Icons.assignment_rounded,     color: AppTheme.warning, animDelay: 400),
              StatCard(value: best.grade,                       label: 'Best Grade',   icon: Icons.emoji_events_rounded,   color: best.gradeColor,  animDelay: 500),
            ],
          ),
          const SizedBox(height: 24),
          Text('Accuracy Distribution', style: Theme.of(context).textTheme.titleLarge)
              .animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          _AccuracyDonut(accuracy: avgAcc),
        ],
      ),
    );
  }
}

class _BestCard extends StatelessWidget {
  final TestResult result;
  const _BestCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [result.gradeColor, result.gradeColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: result.gradeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🏆 Personal Best',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text('${result.wpm} WPM',
                    style: Theme.of(context).textTheme.displaySmall!
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                Text('${result.accuracy.toStringAsFixed(1)}% accuracy · ${result.gradeLabel}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(result.grade,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class _AccuracyDonut extends StatelessWidget {
  final double accuracy;
  const _AccuracyDonut({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 16)],
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: accuracy,
                    color: AppTheme.accent,
                    title: '${accuracy.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 100 - accuracy,
                    color: AppTheme.divider,
                    title: '',
                    radius: 50,
                  ),
                ],
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend(AppTheme.accent, 'Correct'),
              const SizedBox(height: 8),
              _Legend(AppTheme.divider, 'Mistakes'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ── WPM Trend Tab ─────────────────────────────────────────
class _WpmTrendTab extends StatelessWidget {
  final List<TestResult> results;
  const _WpmTrendTab({required this.results});

  @override
  Widget build(BuildContext context) {
    final recent = results.take(20).toList().reversed.toList();

    // ── fix: need at least 2 points for a line; pad if only 1 result ──
    final bool singlePoint = recent.length == 1;
    final chartData = singlePoint
        ? [recent[0], recent[0]] // duplicate so fl_chart doesn't crash
        : recent;

    final spots = List.generate(
      chartData.length,
          (i) => FlSpot(i.toDouble(), chartData[i].wpm.toDouble()),
    );

    final maxWpm   = chartData.map((r) => r.wpm).reduce((a, b) => a > b ? a : b);
    final maxY     = (maxWpm + 20).toDouble();
    // ── fix: ensure minY gives breathing room so single dot isn't at bottom ──
    final minY     = ((maxWpm - 30).clamp(0, maxWpm)).toDouble();
    final maxX     = (chartData.length - 1).toDouble().clamp(1.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── fix: show "1 test" correctly, not "last 1 tests" ──
          Text(
            singlePoint
                ? 'WPM — 1 test so far'
                : 'WPM over last ${recent.length} tests',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          if (singlePoint)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Complete more tests to see your trend line.',
                style: Theme.of(context).textTheme.bodySmall!
                    .copyWith(color: AppTheme.textLight),
              ).animate().fadeIn(delay: 100.ms),
            ),
          const SizedBox(height: 6),
          Container(
            height: 260,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 16)],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppTheme.divider, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 20,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.primary,
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(0.15), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

          const SizedBox(height: 24),
          Text('Accuracy Trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _AccuracyChart(results: chartData),
        ],
      ),
    );
  }
}

class _AccuracyChart extends StatelessWidget {
  final List<TestResult> results;
  const _AccuracyChart({required this.results});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      results.length,
          (i) => FlSpot(i.toDouble(), results[i].accuracy),
    );
    final maxX = (results.length - 1).toDouble().clamp(1.0, double.infinity);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.06), blurRadius: 16)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppTheme.divider, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}%',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
                ),
              ),
            ),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: maxX,   // ── fix: was missing, caused crash with 1 result
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                  colors: [AppTheme.accent, Color(0xFF4DD9C8)]),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppTheme.accent.withOpacity(0.15), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }
}

// ── Letters Tab ───────────────────────────────────────────
class _LettersTab extends StatelessWidget {
  final Map<String, int> mistakes;
  const _LettersTab({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    if (mistakes.isEmpty) {
      return Center(
        child: Text(
          'No mistake data yet.\nComplete more tests!',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: AppTheme.textLight),
        ),
      );
    }

    final maxVal  = mistakes.values.reduce((a, b) => a > b ? a : b).toDouble();
    final entries = mistakes.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Difficult Letters', style: Theme.of(context).textTheme.titleLarge)
              .animate().fadeIn(),
          const SizedBox(height: 6),
          Text('Letters you mistype the most', style: Theme.of(context).textTheme.bodySmall)
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.error.withOpacity(0.06), blurRadius: 16)],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal + 2,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= entries.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            entries[i].key.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(entries.length, (i) {
                  final pct   = entries[i].value / maxVal;
                  final color = Color.lerp(AppTheme.warning, AppTheme.error, pct)!;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: entries[i].value.toDouble(),
                      color: color,
                      width: 22,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ]);
                }),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

          const SizedBox(height: 24),
          Text('Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          ...List.generate(entries.length, (i) {
            final pct   = entries[i].value / maxVal;
            final color = Color.lerp(AppTheme.warning, AppTheme.error, pct)!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        entries[i].key.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: color, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppTheme.divider,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entries[i].value}x',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              )
                  .animate(delay: Duration(milliseconds: i * 60))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────
class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Statistics')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                AppConstants.lottieChart,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.insights_rounded, size: 80, color: AppTheme.textLight),
              ),
            ),
            const SizedBox(height: 16),
            Text('No data yet',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: AppTheme.textMid)),
            const SizedBox(height: 8),
            Text('Complete tests to see your statistics.',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}

// ── Color helpers ─────────────────────────────────────────
extension _C on AppTheme {
  static const textDark  = Color(0xFF1A1F3C);
  static const textMid   = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B7C3);
  static const divider   = Color(0xFFEEF1FF);
}