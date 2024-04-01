import 'package:flutter/material.dart';

class HoldDownAnimatedButton extends StatefulWidget {
  const HoldDownAnimatedButton({
    required this.child,
    required this.onPressed,
    required this.height,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double height;
  final Duration duration;

  @override
  State<HoldDownAnimatedButton> createState() => _HoldDownAnimatedButtonState();
}

const borderRadius = BorderRadius.all(Radius.circular(24));

class _HoldDownAnimatedButtonState extends State<HoldDownAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration ~/ 2,
    );
    _progressController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          widget.onPressed();
          _scaleController.reverse();
          _progressController.reverse(from: 0);
        }
      },
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) {
          _scaleController.forward();
          _progressController.forward();
        },
        onTapUp: (_) {
          _scaleController.reverse();
          _progressController.reverse();
        },
        child: SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ScaleTransition(
                scale: Tween<double>(begin: 1, end: 0.8).animate(
                  CurvedAnimation(
                    parent: _scaleController,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, snapshot) {
                    return Center(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          borderRadius: borderRadius,
                          gradient: LinearGradient(
                            colors: [
                              Colors.black54,
                              Colors.black87,
                              Colors.black,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16,
                              ),
                              child: widget.child,
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: constraints.maxWidth * _progressController.value,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
