import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizCard extends StatefulWidget {
  final QuizModel quiz;
  final Function(String) onAnswerSelected;
  final bool showCorrect;
  final bool showWrong;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.onAnswerSelected,
    this.showCorrect = false,
    this.showWrong = false,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );

    if (widget.showWrong) {
      _triggerShake();
    }
  }

  void _triggerShake() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void didUpdateWidget(QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showWrong && !oldWidget.showWrong) {
      _triggerShake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: AnimatedOpacity(
        opacity: widget.showCorrect || widget.showWrong ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: widget.showCorrect ? Colors.green[50] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Time!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.quiz.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Options grid
                ...widget.quiz.options.map((option) {
                  final isSelected = _selectedOption == option;
                  final isCorrect = option == widget.quiz.answer;
                  final showResult = widget.showCorrect || widget.showWrong;

                  Color optionColor = Colors.white;
                  if (showResult && isCorrect) {
                    optionColor = Colors.green[100]!;
                  } else if (showResult && isSelected && !isCorrect) {
                    optionColor = Colors.red[100]!;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                      onTap: showResult
                          ? null
                          : () {
                              setState(() => _selectedOption = option);
                              widget.onAnswerSelected(option);
                            },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: optionColor,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF8E7CFF) : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (showResult && isCorrect)
                              const Icon(Icons.check_circle, color: Colors.green),
                            if (showResult && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // Feedback message
                if (widget.showCorrect)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Text(
                          'Correct! Great job!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.showWrong)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Try again!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}
