import 'package:flutter/material.dart';
import 'dart:math';

class AudioWaveform extends StatefulWidget {
  final bool isPlaying;
  final Color color;

  const AudioWaveform({
    super.key,
    required this.isPlaying,
    this.color = const Color(0xFFEE6983),
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(10, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Create a random-looking but smooth wave using sine
              // Offset creates the "wave" motion
              final t = _controller.value * 2 * pi;
              final offset = index * 0.5;
              final wave = 0.5 + 0.5 * (
                // Combine two sine waves for variety
                0.7 * (widget.isPlaying ? sin(t + offset) : 0) // Stop motion if paused
              ).abs();

              final height = 10.0 + (30.0 * wave);

              return Container(
                width: 4,
                height: widget.isPlaying ? height : 5, // Collapse to dots when stopped
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
