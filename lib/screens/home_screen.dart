import 'package:flutter/material.dart';

import 'quiz_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
        title: const Text('JLPT 한자 쓰기'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'N5 한자를 직접 써 보고\n시험으로 확인하세요.',
              style: TextStyle(
                fontSize: 28,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: Color(0xFF14213D),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '학습용 추정 한자 103자 · 오프라인 사용 가능',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            _ModeCard(
              icon: Icons.edit_note_rounded,
              title: 'N5 한자 학습',
              subtitle: '한자를 먼저 쓴 뒤 눌러서 뜻과 읽기를 확인합니다.',
              buttonLabel: '학습 시작',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const StudyScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              icon: Icons.quiz_rounded,
              title: 'N5 테스트',
              subtitle: '103자 중 무작위 10문제를 4지선다로 풉니다.',
              buttonLabel: '테스트 시작',
              emphasized: true,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const QuizScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: emphasized ? const Color(0xFF14213D) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 36,
              color: emphasized
                  ? const Color(0xFFF2B134)
                  : const Color(0xFF14213D),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: emphasized ? Colors.white : const Color(0xFF14213D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                height: 1.5,
                color: emphasized ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: emphasized
                  ? FilledButton(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B134),
                        foregroundColor: const Color(0xFF14213D),
                      ),
                      child: Text(buttonLabel),
                    )
                  : FilledButton.tonal(
                      onPressed: onPressed,
                      child: Text(buttonLabel),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
