import 'package:flutter/material.dart';

class AnimatedValueText extends StatefulWidget {
  final String value;
  final TextStyle style;
  final Color flashColor;
  final double flashOpacity;
  final Duration duration;

  const AnimatedValueText({
    super.key,
    required this.value,
    required this.style,
    this.flashColor = Colors.orange,
    this.flashOpacity = 0.7,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<AnimatedValueText> createState() => _AnimatedValueTextState();
}

class _AnimatedValueTextState extends State<AnimatedValueText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _previousValue;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _previousValue = widget.value;
    // Start with animation completed
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedValueText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFirstBuild && widget.value != _previousValue) {
      _controller.reset();
      _controller.forward();
    }
    _isFirstBuild = false;
    _previousValue = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _isFirstBuild 
                ? Colors.transparent 
                : widget.flashColor.withOpacity(_animation.value * widget.flashOpacity),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            widget.value,
            style: widget.style,
          ),
        );
      },
    );
  }
}