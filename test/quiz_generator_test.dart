import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_kanji/models/kanji_card.dart';
import 'package:jlpt_kanji/services/quiz_generator.dart';

KanjiCard card(int index) => KanjiCard(
      id: '$index',
      kanji: String.fromCharCode(0x4E00 + index),
      level: 'N5',
      meaningKo: '뜻 $index',
      onReadings: const [],
      kunReadings: const [],
      strokeCount: index + 1,
      radicalNumber: 1,
    );

void main() {
  test('generates ten unique four-choice questions', () {
    final cards = List.generate(20, card);
    final questions = QuizGenerator(random: Random(7)).generate(cards);

    expect(questions, hasLength(10));
    expect(questions.map((q) => q.answer.id).toSet(), hasLength(10));
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(question.options.map((option) => option.id).toSet(), hasLength(4));
      expect(question.correctIndex, inInclusiveRange(0, 3));
      expect(question.options[question.correctIndex].id, question.answer.id);
    }
  });

  test('rejects a dataset too small for four choices', () {
    expect(
      () => QuizGenerator(random: Random(1)).generate(List.generate(3, card)),
      throwsArgumentError,
    );
  });
}
