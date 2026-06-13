import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/story_provider.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/quiz_widget.dart';

// Peblo-inspired brand palette (from the provided wireframe):
// playful purple, sunny yellow, sky blue, soft cream background.
class PebloColors {
  static const purple = Color(0xFF8E7CFF);
  static const yellow = Color(0xFFFFC94A);
  static const blue = Color(0xFF6FCBE0);
  static const cream = Color(0xFFFFF8EC);
}

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();

    // Fire confetti exactly once when the answer becomes correct.
    if (provider.quizState == QuizState.correctAnswer &&
        _confettiController.state == ConfettiControllerState.stopped) {
      _confettiController.play();
    }

    return Scaffold(
      backgroundColor: PebloColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  BuddyCharacter(mood: _moodFor(provider)),
                  const SizedBox(height: 20),
                  _buildStoryCard(provider),
                  const SizedBox(height: 20),
                  _buildActionArea(context, provider),
                  const SizedBox(height: 20),
                  if (provider.quizState != QuizState.hidden)
                    const QuizCard(),
                  if (provider.quizState == QuizState.correctAnswer)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: _buildRestartButton(provider),
                    ),
                ],
              ),
            ),
            // Confetti bursts from the top center.
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 24,
                gravity: 0.3,
                colors: const [
                  PebloColors.purple,
                  PebloColors.yellow,
                  PebloColors.blue,
                  Colors.pinkAccent,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BuddyMood _moodFor(StoryProvider provider) {
    if (provider.quizState == QuizState.correctAnswer) return BuddyMood.happy;
    if (provider.storyState == StoryState.playing) return BuddyMood.speaking;
    return BuddyMood.idle;
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: PebloColors.purple.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_stories_rounded,
              color: PebloColors.purple, size: 28),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Pip's Story Time",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(StoryProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PebloColors.blue.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        storyText,
        style: const TextStyle(
          fontSize: 17,
          height: 1.5,
          color: Color(0xFF444444),
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, StoryProvider provider) {
    switch (provider.storyState) {
      case StoryState.idle:
      case StoryState.finished:
        return _readButton(context, provider, "🔊 Read Me a Story");

      case StoryState.loading:
        return _statusPill(
          icon: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          label: "Buddy is getting ready...",
          color: PebloColors.blue,
        );

      case StoryState.playing:
        return _statusPill(
          icon: const Icon(Icons.volume_up_rounded,
              color: PebloColors.purple),
          label: "Buddy is reading the story...",
          color: PebloColors.purple,
        );

      case StoryState.error:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      provider.errorMessage ??
                          "Something went wrong. Let's try again!",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _readButton(context, provider, "🔁 Try Again"),
          ],
        );
    }
  }

  Widget _readButton(
      BuildContext context, StoryProvider provider, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.playStory,
        style: ElevatedButton.styleFrom(
          backgroundColor: PebloColors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _statusPill(
      {required Widget icon, required String label, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestartButton(StoryProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _confettiController.stop();
          provider.restart();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: PebloColors.purple,
          side: const BorderSide(color: PebloColors.purple, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Play Again",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
