import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/kanji_card.dart';

class ContentResult {
  const ContentResult({required this.cards, required this.isRemote});
  final List<KanjiCard> cards;
  final bool isRemote;
}

class ContentService {
  ContentService({http.Client? client}) : _client = client ?? http.Client();
  static const _baseUrl = 'https://meol.it.com';
  static const _boardId = String.fromEnvironment('PENX_BOARD_ID');
  final http.Client _client;

  Future<ContentResult> loadCards() async {
    if (_boardId.isNotEmpty) {
      try {
        final remote = await _loadPenxCards(_boardId);
        if (remote.isNotEmpty) {
          return ContentResult(cards: remote, isRemote: true);
        }
      } catch (_) {
        // The reviewed bundled dataset remains available for offline startup.
      }
    }
    final raw = await rootBundle.loadString('assets/data/n5.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final cards = (decoded['cards'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(KanjiCard.fromJson)
        .toList(growable: false);
    return ContentResult(cards: cards, isRemote: false);
  }

  Future<List<KanjiCard>> _loadPenxCards(String boardId) async {
    final cards = <KanjiCard>[];
    var page = 1;
    var totalPages = 1;
    do {
      final uri = Uri.parse(
          '$_baseUrl/api/posts?boardId=$boardId&limit=50&page=$page&lang=ko');
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) {
        throw StateError('PenX returned ${response.statusCode}');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      for (final raw in (body['posts'] as List<dynamic>? ?? const [])) {
        final card = _parsePenxPost(raw as Map<String, dynamic>);
        if (card != null) cards.add(card);
      }
      totalPages = (body['pagination'] as Map<String, dynamic>?)?['totalPages']
              as int? ??
          1;
      page += 1;
    } while (page <= totalPages);
    return cards;
  }

  KanjiCard? _parsePenxPost(Map<String, dynamic> post) {
    final title = post['title'] as String? ?? '';
    final kanjiMatch = RegExp(r'오늘의 한자\s+([^\s(])').firstMatch(title);
    if (kanjiMatch == null) return null;
    final level = RegExp(r'N[1-5]').firstMatch(title)?.group(0) ?? 'N5';
    final reading = RegExp(r'\(([^)]+)\)').firstMatch(title)?.group(1) ?? '';
    final content = post['content'] as String? ?? '';
    final meaning =
        RegExp(r'## 3\. 뜻\s*\n([^\n]+)').firstMatch(content)?.group(1) ?? '';
    return KanjiCard(
      id: 'penx-${post['id']}',
      kanji: kanjiMatch.group(1)!,
      level: level,
      meaningKo: meaning,
      onReadings: reading.isEmpty ? const [] : [reading],
      kunReadings: const [],
      strokeCount: 0,
      radicalNumber: 0,
      imageUrl: post['image_url'] as String?,
      remoteContent: content,
    );
  }
}
