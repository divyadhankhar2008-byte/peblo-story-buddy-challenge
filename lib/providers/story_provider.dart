import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';

enum StoryState { idle, loading, playing, finished, error }

enum QuizState { hidden, shown, wrongAnswer, correctAnswer }

class StoryProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  StoryState _storyState = StoryState.idle;
  QuizState _quizState = QuizState.hidden;
  QuizModel? _currentQuiz;
  String _errorMessage = '';

  // Getters
  StoryState get storyState => _storyState;
  QuizState get quizState => _quizState;
  QuizModel? get currentQuiz => _currentQuiz;
  String get errorMessage => _errorMessage;

  StoryProvider() {
    _initTts();
    // Initialize with sample quiz
    _currentQuiz = QuizModel.fromJson(sampleQuizJson);
  }

  void _initTts() {
    _flutterTts.setCompletionHandler(() {
      _onTtsComplete();
    });

    _flutterTts.setErrorHandler((message) {
      _onTtsError(message.toString());
    });

    // Configure TTS settings
    _flutterTts.setSpeechRate(0.7);
    _flutterTts.setPitch(1.0);
  }

  Future<void> readStory(String storyText) async {
    _storyState = StoryState.loading;
    _quizState = QuizState.hidden;
    _errorMessage = '';
    notifyListeners();

    try {
      await _flutterTts.speak(storyText);
      _storyState = StoryState.playing;
      notifyListeners();
    } catch (e) {
      _onTtsError('Failed to start narration: $e');
    }
  }

  void _onTtsComplete() {
    _storyState = StoryState.finished;
    _quizState = QuizState.shown;
    notifyListeners();
  }

  void _onTtsError(String message) {
    _storyState = StoryState.error;
    _quizState = QuizState.hidden;
    _errorMessage = message;
    notifyListeners();
  }

  void recordAnswer(String selectedOption) {
    if (_currentQuiz == null) return;

    if (selectedOption == _currentQuiz!.answer) {
      _quizState = QuizState.correctAnswer;
    } else {
      _quizState = QuizState.wrongAnswer;
    }
    notifyListeners();
  }

  void resetQuiz() {
    _quizState = QuizState.hidden;
    _storyState = StoryState.idle;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> stopReading() async {
    await _flutterTts.stop();
    _storyState = StoryState.idle;
    _quizState = QuizState.hidden;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
