import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/story_provider.dart';
import 'screens/story_screen.dart';

void main() {
  runApp(const PebloApp());
}

class PebloApp extends StatelessWidget {
  const PebloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: MaterialApp(
        title: 'Peblo Story Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF8E7CFF),
        ),
        home: const StoryScreen(),
      ),
    );
  }
}
