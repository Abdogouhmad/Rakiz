import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerControlUi extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;
  final VoidCallback onNext;

  const PlayerControlUi({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onReset,
    required this.onNext,
  });

  void _handlePress(VoidCallback action) {
    HapticFeedback.lightImpact();
    action();
  }

  @override
  Widget build(BuildContext context) {
    Color? fillButtonColor = isPlaying
        ? Colors.lightBlue[200]
        : Theme.of(context).colorScheme.onInverseSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _handlePress(onPlayPause),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isPlaying ? 140 : 115,
            height: 100,
            decoration: BoxDecoration(
              color: fillButtonColor,
              borderRadius: BorderRadius.circular(isPlaying ? 20 : 90),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: isPlaying
                    ? Icon(
                        Icons.pause,
                        size: 25,
                        key: const ValueKey('p1'),
                        color: Colors.grey[850],
                      )
                    : const Icon(
                        Icons.play_arrow,
                        size: 25,
                        key: ValueKey('p2'),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            minimumSize: const Size(102, 100),
            shape: const StadiumBorder(),
          ),
          onPressed: () => _handlePress(onReset),
          child: const Icon(Icons.replay, size: 25),
        ),
        // const SizedBox(width: 12),
        // FilledButton.tonal(
        //   style: FilledButton.styleFrom(
        //     minimumSize: const Size(20, 100),
        //     shape: const StadiumBorder(),
        //   ),
        //   onPressed: () => _handlePress(onNext),
        //   child: const Icon(Icons.skip_next, size: 25),
        // ),
      ],
    );
  }
}
