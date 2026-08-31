import 'dart:math' as math;
import 'package:flutter/animation.dart';

/// Damped harmonic oscillator spring curve implementation for high-fidelity UI motion.
class SpringCurve extends Curve {
  final double damping; // damping ratio (zeta)
  final double stiffness; // natural frequency (omega0)
  final double mass;

  const SpringCurve({
    this.damping = 15.0,
    this.stiffness = 180.0,
    this.mass = 1.0,
  });

  /// Snappy bounce curve for button presses and dialogs
  static const SpringCurve snappy = SpringCurve(
    damping: 14.0,
    stiffness: 220.0,
    mass: 1.0,
  );

  /// Gentle organic bounce for bottom sheets and drawer reveals
  static const SpringCurve gentle = SpringCurve(
    damping: 18.0,
    stiffness: 140.0,
    mass: 1.0,
  );

  /// Bouncy overshoot for checkmarks and completion indicators
  static const SpringCurve bouncy = SpringCurve(
    damping: 10.0,
    stiffness: 160.0,
    mass: 1.0,
  );

  @override
  double transformInternal(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;

    final double w0 = math.sqrt(stiffness / mass);
    final double zeta = damping / (2.0 * math.sqrt(stiffness * mass));

    if (zeta < 1.0) {
      // Underdamped system
      final double wd = w0 * math.sqrt(1.0 - zeta * zeta);
      final double envelope = math.exp(-zeta * w0 * t);
      final double oscillation = math.cos(wd * t) + ((zeta * w0) / wd) * math.sin(wd * t);
      return 1.0 - envelope * oscillation;
    } else if (zeta == 1.0) {
      // Critically damped
      return 1.0 - math.exp(-w0 * t) * (1.0 + w0 * t);
    } else {
      // Overdamped
      final double r1 = -w0 * (zeta - math.sqrt(zeta * zeta - 1.0));
      final double r2 = -w0 * (zeta + math.sqrt(zeta * zeta - 1.0));
      final double c2 = r1 / (r1 - r2);
      final double c1 = 1.0 - c2;
      return 1.0 - (c1 * math.exp(r1 * t) + c2 * math.exp(r2 * t));
    }
  }
}

class AppDurations {
  AppDurations._();

  static const Duration tapPress = Duration(milliseconds: 100);
  static const Duration tapRebound = Duration(milliseconds: 250);
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration sheet = Duration(milliseconds: 380);
  static const Duration transition = Duration(milliseconds: 280);
}
