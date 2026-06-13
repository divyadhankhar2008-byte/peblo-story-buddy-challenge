import 'package:flutter/material.dart';

/// Pip the robot buddy, drawn with simple shapes so no image asset is
/// needed. Three moods, each driven by a single AnimationController to
/// keep this cheap to run on low-end devices (no per-frame rebuild of
/// anything outside this widget).
enum BuddyMood { idle, speaking, happy }

class BuddyCharacter extends StatefulWidget {
  final BuddyMood mood;
  const BuddyCharacter({super.key, required this.mood});

  @override
  State<BuddyCharacter> createState() => _BuddyCharacterState();
}

class _BuddyCharacterState extends State<BuddyCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value; // 0..1

        // Gentle bob for idle/happy, faster jiggle while speaking.
        final bob = widget.mood == BuddyMood.speaking
            ? (t - 0.5).abs() * -10
            : (t - 0.5).abs() * -6;

        final eyeHeight = widget.mood == BuddyMood.speaking
            ? 10.0
            : (t > 0.95 ? 2.0 : 10.0); // quick blink near top of cycle

        return Transform.translate(
          offset: Offset(0, bob),
          child: _buildBody(eyeHeight),
        );
      },
    );
  }

  Widget _buildBody(double eyeHeight) {
    final bodyColor = switch (widget.mood) {
      BuddyMood.happy => const Color(0xFFFFC94A), // sunny yellow
      BuddyMood.speaking => const Color(0xFF6FCBE0), // bright sky blue
      BuddyMood.idle => const Color(0xFF8E7CFF), // playful purple
    };

    return SizedBox(
      width: 140,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Antenna
          Positioned(
            top: 0,
            child: Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            top: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Head
          Positioned(
            top: 16,
            child: Container(
              width: 120,
              height: 110,
              decoration: BoxDecoration(
                color: bodyColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Eyes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _eye(eyeHeight),
                      const SizedBox(width: 18),
                      _eye(eyeHeight),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Mouth - changes with mood
                  _mouth(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye(double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 14,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }

  Widget _mouth() {
    switch (widget.mood) {
      case BuddyMood.happy:
        return Container(
          width: 46,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(23),
              bottomRight: Radius.circular(23),
            ),
          ),
        );
      case BuddyMood.speaking:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final h = 8 + (_controller.value * 14);
            return Container(
              width: 30,
              height: h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        );
      case BuddyMood.idle:
        return Container(
          width: 34,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        );
    }
  }
}
