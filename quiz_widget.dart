import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/story_provider.dart';

/// Renders a quiz purely from a [QuizModel]. It does not assume any
/// fixed number of options - `quiz.options.map(...)` handles 2, 3, 4,
/// 5+ options identically. Swapping `sampleQuizJson` for
/// `alternateQuizJson` (5 options, different question) requires zero
/// changes to this widget.
class QuizCard extends StatefulWidget {
  const QuizCard({super.key});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake(StoryProvider provider) {
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0).then((_) {
      provider.resetAfterWrongAnswer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final quiz = provider.quiz;

    // Kick off the shake animation as a side-effect of state changing
    // to wrongAnswer, without rebuilding the whole tree per frame.
    if (provider.quizState == QuizState.wrongAnswer &&
        !_shakeController.isAnimating &&
        _shakeController.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _triggerShake(provider);
      });
    }

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shakeOffset =
            _shakeOffset(_shakeController.value) * 12; // px
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz_rounded,
                    color: Color(0xFF8E7CFF), size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quiz.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Data-driven option list - works for any options.length.
            ...quiz.options.map((option) => _buildOption(provider, option)),
            if (provider.quizState == QuizState.correctAnswer)
              _buildSuccessBanner(),
          ],
        ),
      ),
    );
  }

  /// Decaying sine wave gives a quick "shake" that settles back to 0.
  double _shakeOffset(double t) {
    if (t <= 0 || t >= 1) return 0;
    final decay = 1 - t;
    return decay * decay * math.sin(t * 8 * math.pi);
  }

  Widget _buildOption(StoryProvider provider, String option) {
    final isSelected = provider.selectedOption == option;
    final isCorrectAnswer = option == provider.quiz.answer;
    final showResult = provider.quizState == QuizState.correctAnswer ||
        (provider.quizState == QuizState.wrongAnswer && isSelected);

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = const Color(0xFF333333);

    if (showResult) {
      if (provider.quizState == QuizState.correctAnswer && isCorrectAnswer) {
        bgColor = const Color(0xFFD7F7DD);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF2E7D32);
      } else if (provider.quizState == QuizState.wrongAnswer && isSelected) {
        bgColor = const Color(0xFFFFE1E1);
        borderColor = const Color(0xFFE57373);
        textColor = const Color(0xFFC62828);
      }
    }

    final tappable = provider.quizState == QuizState.shown;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: tappable ? () => provider.selectAnswer(option) : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              if (showResult)
                Icon(
                  (provider.quizState == QuizState.correctAnswer &&
                          isCorrectAnswer)
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: borderColor,
                  size: 22,
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBDBDBD)),
                  ),
                ),
              const SizedBox(width: 12),
              Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Text("🎉", style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Yay! You got it right!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB8860B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

