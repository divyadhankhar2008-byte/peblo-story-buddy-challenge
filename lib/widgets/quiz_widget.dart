import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/quiz_model.dart';

class QuizWidget extends StatefulWidget {
  final Quiz quiz;

  const QuizWidget({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  late ConfettiController _confettiController;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleAnswerSelect(int index) {
    if (_answered) return;
    
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    final currentQuestion = widget.quiz.questions[widget.quiz.currentQuestionIndex];
    if (index == currentQuestion.correctAnswerIndex) {
      _confettiController.play();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.quiz.answerQuestion(index);
        setState(() {
          _selectedAnswer = null;
          _answered = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.isComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'Quiz Complete!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Score: ${widget.quiz.score}/${widget.quiz.questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    final currentQuestion = widget.quiz.questions[widget.quiz.currentQuestionIndex];

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (widget.quiz.currentQuestionIndex + 1) / widget.quiz.questions.length,
                ),
                const SizedBox(height: 20),
                Text(
                  'Question ${widget.quiz.currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Text(
                  currentQuestion.question,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ...List.generate(
                  currentQuestion.options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: _answered ? null : () => _handleAnswerSelect(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedAnswer == index
                            ? (index == currentQuestion.correctAnswerIndex
                                ? Colors.green
                                : Colors.red)
                            : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        currentQuestion.options[index],
                        style: TextStyle(
                          color: _selectedAnswer == index ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_answered && _selectedAnswer != currentQuestion.correctAnswerIndex)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Explanation: ${currentQuestion.explanation}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.97,
          ),
        ),
      ],
    );
  }
}
