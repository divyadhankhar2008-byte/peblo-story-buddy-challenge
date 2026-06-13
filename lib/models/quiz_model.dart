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

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }
}

// Sample quiz JSON data
const Map<String, dynamic> sampleQuizJson = {
  'question': 'What was the main character\'s greatest fear?',
  'options': ['Heights', 'Water', 'Darkness', 'Failure'],
  'answer': 'Failure',
};

// Alternate quiz with 5 options to demonstrate flexible rendering
const Map<String, dynamic> alternateQuizJson = {
  'question': 'Which lesson did the character learn by the end?',
  'options': ['Courage comes in many forms', 'Trust your instincts', 'Teamwork matters', 'Never give up', 'Ask for help'],
  'answer': 'Trust your instincts',
};