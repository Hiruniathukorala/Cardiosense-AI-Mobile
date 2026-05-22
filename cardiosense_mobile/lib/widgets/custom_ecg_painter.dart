import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomEcgPainter extends CustomPainter {
  final String status; // 'Normal', 'Abnormal', 'Critical', 'Pending'
  final double animationValue; // For micro-animations

  CustomEcgPainter({required this.status, this.animationValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw ECG Millimeter Grid Paper background
    final Paint gridThinPaint = Paint()
      ..color = const Color(0xFFFFECEB)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final Paint gridThickPaint = Paint()
      ..color = const Color(0xFFFFC5C2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw grid columns
    double xStep = 10.0; // 1mm thin lines
    for (double x = 0; x < size.width; x += xStep) {
      bool isThick = (x / xStep).round() % 5 == 0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), isThick ? gridThickPaint : gridThinPaint);
    }

    // Draw grid rows
    double yStep = 10.0;
    for (double y = 0; y < size.height; y += yStep) {
      bool isThick = (y / yStep).round() % 5 == 0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), isThick ? gridThickPaint : gridThinPaint);
    }

    // 2. Draw ECG Tracing Wave
    final Paint wavePaint = Paint()
      ..color = _getWaveColor(status)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final Path wavePath = Path();
    final double midY = size.height / 2;
    wavePath.moveTo(0, midY);

    if (status == 'Abnormal' || status == 'Critical') {
      // Draw Atrial Fibrillation (erratic baseline, irregular QRS peaks, tachycardic rhythm)
      _drawAtrialFibrillation(wavePath, size.width, midY);
    } else {
      // Draw standard beautiful Normal Sinus Rhythm (P wave, QRS complex, T wave, rhythmic intervals)
      _drawNormalSinusRhythm(wavePath, size.width, midY);
    }

    canvas.drawPath(wavePath, wavePaint);
  }

  Color _getWaveColor(String status) {
    switch (status) {
      case 'Normal':
        return const Color(0xFF10B981); // Success Mint Green
      case 'Abnormal':
        return const Color(0xFFF59E0B); // Amber Warning
      case 'Critical':
        return const Color(0xFFEF4444); // Medical Red
      default:
        return const Color(0xFF0A66C2); // CardioSense Medical Blue
    }
  }

  void _drawNormalSinusRhythm(Path path, double width, double midY) {
    // Normal sinus beat interval sequence
    double x = 0;

    while (x < width) {
      // Isoelectric baseline before P-wave
      path.lineTo(x + 20, midY);
      x += 20;

      // P Wave: gentle small curve up
      path.quadraticBezierTo(x + 10, midY - 10, x + 20, midY);
      x += 20;

      // PR segment (baseline)
      path.lineTo(x + 15, midY);
      x += 15;

      // QRS Complex
      // Q Wave: quick dip down
      path.lineTo(x + 5, midY + 8);
      // R Wave: high peak up
      path.lineTo(x + 12, midY - 45);
      // S Wave: deep plunge down
      path.lineTo(x + 20, midY + 50);
      // Back to baseline
      path.lineTo(x + 25, midY);
      x += 25;

      // ST Segment (baseline)
      path.lineTo(x + 15, midY);
      x += 15;

      // T Wave: moderate smooth curve up
      path.quadraticBezierTo(x + 15, midY - 22, x + 30, midY);
      x += 30;

      // TP Segment (baseline before next beat)
      path.lineTo(x + 35, midY);
      x += 35;
    }
  }

  void _drawAtrialFibrillation(Path path, double width, double midY) {
    double x = 0;
    final random = math.Random(42); // Seeded to stay consistent

    while (x < width) {
      // Fibrillatory 'f' waves: noisy baseline
      for (int i = 0; i < 5; i++) {
        double baselineNoise = (random.nextDouble() - 0.5) * 8.0;
        path.lineTo(x + 6, midY + baselineNoise);
        x += 6;
      }

      // Irregular, rapid QRS beats
      // Q Wave
      path.lineTo(x + 4, midY + (random.nextDouble() * 5 + 4));
      // R Wave (tall, varying heights)
      double rHeight = 35.0 + random.nextDouble() * 20.0;
      path.lineTo(x + 8, midY - rHeight);
      // S Wave (deep, varying depths)
      double sDepth = 40.0 + random.nextDouble() * 15.0;
      path.lineTo(x + 14, midY + sDepth);
      // Return
      path.lineTo(x + 18, midY);
      x += 18;

      // ST segment noise
      for (int i = 0; i < 4; i++) {
        double baselineNoise = (random.nextDouble() - 0.5) * 6.0;
        path.lineTo(x + 6, midY + baselineNoise);
        x += 6;
      }

      // Shorter, highly variable R-R intervals
      double variableRest = 15.0 + random.nextDouble() * 30.0;
      for (double r = 0; r < variableRest; r += 5) {
        double noise = (random.nextDouble() - 0.5) * 5.0;
        path.lineTo(x + 5, midY + noise);
        x += 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomEcgPainter oldDelegate) {
    return oldDelegate.status != status || oldDelegate.animationValue != animationValue;
  }
}
