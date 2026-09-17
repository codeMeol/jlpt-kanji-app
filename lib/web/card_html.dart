import 'dart:convert';

import '../models/kanji_card.dart';

String buildCardHtml(KanjiCard card) {
  final escape = const HtmlEscape();
  final kanji = escape.convert(card.kanji);
  final level = escape.convert(card.level);
  final meaning = escape.convert(card.meaningKo);
  final on = escape.convert(card.onReadings.join(' · '));
  final kun = escape.convert(card.kunReadings.join(' · '));
  final remote = card.remoteContent == null
      ? ''
      : '<div class="remote">${escape.convert(card.remoteContent!).replaceAll('\n', '<br>')}</div>';
  final image = card.imageUrl?.startsWith('https://') == true
      ? '<img class="kanji-image" src="${escape.convert(card.imageUrl!)}" alt="$kanji">'
      : '''<svg class="kanji-image" viewBox="0 0 720 720" role="img" aria-label="$kanji">
          <rect width="720" height="720" rx="36" fill="#fffdf8"/>
          <path d="M360 48V672M48 360H672M70 70L650 650M650 70L70 650" stroke="#eadfca" stroke-width="3" stroke-dasharray="12 14"/>
          <rect x="48" y="48" width="624" height="624" rx="18" fill="none" stroke="#d9c8a7" stroke-width="4"/>
          <text x="360" y="505" text-anchor="middle" font-size="430" font-family="Noto Serif CJK JP, Noto Serif JP, serif" fill="#111827">$kanji</text>
        </svg>''';
  return '''<!doctype html><html lang="ko"><head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    *{box-sizing:border-box;-webkit-tap-highlight-color:transparent}body{margin:0;min-height:100vh;background:#f6f4ee;font-family:-apple-system,BlinkMacSystemFont,"Noto Sans KR",sans-serif;color:#14213d}
    button{all:unset;display:block;width:100%;min-height:100vh;padding:20px;cursor:pointer}.wrap{max-width:720px;margin:0 auto}.kanji-image{display:block;width:100%;max-height:72vh;object-fit:contain;border-radius:24px;box-shadow:0 12px 36px rgba(20,33,61,.12);background:#fffdf8}
    .hint{margin:18px 0 0;text-align:center;color:#64748b;font-size:15px}#answer{display:none;margin-top:18px;padding:22px;border-radius:20px;background:white;box-shadow:0 8px 24px rgba(20,33,61,.08);text-align:left}#answer.show{display:block}.level{color:#b7791f;font-size:14px;font-weight:800;letter-spacing:.08em}h1{margin:8px 0 14px;font-size:32px}dl{display:grid;grid-template-columns:72px 1fr;gap:10px 12px;margin:0}dt{color:#64748b;font-weight:700}dd{margin:0;font-weight:650}.remote{margin-top:20px;padding-top:20px;border-top:1px solid #e2e8f0;line-height:1.7}
  </style></head><body>
  <button type="button" onclick="const a=document.getElementById('answer');a.classList.toggle('show');document.querySelector('.hint').textContent=a.classList.contains('show')?'다시 누르면 설명을 숨깁니다':'직접 써 본 뒤 눌러서 확인하세요';"><div class="wrap">
    $image<p class="hint">직접 써 본 뒤 눌러서 확인하세요</p><section id="answer" aria-live="polite">
    <div class="level">$level · ${card.strokeCount > 0 ? '${card.strokeCount}획' : 'PenX 카드'}</div><h1>$kanji · $meaning</h1><dl>
    ${on.isEmpty ? '' : '<dt>음독</dt><dd>$on</dd>'}${kun.isEmpty ? '' : '<dt>훈독</dt><dd>$kun</dd>'}${card.radicalNumber > 0 ? '<dt>부수</dt><dd>${card.radicalNumber}번</dd>' : ''}
    </dl>$remote</section></div></button></body></html>''';
}
