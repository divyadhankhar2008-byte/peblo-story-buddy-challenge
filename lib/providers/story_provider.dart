import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';

class StoryProvider with ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  
  String _currentStory = '';
  bool _isPlaying = false;
  Quiz? _currentQuiz;
  double _ttsSpeed = 0.5;
  
  String get currentStory => _currentStory;
  bool get isPlaying => _isPlaying;
  Quiz? get currentQuiz => _currentQuiz;
  double get ttsSpeed => _ttsSpeed;
  
  StoryProvider() {
    _initializeTts();
  }
  
  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(_ttsSpeed);
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }
  
  void setStory(String story) {
    _currentStory = story;
    notifyListeners();
  }
  
  Future<void> playStory() async {
    if (_currentStory.isEmpty) return;
    
    try {
      _isPlaying = true;
      notifyListeners();
      
      await _flutterTts.speak(_currentStory);
    } catch (e) {
      debugPrint('Error playing story: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }
  
  Future<void> stopStory() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping story: $e');
    }
  }
  
  Future<void> setTtsSpeed(double speed) async {
    try {
      _ttsSpeed = speed;
      await _flutterTts.setSpeechRate(speed);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting TTS speed: $e');
    }
  }
  
  void setQuiz(Quiz quiz) {
    _currentQuiz = quiz;
    notifyListeners();
  }
  
  void clearQuiz() {
    _currentQuiz = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
