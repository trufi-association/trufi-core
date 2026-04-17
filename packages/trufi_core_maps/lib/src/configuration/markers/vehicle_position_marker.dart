import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Live vehicle marker: a circular badge with an upright bus icon plus a small
/// rotating arrow that indicates heading.
///
/// Keeping the bus icon upright (and rotating only the arrow) ensures the
/// icon is always readable regardless of direction of travel.
class VehiclePositionMarker extends StatelessWidget {
  const VehiclePositionMarker({
    super.key,
    this.color = const Color(0xFF1E88E5),
    this.size = 28,
    this.heading = 0,
    this.icon = Icons.directions_bus_rounded,
  });

  final Color color;
  final double size;
  final double heading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final total = size * 1.55;
    final arrowSize = size * 0.55;
    final arrowOffset = size * 0.5;

    return SizedBox(
      width: total,
      height: total,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Transform.rotate(
            angle: heading * math.pi / 180,
            child: Transform.translate(
              offset: Offset(0, -arrowOffset),
              child: _HeadingChevron(size: arrowSize, color: color),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: size * 0.6,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadingChevron extends StatelessWidget {
  const _HeadingChevron({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ChevronPainter(color: color),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter old) => old.color != color;
}
