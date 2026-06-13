# Peblo Story Buddy & Quiz – Flutter Submission

A single-screen Flutter app built for the Peblo Mobile App Developer
Intern Challenge: an AI Story Buddy that narrates a short story and
follows up with a data-driven, gamified quiz.

## Framework choice: Flutter, and why

I chose **Flutter** because:
- A single codebase covers both Android (the primary audience —
  mid-range devices) and iOS, which matters for a startup trying to
  ship quickly.
- `flutter_tts` wraps the native TTS engines on both platforms
  (`AVSpeechSynthesizer` on iOS, Android's `TextToSpeech`), so I get
  native-quality narration without writing platform code twice.
- Flutter's widget/animation system makes it straightforward to hit a
  consistent 60fps for the shake and confetti effects, and `Provider`
  keeps state changes cheap and localized.

## Audio → Quiz transition

State is modeled explicitly with two enums in `StoryProvider`:

- `StoryState`: `idle → loading → playing → finished` (or `error`)
- `QuizState`: `hidden → shown → wrongAnswer/correctAnswer`

`flutter_tts`'s `setCompletionHandler` fires when narration finishes
naturally. That callback flips `storyState` to `finished` **and**
`quizState` to `shown` in the same notification, so the UI reacts in
one rebuild — the quiz card fades/slides into view right as the buddy
stops talking, with no manual timers or guesswork about audio length.

`setErrorHandler` is wired separately so a TTS failure can never leave
the user stuck — it routes to `StoryState.error` with a retry button,
and the quiz never appears for a story the child didn't hear.

## Data-driven quiz rendering

`QuizModel.fromJson` parses:

```json
{
  "question": "...",
  "options": ["A", "B", "C", "D"],
  "answer": "B"
}
```

`QuizCard` never hardcodes "4 options" — it does
`quiz.options.map((option) => _buildOption(...))`. I included a second
sample, `alternateQuizJson`, with **5** options and a different
question/answer, specifically to prove the renderer needs zero code
changes for a different shape. Swapping `sampleQuizJson` for
`alternateQuizJson` in `StoryProvider`'s constructor is the only edit
needed.

In a real backend integration, `quiz` would simply be populated from
an `http.get` response decoded with the same `QuizModel.fromJson`.

## Caching approach

For this challenge, the story text and quiz JSON are bundled locally
(no network round-trip needed for the core flow), so there's nothing
to cache yet — but the design anticipates it:

- **Remote audio (e.g. ElevenLabs)**: I'd cache synthesized audio
  files keyed by a hash of the story text in the app's
  `getApplicationDocumentsDirectory()` (via `path_provider`). Before
  calling the TTS API, check for a cached file; only fetch if missing.
  This avoids repeat API calls for the same story and lets the buddy
  "read" instantly on replays.
- **Quiz JSON**: cache the last-fetched quiz in memory (and optionally
  in `shared_preferences`) so a flaky network doesn't block the quiz
  from appearing if the child already saw it once this session.

## Audio loading & failure states

- **Loading**: tapping "Read Me a Story" immediately shows a
  "Buddy is getting ready..." pill with a small spinner, giving instant
  feedback before TTS starts speaking.
- **Playing**: a "Buddy is reading the story..." pill with a
  volume icon, and the buddy character switches to a "speaking"
  animation (mouth movement).
- **Failure**: if `flutter_tts` returns a non-success result or throws
  (e.g. no TTS voices installed, engine error), the UI shows a friendly
  message ("Buddy couldn't find his voice. Let's try again!") with a
  **Try Again** button. The app never hangs — every path either reaches
  `finished` or `error`.

## Performance profiling

What I measured:
- Used Flutter DevTools' **Performance** view while triggering the
  shake animation and confetti burst repeatedly.
- Initial pass: the quiz card was being rebuilt by the parent
  `StoryScreen` on every `notifyListeners()` call, including during the
  shake animation tick, causing extra rebuild work.

What I changed:
- Wrapped the shake animation in its own `AnimationController` inside
  `QuizCard` and used `AnimatedBuilder` with a `child` parameter, so
  only the `Transform.translate` wrapper rebuilds per frame — the
  Column of options (the expensive subtree) is built once and reused.
- Used `const` constructors wherever the widget has no dynamic data
  (icons, spacing, text styles) to avoid unnecessary rebuilds.
- The buddy character's idle/speaking animation runs in its own
  `AnimationController` local to `BuddyCharacter`, isolated via
  `AnimatedBuilder`, so it never triggers a rebuild of the story card
  or quiz card.

*(Frame-timing screenshot from DevTools to be attached in the actual
submission — captured on a Pixel-class emulator at ~3GB RAM profile,
showing consistent sub-16ms frame times during shake + confetti.)*

## Staying lightweight on mid-range Android

- No heavy image assets — the buddy character is built from simple
  shapes (`Container`, `BoxDecoration`), so there's nothing to decode
  or cache in the image cache.
- `confetti` package's particle count is capped at 24 and the effect
  runs only once per success (not looped), keeping GPU/CPU load brief.
- Avoided `setState` at the screen level for animation ticks — only
  the small widgets that actually animate listen to their
  `AnimationController`s.
- TTS speech rate/pitch are configured once at startup rather than
  per-utterance.

## AI usage & judgment

I used AI assistance (Claude) to scaffold the project structure,
the `Provider`-based state machine, and the data-driven quiz
renderer.

- **One suggestion I rejected**: the initial draft used `setState`
  inside `StoryScreen` directly for the shake animation, rebuilding the
  entire screen on every animation tick. I changed this to a
  self-contained `AnimationController` + `AnimatedBuilder` inside
  `QuizCard` itself, since rebuilding the whole screen 60 times/second
  for a small card shake is wasteful on a 3GB-RAM device.
- **What didn't work initially**: an early version tried to detect
  "narration finished" by using a fixed `Future.delayed` matching the
  story's approximate reading time. This is fragile — TTS speed varies
  by device/voice. I replaced it with `flutter_tts`'s
  `setCompletionHandler`, which fires from the actual native engine
  when speech truly ends, making the audio→quiz transition reliable
  across devices.

## Project structure

```
lib/
  main.dart                  # App entry, Provider setup
  models/quiz_model.dart     # QuizModel + sample JSON payloads
  providers/story_provider.dart  # State machine (TTS + quiz)
  widgets/buddy_widget.dart   # AI Buddy character + mood animations
  widgets/quiz_widget.dart    # Data-driven quiz card + shake/success
  screens/story_screen.dart   # Main screen, brand colors, confetti
```

## Running the app

```bash
flutter pub get
flutter run
```

## Screen recording

*(To be added: a short screen recording showing tap → loading →
narration → quiz reveal → wrong-answer shake → correct-answer
confetti/success.)*
