import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz_question.dart';
import '../services/content_service.dart';
import '../services/quiz_generator.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _bestScoreKey = 'n5_quiz_best_score';
  final _contentService = ContentService();
  final _generator = QuizGenerator();

  List<QuizQuestion> _questions = const [];
  int _questionIndex = 0;
  int _score = 0;
  int _bestScore = 0;
  int? _selectedIndex;
  bool _loading = true;
  bool _finished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _finished = false;
      _questionIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _error = null;
    });
    try {
      final result = await _contentService.loadCards();
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _questions = _generator.generate(result.cards, count: 10);
        _bestScore = prefs.getInt(_bestScoreKey) ?? 0;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _select(int index) {
    if (_selectedIndex != null) return;
    setState(() {
      _selectedIndex = index;
      if (index == _questions[_questionIndex].correctIndex) _score += 1;
    });
  }

  Future<void> _next() async {
    if (_selectedIndex == null) return;
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex += 1;
        _selectedIndex = null;
      });
      return;
    }

    final best = _score > _bestScore ? _score : _bestScore;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, best);
    if (!mounted) return;
    setState(() {
      _bestScore = best;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
        title: const Text('N5 테스트'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _start)
              : _finished
                  ? _ResultView(
                      score: _score,
                      total: _questions.length,
                      bestScore: _bestScore,
                      onRetry: _start,
                    )
                  : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_questionIndex];
    return SafeArea(
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_questionIndex + 1) / _questions.length,
            minHeight: 5,
            color: const Color(0xFFF2B134),
            backgroundColor: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_questionIndex + 1} / ${_questions.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '점수 $_score',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF14213D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '이 한자의 뜻은 무엇인가요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  question.answer.kanji,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 150,
                    height: 1.25,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(question.options.length, (index) {
                  final selected = _selectedIndex == index;
                  final correct = question.correctIndex == index;
                  Color? background;
                  Color? foreground;
                  IconData? icon;
                  if (_selectedIndex != null && correct) {
                    background = const Color(0xFFD1FAE5);
                    foreground = const Color(0xFF047857);
                    icon = Icons.check_circle;
                  } else if (_selectedIndex != null && selected) {
                    background = const Color(0xFFFEE2E2);
                    foreground = const Color(0xFFB91C1C);
                    icon = Icons.cancel;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonalIcon(
                      onPressed:
                          _selectedIndex == null ? () => _select(index) : null,
                      icon: Icon(icon ?? Icons.circle_outlined, size: 20),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          question.options[index].meaningKo,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        backgroundColor: background,
                        foregroundColor: foreground,
                        disabledBackgroundColor:
                            background ?? const Color(0xFFE8E7E1),
                        disabledForegroundColor:
                            foreground ?? const Color(0xFF475569),
                      ),
                    ),
                  );
                }),
                if (_selectedIndex != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '음독 ${question.answer.onReadings.join(' · ')}  ·  훈독 ${question.answer.kunReadings.join(' · ')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _questionIndex == _questions.length - 1
                          ? '결과 보기'
                          : '다음 문제',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView(
      {required this.score,
      required this.total,
      required this.bestScore,
      required this.onRetry});
  final int score;
  final int total;
  final int bestScore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (score * 100 / total).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded,
                size: 72, color: Color(0xFFF2B134)),
            const SizedBox(height: 20),
            Text('$score / $total',
                style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14213D))),
            Text('$percent점',
                style: const TextStyle(fontSize: 22, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Text('최고 점수 $bestScore / $total',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 28),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: onRetry, child: const Text('다시 테스트'))),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('홈으로')),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
