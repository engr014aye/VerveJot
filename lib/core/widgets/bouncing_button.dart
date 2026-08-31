import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/spring_curves.dart';

class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double shrinkScale;
  final bool enableAudio;
  final bool enableHaptic;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  const BouncingButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.shrinkScale = 0.95,
    this.enableAudio = true,
    this.enableHaptic = true,
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.tapPress,
      reverseDuration: AppDurations.tapRebound,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.shrinkScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: SpringCurve.snappy,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
    if (widget.enableAudio || widget.enableHaptic) {
      AudioService().playTap(haptic: widget.enableHaptic);
    }
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.child,
    );

    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress != null
          ? () {
              if (widget.enableHaptic) {
                AudioService().playTap(haptic: true);
              }
              widget.onLongPress?.call();
            }
          : null,
      child: content,
    );
  }
}
