import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_kanji/screens/home_screen.dart';

void main() {
  testWidgets('shows both N5 study and quiz entry points', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen()),
    );

    expect(find.text('N5 한자 학습'), findsOneWidget);
    expect(find.text('학습 시작'), findsOneWidget);
    expect(find.text('N5 테스트'), findsOneWidget);
    expect(find.text('테스트 시작'), findsOneWidget);
  });
}
