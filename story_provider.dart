import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';

/// All the states the "Read Me a Story" flow can be in.
/// Keeping this explicit (rather than scattered booleans) makes the
/// audio -> quiz transition easy to reason about and test.
enum StoryState {
  idle, // before user taps the button
  loading, // TTS engine preparing / fetching audio
  playing, // narration in progress
  error, // TTS failed - show retry
  finished, // narration done -> quiz should appear
}

enum QuizState {
  hidden,
  shown,
  wrongAnswer, // triggers shake animation, then back to shown
  correctAnswer, // triggers confetti + success UI
}

const String storyText =
    "Once upon a time, a clever little robot named Pip lost his shiny "
    "blue gear in the Whispering Woods...";

class StoryProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  StoryState storyState = StoryState.idle;
  QuizState quizState = QuizState.hidden;

  // The quiz is built purely from this JSON - swap it for a network
  // response and nothing else in the UI needs to change.
  late QuizModel quiz;

  String? selectedOption;
  String? errorMessage;

  StoryProvider() {
    quiz = QuizModel.fromJson(sampleQuizJson);
    _initTts();
  }

  void _initTts() {
    // Sensible defaults for a kid-friendly narrator voice.
    _tts.setSpeechRate(0.42);
    _tts.setPitch(1.05);
    _tts.setVolume(1.0);

    // Fires when narration completes naturally -> reveal the quiz.
    _tts.setCompletionHandler(() {
      storyState = StoryState.finished;
      quizState = QuizState.shown;
      notifyListeners();
    });

    // Fires on TTS engine errors (no network for remote engines,
    // missing voice data, etc). We surface a friendly retry instead
    // of letting the app hang.
    _tts.setErrorHandler((msg) {
      storyState = StoryState.error;
      errorMessage = "Hmm, Buddy couldn't find his voice. Let's try again!";
      notifyListeners();
    });
  }

  /// Called when the user taps "Read Me a Story".
  Future<void> playStory() async {
    // Reset quiz in case this is a retry after a previous attempt.
    quizState = QuizState.hidden;
    selectedOption = null;
    storyState = StoryState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      // A tiny artificial delay so the "preparing" state is visible
      // even on fast devices/emulators - mirrors a real network
      // fetch (e.g. ElevenLabs) and gives kids a moment of
      // anticipation ("Buddy is getting ready...").
      await Future.delayed(const Duration(milliseconds: 400));

      storyState = StoryState.playing;
      notifyListeners();

      final result = await _tts.speak(storyText);

      // flutter_tts returns 1 on success queuing the utterance.
      // 0/negative usually means the platform engine rejected it
      // (e.g. no TTS voices installed) - treat as an error so the
      // user gets a retry instead of a silent hang.
      if (result != 1) {
        storyState = StoryState.error;
        errorMessage = "Buddy's voice isn't working right now.";
        notifyListeners();
      }
    } catch (e) {
      storyState = StoryState.error;
      errorMessage = "Something went wrong. Let's try again!";
      notifyListeners();
    }
  }

  /// Called when the child taps an answer option.
  void selectAnswer(String option) {
    selectedOption = option;
    if (quiz.isCorrect(option)) {
      quizState = QuizState.correctAnswer;
    } else {
      quizState = QuizState.wrongAnswer;
    }
    notifyListeners();
  }

  /// After the shake animation finishes for a wrong answer, go back
  /// to "shown" so the child can try again.
  void resetAfterWrongAnswer() {
    if (quizState == QuizState.wrongAnswer) {
      quizState = QuizState.shown;
      selectedOption = null;
      notifyListeners();
    }
  }

  /// Reset everything so the child can replay the whole experience.
  void restart() {
    storyState = StoryState.idle;
    quizState = QuizState.hidden;
    selectedOption = null;
    errorMessage = null;
    _tts.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
