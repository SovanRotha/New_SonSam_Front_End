import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 1;
    final strokeWidth = size.shortestSide * 0.22;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final segments = [
      (const Color(0xFF4285F4), -45.0, 105.0),
      (const Color(0xFF34A853), 60.0, 75.0),
      (const Color(0xFFFBBC05), 135.0, 75.0),
      (const Color(0xFFEA4335), 210.0, 105.0),
    ];

    for (final (color, startAngle, sweepAngle) in segments) {
      strokePaint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle * 3.14159265359 / 180,
        sweepAngle * 3.14159265359 / 180,
        false,
        strokePaint,
      );
    }

    strokePaint
      ..color = const Color(0xFF4285F4)
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width - 1, center.dy),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}