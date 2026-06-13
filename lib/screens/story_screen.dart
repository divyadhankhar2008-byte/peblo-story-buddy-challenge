import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/story_provider.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/quiz_widget.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late ConfettiController _confettiController;

  final String sampleStory = """
  Once upon a time, in a magical forest filled with ancient trees and shimmering streams,
  there lived a brave young adventurer named Alex. One misty morning, Alex discovered
  a mysterious map hidden beneath the roots of an old oak tree. The map showed a path
  to a hidden treasure guarded by a wise dragon. Without hesitation, Alex set off on
  an incredible journey through enchanted valleys and across crystal bridges.
  
  Along the way, Alex met a clever fox who became a loyal friend. Together, they faced
  many challenges and dangers, but with courage and determination, they finally reached
  the dragon's lair. Instead of fighting, Alex spoke kindly to the dragon and discovered
  that it was lonely and had been guarding the treasure for centuries, hoping someone
  would understand its loneliness. Alex learned that true treasure isn't gold or jewels,
  but the friendships we make and the kindness we share with others.
  """;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple[50]!,
                  Colors.blue[50]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Consumer<StoryProvider>(
                builder: (context, storyProvider, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header
                        const Text(
                          'Peblo Story Buddy',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E7CFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Listen to amazing stories and take fun quizzes!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Buddy Character
                        BuddyCharacter(
                          isSpeaking: storyProvider.storyState == StoryState.playing,
                        ),
                        const SizedBox(height: 40),

                        // Status indicator
                        _buildStatusIndicator(storyProvider),
                        const SizedBox(height: 40),

                        // Main content based on state
                        if (storyProvider.storyState == StoryState.idle)
                          _buildIdleState(storyProvider)
                        else if (storyProvider.storyState == StoryState.loading)
                          _buildLoadingState()
                        else if (storyProvider.storyState == StoryState.playing)
                          _buildPlayingState()
                        else if (storyProvider.storyState == StoryState.finished)
                          _buildFinishedState(storyProvider)
                        else if (storyProvider.storyState == StoryState.error)
                          _buildErrorState(storyProvider),

                        const SizedBox(height: 30),

                        // Quiz
                        if (storyProvider.quizState != QuizState.hidden &&
                            storyProvider.currentQuiz != null)
                          QuizCard(
                            quiz: storyProvider.currentQuiz!,
                            onAnswerSelected: (selectedOption) {
                              storyProvider.recordAnswer(selectedOption);
                              if (selectedOption == storyProvider.currentQuiz!.answer) {
                                _confettiController.play();
                              }
                            },
                            showCorrect: storyProvider.quizState == QuizState.correctAnswer,
                            showWrong: storyProvider.quizState == QuizState.wrongAnswer,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 24,
              gravity: 0.05,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(StoryProvider provider) {
    String status = '';
    IconData icon = Icons.info_outline;

    switch (provider.storyState) {
      case StoryState.idle:
        return const SizedBox.shrink();
      case StoryState.loading:
        status = 'Buddy is getting ready...';
        icon = Icons.hourglass_empty;
      case StoryState.playing:
        status = 'Buddy is reading the story...';
        icon = Icons.volume_up;
      case StoryState.finished:
        status = 'Story finished!';
        icon = Icons.check_circle;
      case StoryState.error:
        status = 'Oops! Something went wrong';
        icon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF8E7CFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8E7CFF).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF8E7CFF), size: 18),
          const SizedBox(width: 8),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFF8E7CFF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState(StoryProvider provider) {
    return Column(
      children: [
        const Text(
          'Ready for a story?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => provider.readStory(sampleStory),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E7CFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Read Me a Story',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E7CFF)),
            strokeWidth: 3,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Loading story...',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPlayingState() {
    return const Column(
      children: [
        Text(
          '🎧 Listening...',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFinishedState(StoryProvider provider) {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Story completed! Take the quiz above.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: provider.resetQuiz,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8E7CFF),
            side: const BorderSide(color: Color(0xFF8E7CFF)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Try Another Story'),
        ),
      ],
    );
  }

  Widget _buildErrorState(StoryProvider provider) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(
          'Buddy couldn\'t find his voice. Let\'s try again!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          provider.errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            provider.resetQuiz();
            provider.readStory(sampleStory);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}
