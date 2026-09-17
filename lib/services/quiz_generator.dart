import 'dart:math';

import '../models/kanji_card.dart';
import '../models/quiz_question.dart';

class QuizGenerator {
  QuizGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  List<QuizQuestion> generate(List<KanjiCard> cards, {int count = 10}) {
    if (cards.length < 4) {
      throw ArgumentError('테스트를 만들려면 최소 4장의 카드가 필요합니다.');
    }

    final answers = List<KanjiCard>.from(cards)..shuffle(_random);
    final questionCount = min(count, answers.length);

    return answers.take(questionCount).map((answer) {
      final distractors = cards
          .where((card) =>
              card.id != answer.id && card.meaningKo != answer.meaningKo)
          .toList()
        ..shuffle(_random);
      if (distractors.length < 3) {
        throw StateError('서로 다른 뜻을 가진 오답 카드가 부족합니다.');
      }
      final options = <KanjiCard>[answer, ...distractors.take(3)]
        ..shuffle(_random);
      return QuizQuestion(answer: answer, options: options);
    }).toList(growable: false);
  }
}
