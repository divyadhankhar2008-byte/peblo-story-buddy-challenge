class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class Quiz {
  final String storyId;
  final List<QuizQuestion> questions;
  int currentQuestionIndex;
  int score;

  Quiz({
    required this.storyId,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
  });

  bool get isComplete => currentQuestionIndex >= questions.length;

  void answerQuestion(int selectedIndex) {
    if (currentQuestionIndex < questions.length) {
      if (selectedIndex == questions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      }
      currentQuestionIndex++;
    }
  }

  void reset() {
    currentQuestionIndex = 0;
    score = 0;
  }
}
