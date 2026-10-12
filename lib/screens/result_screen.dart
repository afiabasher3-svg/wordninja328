import 'package:flutter/material.dart';
import '../models/word_note.dart';
import '../widgets/gradient_button.dart';
import 'mode_selection_screen.dart';
import 'home_screen.dart';
import 'word_notes_screen.dart';

const Color kBgDark = Color(0xFF0A0A14);
const Color kBgCard = Color(0xFF1A1A2E);
const Color kPurplePrimary = Color(0xFF7C3AED);
const Color kPurpleAccent = Color(0xFF9D5CF6);
const Color kPurpleLight = Color(0xFFC084FC);

class ResultScreen extends StatelessWidget {
  final String topicEmoji;
  final String topicName;
  final int topicId;
  final String mode;
  final int finalScore;
  final double accuracy;
  final double wpm;
  final int levelReached;
  final int wordsPopped;
  final int wordsMissed;
  final int synonymsCompleted;
  final Duration timePlayed;
  final List<WordNote> sessionWords;

  const ResultScreen({
    super.key,
    required this.topicEmoji,
    required this.topicName,
    required this.topicId,
    required this.mode,
    required this.finalScore,
    required this.accuracy,
    required this.wpm,
    required this.levelReached,
    required this.wordsPopped,
    required this.wordsMissed,
    required this.synonymsCompleted,
    required this.timePlayed,
    this.sessionWords = const [],
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Text(topicEmoji, style: const TextStyle(fontSize: 56)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(topicName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  mode == 'advanced' ? '🔴 Advanced Mode' : '🟢 Easy Mode',
                  style: const TextStyle(
                      color: kPurpleLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              _buildScoreHero(),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 28),

              // Play Again
              GradientButton(
                label: 'Play Again 🎮',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ModeSelectionScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Review Words
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: kPurpleAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordNotesScreen(
                        initialTopicId: topicId,
                        initialMode: mode,
                      ),
                    ),
                  );
                },
                child: const Text('📓 Review Words',
                    style: TextStyle(
                        color: kPurpleLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),

              // Home
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('🏠 Home',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPurplePrimary, kPurpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kPurplePrimary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          const Text('FINAL SCORE',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text('$finalScore',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatItem('Accuracy', '${accuracy.toStringAsFixed(0)}%', Icons.gps_fixed),
      _StatItem('WPM', '${wpm.toStringAsFixed(0)}', Icons.speed),
      _StatItem('Level Reached', '$levelReached', Icons.stairs),
      _StatItem(
          'Time Played', _formatDuration(timePlayed), Icons.timer_outlined),
      _StatItem('Words Popped', '$wordsPopped', Icons.check_circle_outline),
      _StatItem('Words Missed', '$wordsMissed', Icons.cancel_outlined),
      _StatItem('Synonyms', '$synonymsCompleted', Icons.auto_awesome),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final s = stats[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPurplePrimary.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(s.icon, color: kPurpleLight, size: 15),
              const SizedBox(height: 3),
              Text(s.value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              Text(s.label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  _StatItem(this.label, this.value, this.icon);
}
