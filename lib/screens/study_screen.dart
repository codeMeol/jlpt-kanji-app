import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/kanji_card.dart';
import '../services/content_service.dart';
import '../web/card_html.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  static const _lastIndexKey = 'last_card_index';
  static const _knownKey = 'known_card_ids';
  late final WebViewController _controller;
  final _contentService = ContentService();
  List<KanjiCard> _cards = const [];
  Set<String> _known = <String>{};
  int _index = 0;
  bool _loading = true;
  bool _remote = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF6F4EE))
      ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (request) => request.url.startsWith('about:') ||
                  request.url.startsWith('data:')
              ? NavigationDecision.navigate
              : NavigationDecision.prevent));
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await _contentService.loadCards();
      if (!mounted) return;
      _cards = result.cards;
      _remote = result.isRemote;
      _known = (prefs.getStringList(_knownKey) ?? const []).toSet();
      _index = (prefs.getInt(_lastIndexKey) ?? 0)
          .clamp(0, max(0, _cards.length - 1));
      if (_cards.isNotEmpty) await _showCurrent();
      setState(() => _loading = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _showCurrent() async {
    if (_cards.isEmpty) return;
    await _controller.loadHtmlString(buildCardHtml(_cards[_index]));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastIndexKey, _index);
    if (mounted) setState(() {});
  }

  Future<void> _move(int delta) async {
    if (_cards.isEmpty) return;
    _index = (_index + delta) % _cards.length;
    if (_index < 0) _index = _cards.length - 1;
    await _showCurrent();
  }

  Future<void> _shuffle() async {
    if (_cards.length < 2) return;
    var next = _index;
    while (next == _index) {
      next = Random.secure().nextInt(_cards.length);
    }
    _index = next;
    await _showCurrent();
  }

  Future<void> _toggleKnown() async {
    final id = _cards[_index].id;
    _known.contains(id) ? _known.remove(id) : _known.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_knownKey, _known.toList()..sort());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards.isEmpty ? null : _cards[_index];
    final isKnown = card != null && _known.contains(card.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(card == null
            ? 'JLPT 한자 쓰기'
            : '${card.level}  ${_index + 1}/${_cards.length}'),
        actions: [
          if (!_loading && _cards.isNotEmpty)
            Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                    child: Text(_remote ? 'PenX' : '오프라인',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70))))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24), child: Text(_error!)))
              : WebViewWidget(controller: _controller),
      bottomNavigationBar: _cards.isEmpty
          ? null
          : SafeArea(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(children: [
                IconButton.filledTonal(
                    tooltip: '이전 한자',
                    onPressed: () => _move(-1),
                    icon: const Icon(Icons.arrow_back_rounded)),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                    tooltip: '무작위 한자',
                    onPressed: _shuffle,
                    icon: const Icon(Icons.shuffle_rounded)),
                const Spacer(),
                FilledButton.tonalIcon(
                    onPressed: _toggleKnown,
                    icon: Icon(isKnown
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked),
                    label: Text(isKnown ? '암기함' : '암기 표시')),
                const Spacer(),
                IconButton.filled(
                    tooltip: '다음 한자',
                    onPressed: () => _move(1),
                    icon: const Icon(Icons.arrow_forward_rounded)),
              ]),
            )),
    );
  }
}
