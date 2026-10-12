import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/word_note.dart';
import '../services/supabase_service.dart';
import 'result_screen.dart'
    show kBgDark, kBgCard, kPurplePrimary, kPurpleAccent, kPurpleLight;

enum _NotebookFilter { all, learned, review }

class WordNotesScreen extends StatefulWidget {
  final int? initialTopicId;
  final String? initialMode;

  const WordNotesScreen({super.key, this.initialTopicId, this.initialMode});

  @override
  State<WordNotesScreen> createState() => _WordNotesScreenState();
}

class _WordNotesScreenState extends State<WordNotesScreen> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();

  List<WordNote> _allWords = [];
  bool _loading = true;
  String? _error;
  _NotebookFilter _filter = _NotebookFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadWords();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
  }

  Future<void> _loadWords() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final words = await SupabaseService.fetchWordNotes();
      setState(() {
        _allWords = words;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load your notebook. Pull to refresh.';
        _loading = false;
      });
    }
  }

  Future<void> _speak(String word) async {
    if (word.isEmpty) return;
    await _tts.stop();
    await _tts.speak(word);
  }

  Future<void> _toggleLearned(WordNote note) async {
    final updated = note.copyWith(learned: !note.learned);
    setState(() {
      _allWords = [
        for (final w in _allWords)
          if (w.id == note.id) updated else w,
      ];
    });
    if (note.id != null) {
      try {
        await SupabaseService.markWordLearned(note.id!, updated.learned);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _allWords = [
            for (final w in _allWords)
              if (w.id == note.id) note else w,
          ];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update. Try again.')),
        );
      }
    }
  }

  List<WordNote> get _filteredWords {
    Iterable<WordNote> list = _allWords;

    if (widget.initialTopicId != null) {
      list = list.where((w) => w.topicId == widget.initialTopicId);
    }
    if (widget.initialMode != null) {
      list = list.where((w) => w.mode == widget.initialMode);
    }

    switch (_filter) {
      case _NotebookFilter.learned:
        list = list.where((w) => w.learned);
        break;
      case _NotebookFilter.review:
        list = list.where((w) => !w.learned);
        break;
      case _NotebookFilter.all:
        break;
    }

    if (_query.isNotEmpty) {
      list = list.where((w) =>
          w.word.toLowerCase().contains(_query) ||
          w.meaning.toLowerCase().contains(_query));
    }

    return list.toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'popped':
        return const Color(0xFF34D399);
      case 'missed':
        return const Color(0xFFF87171);
      case 'synonym':
        return const Color(0xFFFBBF24);
      default:
        return kPurpleLight;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'popped':
        return 'Popped ✅';
      case 'missed':
        return 'Missed ❌';
      case 'synonym':
        return 'Synonym ⭐';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = _filteredWords;

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        backgroundColor: kBgDark,
        elevation: 0,
        title: const Text('📓 Vocabulary Notebook',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search words or meanings...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: kBgCard,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterChip('All', _NotebookFilter.all),
                  const SizedBox(width: 8),
                  _filterChip('Learned', _NotebookFilter.learned),
                  const SizedBox(width: 8),
                  _filterChip('Review', _NotebookFilter.review),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(child: _buildBody(words)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, _NotebookFilter value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: kPurplePrimary,
      backgroundColor: kBgCard,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: kPurplePrimary.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildBody(List<WordNote> words) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: kPurpleAccent));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextButton(
                onPressed: _loadWords,
                child:
                    const Text('Retry', style: TextStyle(color: kPurpleLight))),
          ],
        ),
      );
    }
    if (words.isEmpty) {
      return const Center(
        child: Text(
          'No words here yet.\nPlay a round to start filling your notebook!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      color: kPurpleAccent,
      backgroundColor: kBgCard,
      onRefresh: _loadWords,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: words.length,
        itemBuilder: (context, index) => _wordCard(words[index]),
      ),
    );
  }

  Widget _wordCard(WordNote note) {
    final color = _statusColor(note.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(note.word,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.6)),
                      ),
                      child: Text(_statusLabel(note.status),
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                if (note.pronunciation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('/${note.pronunciation}/',
                      style: const TextStyle(
                          color: kPurpleLight,
                          fontSize: 13,
                          fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 6),
                Text(note.meaning,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: kPurpleLight),
                onPressed: () => _speak(note.word),
                tooltip: 'Pronounce',
              ),
              IconButton(
                icon: Icon(
                  note.learned
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color:
                      note.learned ? const Color(0xFF34D399) : Colors.white38,
                ),
                onPressed: () => _toggleLearned(note),
                tooltip: note.learned ? 'Learned' : 'Mark as learned',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
