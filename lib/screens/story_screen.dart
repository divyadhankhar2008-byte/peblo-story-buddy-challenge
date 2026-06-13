import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/quiz_widget.dart';
import '../models/quiz_model.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late StoryProvider storyProvider;
  
  final String demoStory = 'Once upon a time, in a magical forest, '
      'there lived a curious little buddy who loved to explore and learn new things. '
      'Every day was an adventure filled with wonder and excitement. '
      'The buddy made many friends and together they discovered the secrets of the forest.';

  @override
  void initState() {
    super.initState();
    storyProvider = context.read<StoryProvider>();
    storyProvider.setStory(demoStory);
    _createSampleQuiz();
  }

  void _createSampleQuiz() {
    final quiz = Quiz(
      storyId: 'story_1',
      questions: [
        QuizQuestion(
          question: 'Where did the story take place?',
          options: ['Magical forest', 'Dark castle', 'Sunny beach', 'Mountain peak'],
          correctAnswerIndex: 0,
          explanation: 'The story begins with "in a magical forest".',
        ),
        QuizQuestion(
          question: 'What did the buddy love to do?',
          options: ['Sleep', 'Explore and learn', 'Swim', 'Climb'],
          correctAnswerIndex: 1,
          explanation: 'The buddy loved to explore and learn new things.',
        ),
      ],
    );
    storyProvider.setQuiz(quiz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Buddy Challenge'),
        elevation: 0,
      ),
      body: Consumer<StoryProvider>(
        builder: (context, provider, child) {
          if (provider.currentQuiz?.isComplete ?? false) {
            return _buildQuizComplete(context, provider);
          }
          
          if (provider.currentQuiz != null) {
            return QuizWidget(quiz: provider.currentQuiz!);
          }
          
          return _buildStoryView(context, provider);
        },
      ),
    );
  }

  Widget _buildStoryView(BuildContext context, StoryProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const BuddyWidget(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                provider.currentStory,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => provider.playStory(),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Play Story'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => provider.stopStory(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
                const SizedBox(height: 20),
                if (provider.currentQuiz != null)
                  ElevatedButton(
                    onPressed: () => provider.currentQuiz!.reset(),
                    child: const Text('Start Quiz'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuizComplete(BuildContext context, StoryProvider provider) {
    final score = provider.currentQuiz?.score ?? 0;
    final total = provider.currentQuiz?.questions.length ?? 0;
    
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
            'Score: $score/$total',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              provider.currentQuiz?.reset();
              provider.setQuiz(provider.currentQuiz!);
            },
            child: const Text('Retake Quiz'),
          ),
        ],
      ),
    );
  }
}
