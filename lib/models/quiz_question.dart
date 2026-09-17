import 'kanji_card.dart';

class QuizQuestion {
  const QuizQuestion({required this.answer, required this.options});

  final KanjiCard answer;
  final List<KanjiCard> options;

  int get correctIndex => options.indexWhere((card) => card.id == answer.id);
}
