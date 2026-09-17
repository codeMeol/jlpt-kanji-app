import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_kanji/models/kanji_card.dart';
import 'package:jlpt_kanji/web/card_html.dart';

void main() {
  test('card HTML starts hidden and contains study details', () {
    const card = KanjiCard(
        id: '65E5',
        kanji: '日',
        level: 'N5',
        meaningKo: '날 일',
        onReadings: ['ニチ', 'ジツ'],
        kunReadings: ['ひ'],
        strokeCount: 4,
        radicalNumber: 72);
    final html = buildCardHtml(card);
    expect(html, contains('日'));
    expect(html, contains('날 일'));
    expect(html, contains('ニチ · ジツ'));
    expect(html, contains('#answer{display:none'));
    expect(html, contains("classList.toggle('show')"));
  });

  test('remote content is escaped before rendering', () {
    const card = KanjiCard(
        id: 'remote-1',
        kanji: '人',
        level: 'N5',
        meaningKo: '사람 인',
        onReadings: [],
        kunReadings: [],
        strokeCount: 0,
        radicalNumber: 0,
        remoteContent: '<script>alert(1)</script>');
    final html = buildCardHtml(card);
    expect(html, contains('&lt;script&gt;'));
    expect(html, isNot(contains('<script>alert(1)</script>')));
  });
}
