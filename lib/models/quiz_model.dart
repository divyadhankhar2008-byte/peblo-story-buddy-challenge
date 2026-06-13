/// Data-driven Quiz model.
/// Mirrors the JSON shape Peblo's backend would send:
/// {
///   "question": "...",
///   "options": ["A", "B", "C", ...],   // any length: 2, 3, 4, 5, ...
///   "answer": "B"
/// }
///
/// The renderer (QuizCard) never assumes a fixed option count -
/// it just maps over `options`.
class QuizModel {
  final String question;
  final List<String> options;
  final String answer;

  QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
    );
  }

  bool isCorrect(String selected) => selected == answer;
}

/// Sample data simulating what Peblo's backend sends.
/// Swap this for a real API call (e.g. http.get) - the rest of the
/// app does not need to change because rendering is data-driven.
const Map<String, dynamic> sampleQuizJson = {
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue",
};

/// A second sample with a DIFFERENT option count (5) and different text,
/// to demonstrate the renderer handles it without any code changes.
/// Try swapping `sampleQuizJson` for this one in StoryProvider.
const Map<String, dynamic> alternateQuizJson = {
  "question": "Where did Pip lose his gear?",
  "options": [
    "The Whispering Woods",
    "A castle",
    "The ocean",
    "A volcano",
    "Outer space",
  ],
  "answer": "The Whispering Woods",
};
