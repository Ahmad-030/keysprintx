import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keysprintx/storage_service.dart';
import 'package:keysprintx/test_result.dart';
import 'package:keysprintx/typing_texts.dart';
import 'app_theme.dart';
import 'result_screen.dart';

class TypingScreen extends StatefulWidget {
  final String mode;
  const TypingScreen({super.key, required this.mode});

  @override
  State<TypingScreen> createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen>
    with SingleTickerProviderStateMixin {
  final _storage = StorageService();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  late String _targetText;
  late int _totalSeconds;
  int _remaining = 0;
  int _currentIndex = 0;
  int _mistakes = 0;
  bool _started = false;
  bool _finished = false;
  bool _animationsDone = false;
  bool _statsRowVisible = false; // ← new flag
  Timer? _timer;
  final Map<String, int> _mistakeMap = {};
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _totalSeconds = _storage.testDuration;
    _remaining = _totalSeconds;
    _targetText = TypingTexts.getRandom(_storage.difficulty);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _animationsDone = true);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _finish();
    });
  }

  void _onTextChanged(String value) {
    if (_finished) return;

    if (!_started && value.isNotEmpty) {
      _started = true;
      _statsRowVisible = true; // set BEFORE setState so no layout shift
      _startTimer();
    }

    if (value.isNotEmpty) {
      final last = value.length - 1;
      if (last < _targetText.length && value[last] != _targetText[last]) {
        _mistakes++;
        final ch = _targetText[last];
        _mistakeMap[ch] = (_mistakeMap[ch] ?? 0) + 1;
        HapticFeedback.lightImpact();
      }
    }

    setState(() {
      _currentIndex = value.length;
    });

    if (value.length >= _targetText.length) {
      _finish();
    }
  }

  void _finish() {
    if (_finished) return;
    _timer?.cancel();
    setState(() => _finished = true);

    final elapsed = _totalSeconds - _remaining;
    final wordsTyped = _currentIndex / 5.0;
    final minutes = (elapsed == 0 ? 1 : elapsed) / 60.0;
    final wpm = (wordsTyped / minutes).round().clamp(0, 9999);
    final correct = (_currentIndex - _mistakes).clamp(0, _currentIndex);
    final accuracy =
    _currentIndex == 0 ? 0.0 : (correct / _currentIndex * 100);

    final result = TestResult(
      id: _storage.generateId(),
      wpm: wpm,
      accuracy: accuracy,
      mistakes: _mistakes,
      timestamp: DateTime.now(),
      duration: elapsed,
      mode: widget.mode,
      totalChars: _currentIndex,
      mistakeLetters: _mistakeMap,
    );

    _storage.saveResult(result);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              ResultScreen(result: result, mode: widget.mode),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  double get _progress => _currentIndex / _targetText.length;
  double get _timerProgress => _remaining / _totalSeconds;

  int get _liveWpm {
    if (!_started) return 0;
    final elapsed = (_totalSeconds - _remaining).clamp(1, 9999);
    final words = _currentIndex / 5.0;
    return (words / (elapsed / 60.0)).round();
  }

  double get _liveAccuracy {
    if (_currentIndex == 0) return 100;
    final correct = (_currentIndex - _mistakes).clamp(0, _currentIndex);
    return correct / _currentIndex * 100;
  }

  @override
  Widget build(BuildContext context) {
    final progressValue =
    (widget.mode == 'test' ? _timerProgress : _progress).clamp(0.0, 1.0);
    final progressColor = progressValue < 0.25
        ? AppTheme.error
        : progressValue < 0.5
        ? AppTheme.warning
        : AppTheme.accent;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
            widget.mode == 'test' ? '⚡ Speed Test' : '✏️ Practice Mode'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.mode == 'test')
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _TimerBadge(
                  remaining: _remaining, total: _totalSeconds),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            children: [
              // ── Progress bar ──
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: AppTheme.divider,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 24),

              // ── Text display container ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(0.06),
                          blurRadius: 20)
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: _TextDisplay(
                      target: _targetText,
                      typed: _controller.text,
                      currentIndex: _currentIndex,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Live stats — always reserves space, no layout shift ──
              Visibility(
                visible: _statsRowVisible && _storage.showLiveWpm,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      _Chip('$_liveWpm WPM', Icons.speed_rounded,
                          AppTheme.primary),
                      const SizedBox(width: 8),
                      _Chip(
                          '${_liveAccuracy.toStringAsFixed(0)}%',
                          Icons.track_changes_rounded,
                          AppTheme.accent),
                      const SizedBox(width: 8),
                      _Chip('$_currentIndex chars',
                          Icons.text_fields_rounded, AppTheme.warning),
                    ],
                  ),
                ),
              ),

              // ── TextField ──
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: false,
                onChanged: _onTextChanged,
                enabled: !_finished,
                maxLines: 1,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.none,
                autocorrect: false,
                enableSuggestions: false,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: _started
                      ? 'Keep typing...'
                      : 'Start typing to begin...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  filled: true,
                  fillColor: const Color(0xFFEEF2FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppTheme.primary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.keyboard_alt_rounded,
                      color: AppTheme.primary),
                ),
              ),

              const SizedBox(height: 16),

              // ── Hint — always reserves space, no layout shift ──
              Visibility(
                visible: !_started,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(
                  '⏱ Timer starts when you begin typing',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppTheme.textLight),
                ),
              ),

              // ── Bottom padding for keyboard ──
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom + 16
                    : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  final int remaining, total;
  const _TimerBadge({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final isLow = remaining <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLow
            ? const Color(0xFFFFECF0)
            : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded,
              size: 16,
              color: isLow ? AppTheme.error : AppTheme.primary),
          const SizedBox(width: 4),
          Text('${remaining}s',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isLow ? AppTheme.error : AppTheme.primary,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class _TextDisplay extends StatelessWidget {
  final String target, typed;
  final int currentIndex;
  const _TextDisplay(
      {required this.target,
        required this.typed,
        required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(height: 1.8, fontSize: 17),
        children: List.generate(target.length, (i) {
          Color color;
          FontWeight weight = FontWeight.w400;
          TextDecoration decoration = TextDecoration.none;

          if (i < typed.length) {
            if (typed[i] == target[i]) {
              color = AppTheme.accent;
              weight = FontWeight.w600;
            } else {
              color = AppTheme.error;
              decoration = TextDecoration.underline;
            }
          } else if (i == typed.length) {
            color = AppTheme.primary;
            weight = FontWeight.w700;
          } else {
            color = AppTheme.textLight;
          }

          return TextSpan(
            text: target[i],
            style: TextStyle(
                color: color,
                fontWeight: weight,
                decoration: decoration),
          );
        }),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

extension _AppThemeColors on AppTheme {
  static const divider = Color(0xFFEEF1FF);
  static const textLight = Color(0xFFB0B7C3);
}