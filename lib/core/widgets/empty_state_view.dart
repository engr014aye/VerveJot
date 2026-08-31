import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EmptyStateView extends StatefulWidget {
  final IconData? icon;
  final String? title;
  final String? subtitle;

  const EmptyStateView({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  });

  @override
  State<EmptyStateView> createState() => _EmptyStateViewState();
}

class _EmptyStateViewState extends State<EmptyStateView>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _searchController;

  late final Animation<double> _entranceSlide;
  late final Animation<double> _entranceUnfold;
  late final Animation<double> _entranceOpacity;

  Timer? _initTimer;
  bool _isEntranceStarted = false;

  @override
  void initState() {
    super.initState();

    // 1. ONE-TIME ENTRANCE CONTROLLER
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    // Smooth entrance downward movement with subtle, elegant settling
    _entranceSlide = Tween<double>(begin: -140.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Cubic(0.16, 1.0, 0.3, 1.0), // Smooth custom ease-out with gentle settling
      ),
    );

    // Progressive top-to-bottom unfold / reveal
    _entranceUnfold = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Initial opacity fade in
    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. CONTINUOUS ORGANIC SEARCHING LOOP CONTROLLER
    _searchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          _searchController.repeat();
        }
      }
    });

    // Start with a brief empty screen delay (200ms) before the entrance begins
    _initTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isEntranceStarted = true;
        });
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    _entranceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Completely empty initially until the entrance triggers
    if (!_isEntranceStarted) {
      return const SizedBox.shrink();
    }

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _searchController]),
        builder: (context, child) {
          return Opacity(
            opacity: _entranceOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _entranceSlide.value),
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _entranceUnfold.value.clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: const Size(240, 220),
                    painter: _TargetEmptyStatePainter(
                      isDark: isDark,
                      accentColor: AppColors.primary,
                      searchProgress: _searchController.value,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TargetEmptyStatePainter extends CustomPainter {
  final bool isDark;
  final Color accentColor;
  final double searchProgress;

  _TargetEmptyStatePainter({
    required this.isDark,
    required this.accentColor,
    required this.searchProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ==========================================
    // 1. SOFT GREY ORGANIC BACKDROP (STATIONARY)
    // ==========================================
    final blobPaint = Paint()
      ..color = isDark ? const Color(0xFF232328) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final blobPath = Path()
      ..moveTo(center.dx - 70, center.dy - 45)
      ..cubicTo(center.dx - 105, center.dy - 10, center.dx - 90, center.dy + 55, center.dx - 20, center.dy + 70)
      ..cubicTo(center.dx + 45, center.dy + 85, center.dx + 105, center.dy + 55, center.dx + 90, center.dy - 5)
      ..cubicTo(center.dx + 85, center.dy - 55, center.dx + 10, center.dy - 80, center.dx - 70, center.dy - 45)
      ..close();

    canvas.drawPath(blobPath, blobPaint);

    // ==========================================
    // 2. SUBTLE DECORATIVE SPARKLES & MARKS
    // ==========================================
    final t = searchProgress * 2 * math.pi;
    final sparklePulse1 = (math.sin(t) * 0.2 + 0.8).clamp(0.0, 1.0);
    final sparklePulse2 = (math.cos(t) * 0.2 + 0.8).clamp(0.0, 1.0);

    final sparklePaint1 = Paint()
      ..color = (isDark ? const Color(0xFF3F3F46) : const Color(0xFFCBD5E1)).withValues(alpha: sparklePulse1)
      ..style = PaintingStyle.fill;

    final sparklePaint2 = Paint()
      ..color = (isDark ? const Color(0xFF3F3F46) : const Color(0xFFCBD5E1)).withValues(alpha: sparklePulse2)
      ..style = PaintingStyle.fill;

    // Small decorative circles
    canvas.drawCircle(Offset(center.dx + 78, center.dy - 38), 3.5, sparklePaint1);
    canvas.drawCircle(Offset(center.dx - 82, center.dy + 42), 3.0, sparklePaint2);
    canvas.drawCircle(Offset(center.dx + 65, center.dy + 62), 2.2, sparklePaint1);

    // Tiny decorative plus mark
    final crossPaint = Paint()
      ..color = (isDark ? const Color(0xFF3F3F46) : const Color(0xFFCBD5E1)).withValues(alpha: sparklePulse2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    final crossX = center.dx - 72;
    final crossY = center.dy - 20;
    canvas.drawLine(Offset(crossX - 3.5, crossY), Offset(crossX + 3.5, crossY), crossPaint);
    canvas.drawLine(Offset(crossX, crossY - 3.5), Offset(crossX, crossY + 3.5), crossPaint);

    // ==========================================
    // 3. CLEAN NOTEPAD DOCUMENT (STATIONARY)
    // ==========================================
    final docLeft = center.dx - 52;
    final docTop = center.dy - 65;
    final docWidth = 98.0;
    final docHeight = 120.0;

    final paperPaint = Paint()
      ..color = isDark ? const Color(0xFF18181B) : Colors.white
      ..style = PaintingStyle.fill;

    final paperStroke = Paint()
      ..color = isDark ? const Color(0xFF3F3F46) : const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final paperPath = Path()
      ..moveTo(docLeft + 16, docTop)
      ..lineTo(docLeft + docWidth - 16, docTop)
      ..quadraticBezierTo(docLeft + docWidth, docTop, docLeft + docWidth, docTop + 16)
      ..lineTo(docLeft + docWidth, docTop + docHeight - 16)
      ..quadraticBezierTo(docLeft + docWidth, docTop + docHeight, docLeft + docWidth - 16, docTop + docHeight)
      ..lineTo(docLeft + 16, docTop + docHeight)
      ..quadraticBezierTo(docLeft, docTop + docHeight, docLeft, docTop + docHeight - 16)
      ..lineTo(docLeft, docTop + 16)
      ..quadraticBezierTo(docLeft, docTop, docLeft + 16, docTop)
      ..close();

    canvas.drawPath(paperPath, paperPaint);
    canvas.drawPath(paperPath, paperStroke);

    // Document Content Lines
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFFE4E4E7) : const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.6;

    // Header & Content Lines
    canvas.drawLine(Offset(docLeft + 18, docTop + 26), Offset(docLeft + docWidth - 18, docTop + 26), linePaint);
    canvas.drawLine(Offset(docLeft + 18, docTop + 48), Offset(docLeft + docWidth - 34, docTop + 48), linePaint);
    canvas.drawLine(Offset(docLeft + 18, docTop + 70), Offset(docLeft + docWidth - 22, docTop + 70), linePaint);
    canvas.drawLine(Offset(docLeft + 18, docTop + 92), Offset(docLeft + docWidth - 40, docTop + 92), linePaint);

    // ==========================================
    // 4. ORGANIC MAGNIFYING GLASS SEARCH PATH
    // ==========================================
    // Evaluate smooth curved coordinates, micro-rotations, and search/X state
    final searchMetrics = _evaluateSearchPath(searchProgress);

    final magCenterX = center.dx + searchMetrics.x;
    final magCenterY = center.dy + searchMetrics.y;
    final magAngle = searchMetrics.angle;
    final crossWeight = searchMetrics.crossWeight; // 0.0 = searching state, 1.0 = X state

    final magRadius = 26.0;

    canvas.save();
    canvas.translate(magCenterX, magCenterY);
    canvas.rotate(magAngle);

    // Lens Interior (Soft Glass Refraction)
    final lensPaint = Paint()
      ..color = (isDark ? const Color(0xFF27272A) : Colors.white).withValues(alpha: 0.94)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, magRadius, lensPaint);

    // Lens Outer Rim
    final rimPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8;

    canvas.drawCircle(Offset.zero, magRadius, rimPaint);

    // Handle
    final handleAngle = math.pi / 4; // 45 degrees
    final handleStartX = math.cos(handleAngle) * (magRadius + 1);
    final handleStartY = math.sin(handleAngle) * (magRadius + 1);
    final handleEndX = handleStartX + math.cos(handleAngle) * 20;
    final handleEndY = handleStartY + math.sin(handleAngle) * 20;

    final handlePaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.5;

    canvas.drawLine(Offset(handleStartX, handleStartY), Offset(handleEndX, handleEndY), handlePaint);

    // State A: Subtle search reflection / scanning line inside lens (when cross is fading out)
    if (crossWeight < 0.95) {
      final searchAlpha = ((1.0 - crossWeight) * 0.7).clamp(0.0, 1.0);
      final searchLinePaint = Paint()
        ..color = (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF94A3B8)).withValues(alpha: searchAlpha)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;

      canvas.drawLine(const Offset(-10, -6), const Offset(8, -6), searchLinePaint);
      canvas.drawLine(const Offset(-6, 2), const Offset(10, 2), searchLinePaint);
    }

    // State B: "X" (No Result / Not Found) Symbol inside lens (smoothly transitions in and out)
    if (crossWeight > 0.05) {
      final crossSize = 8.5 * crossWeight;
      final crossAlpha = crossWeight.clamp(0.0, 1.0);

      final crossPaint = Paint()
        ..color = (isDark ? Colors.white : const Color(0xFF0F172A)).withValues(alpha: crossAlpha)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.2;

      canvas.drawLine(Offset(-crossSize, -crossSize), Offset(crossSize, crossSize), crossPaint);
      canvas.drawLine(Offset(crossSize, -crossSize), Offset(-crossSize, crossSize), crossPaint);
    }

    canvas.restore();
  }

  /// Calculates a smooth, multi-point curved organic searching trajectory.
  _SearchMetrics _evaluateSearchPath(double p) {
    // Multi-waypoint organic search cycle:
    // Waypoints: (x, y, angle, crossWeight)
    final waypoints = [
      _SearchPoint(0.00, -18.0, -22.0, -0.07, 0.0), // Top-left scanning
      _SearchPoint(0.22, 16.0, -16.0, 0.06, 0.0),   // Top-right scanning
      _SearchPoint(0.42, 14.0, 14.0, 0.08, 0.1),    // Middle-right searching
      _SearchPoint(0.58, -14.0, 18.0, -0.05, 0.6),  // Bottom-left searching, 'X' begins
      _SearchPoint(0.72, 0.0, 0.0, 0.0, 1.0),       // Center pause: 'X' (No result found)
      _SearchPoint(0.86, -12.0, -10.0, -0.06, 0.2), // Resuming scan, 'X' fades
      _SearchPoint(1.00, -18.0, -22.0, -0.07, 0.0), // Seamless loop back to start
    ];

    for (int i = 0; i < waypoints.length - 1; i++) {
      final p1 = waypoints[i];
      final p2 = waypoints[i + 1];

      if (p >= p1.t && p <= p2.t) {
        final localT = (p - p1.t) / (p2.t - p1.t);
        // Smooth Hermite / Cubic interpolation
        final smoothT = localT * localT * (3 - 2 * localT);

        final x = p1.x + (p2.x - p1.x) * smoothT;
        final y = p1.y + (p2.y - p1.y) * smoothT;
        final angle = p1.angle + (p2.angle - p1.angle) * smoothT;
        final crossWeight = p1.cross + (p2.cross - p1.cross) * smoothT;

        return _SearchMetrics(x, y, angle, crossWeight);
      }
    }

    return _SearchMetrics(-18.0, -22.0, -0.07, 0.0);
  }

  @override
  bool shouldRepaint(covariant _TargetEmptyStatePainter oldDelegate) {
    return oldDelegate.searchProgress != searchProgress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.accentColor != accentColor;
  }
}

class _SearchPoint {
  final double t;
  final double x;
  final double y;
  final double angle;
  final double cross;

  _SearchPoint(this.t, this.x, this.y, this.angle, this.cross);
}

class _SearchMetrics {
  final double x;
  final double y;
  final double angle;
  final double crossWeight;

  _SearchMetrics(this.x, this.y, this.angle, this.crossWeight);
}
