import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kanji_card.dart';
import '../services/content_service.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  static const _lastIndexKey = 'jlpt_last_index';
  static const _knownKey = 'jlpt_known_ids';

  final _contentService = ContentService();
  List<KanjiCard> _cards = const [];
  Set<String> _known = {};
  int _index = 0;
  bool _loading = true;
  bool _revealed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await _contentService.loadCards();
      if (!mounted) return;
      _cards = result.cards;
      _known = (prefs.getStringList(_knownKey) ?? const []).toSet();
      _index = (prefs.getInt(_lastIndexKey) ?? 0)
          .clamp(0, max(0, _cards.length - 1));
      setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _saveIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastIndexKey, _index);
  }

  Future<void> _move(int delta) async {
    if (_cards.isEmpty) return;
    setState(() {
      _revealed = false;
      _index = (_index + delta) % _cards.length;
      if (_index < 0) _index = _cards.length - 1;
    });
    await _saveIndex();
  }

  Future<void> _shuffle() async {
    if (_cards.length < 2) return;
    var next = _index;
    while (next == _index) {
      next = Random.secure().nextInt(_cards.length);
    }
    setState(() {
      _revealed = false;
      _index = next;
    });
    await _saveIndex();
  }

  Future<void> _toggleKnown() async {
    final id = _cards[_index].id;
    setState(() {
      _known.contains(id) ? _known.remove(id) : _known.add(id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_knownKey, _known.toList()..sort());
  }

  void _reveal() {
    HapticFeedback.mediumImpact();
    setState(() => _revealed = !_revealed);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F4EE),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F4EE),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(24), child: Text(_error!))),
      );
    }

    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F4EE),
        body: const Center(child: Text('데이터가 없습니다')),
      );
    }

    final card = _cards[_index];
    final isKnown = _known.contains(card.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
        title: Text('${card.level}  ${_index + 1}/${_cards.length}'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                isKnown ? '✓ 암기함' : '',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _reveal,
        child: SafeArea(
          child: Column(
            children: [
              // Kanji card area
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Kanji
                        Text(
                          card.kanji,
                          style: const TextStyle(
                            fontSize: 200,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF111827),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Hint / answer
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _revealed
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E2D8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              ' tap to reveal ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          secondChild: Column(
                            children: [
                              Text(
                                card.meaningKo,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF14213D),
                                ),
                              ),
                              if (card.onReadings.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '음독 ${card.onReadings.join(' · ')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A5568),
                                  ),
                                ),
                              ],
                              if (card.kunReadings.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '훈독 ${card.kunReadings.join(' · ')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A5568),
                                  ),
                                ),
                              ],
                              if (card.strokeCount > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${card.strokeCount}획',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Navigation bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBtn(
                      icon: Icons.arrow_back_rounded,
                      label: '이전',
                      onPressed: () => _move(-1),
                    ),
                    _NavBtn(
                      icon: Icons.shuffle_rounded,
                      label: '셔플',
                      onPressed: _shuffle,
                    ),
                    _ActionBtn(
                      label: isKnown ? '암기 완료' : '암기 표시',
                      icon: isKnown
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      filled: isKnown,
                      onPressed: _toggleKnown,
                    ),
                    _NavBtn(
                      icon: Icons.arrow_forward_rounded,
                      label: '다음',
                      onPressed: () => _move(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn(
      {required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon),
          tooltip: label,
        ),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.filled,
      required this.onPressed});
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          style: FilledButton.styleFrom(
            backgroundColor:
                filled ? const Color(0xFF10B981).withAlpha(30) : null,
            foregroundColor: filled ? const Color(0xFF059669) : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}
