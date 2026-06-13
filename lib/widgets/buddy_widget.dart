import 'package:flutter/material.dart';

class BuddyCharacter extends StatefulWidget {
  final bool isSpeaking;

  const BuddyCharacter({
    super.key,
    this.isSpeaking = false,
  });

  @override
  State<BuddyCharacter> createState() => _BuddyCharacterState();
}

class _BuddyCharacterState extends State<BuddyCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.isSpeaking) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BuddyCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isSpeaking && _animationController.isAnimating) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animationController.value * 8 - 4),
          child: child,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Buddy head
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF8E7CFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E7CFF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Eyes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                // Mouth (animates when speaking)
                Positioned(
                  bottom: 30,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final mouthHeight = widget.isSpeaking ? 12 + (_animationController.value * 4) : 4;
                      return Container(
                        width: 30,
                        height: mouthHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Character name
          const Text(
            'Buddy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8E7CFF),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
