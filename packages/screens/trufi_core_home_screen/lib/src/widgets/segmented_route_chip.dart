import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// One segment of a [SegmentedRouteChip].
class RouteSegmentSpec {
  const RouteSegmentSpec({
    required this.label,
    required this.color,
    this.icon,
    this.trailing,
    this.dimmed = false,
    this.onTap,
    this.key,
    this.selected = false,
  });

  final String label;

  /// The segment's own route color.
  final Color color;

  /// Leading icon (the mode icon on the journey's first segment).
  final IconData? icon;

  /// Small trailing text (a departure time acting as tiebreaker).
  final String? trailing;

  /// An unselected option: keeps its route color, only slightly muted
  /// into the backdrop (Sam 2026-08-13: "que se mantengan los colores").
  /// The text keeps full opacity.
  final bool dimmed;

  final VoidCallback? onTap;
  final Key? key;
  final bool selected;
}

/// A single chip whose segments meet on thin slanted "/" seams — the
/// grouped-routes visual of the itinerary card, reusable interactively
/// (the detail's option switcher renders the same chip with tappable,
/// dimmable segments so both screens speak one language).
///
/// The segments overlap by `slant - seamWidth` (custom row render object),
/// which decouples the seam's thickness from its angle — clipping alone
/// couples them (parallel edges in a flush row leave a background sliver
/// exactly `slant` wide).
///
/// Layout contract: the chip wants unbounded horizontal room (both strips
/// mount it inside a horizontal [SingleChildScrollView]) — segments never
/// shrink, so a tight width overflows the segments' internal rows and
/// clips whatever doesn't fit. Seams always run "/" (LTR); the app ships
/// LTR locales only.
class SegmentedRouteChip extends StatelessWidget {
  const SegmentedRouteChip({
    super.key,
    required this.segments,
    this.slant = 7,
    this.seamWidth = 1.8,
    this.borderRadius = 8,
    this.dimBackdrop,
  });

  final List<RouteSegmentSpec> segments;

  /// Horizontal run of the diagonal seam.
  final double slant;

  /// Visible thickness of the seam (the backdrop showing through).
  final double seamWidth;

  final double borderRadius;

  /// What dimmed fills blend into (the strip behind the chip) — used both
  /// for the effective fill and for its text contrast.
  final Color? dimBackdrop;

  /// The ink for text sitting on [fill]. The app's badge language is
  /// white-on-color (the map's route badges, Sam 2026-08-13: nothing black
  /// on the unselected options) — so white wins whenever it clears WCAG
  /// large-text AA (3:1), and near-black takes over only on fills too
  /// light for white to stay readable.
  static Color bestContrastOn(Color fill) {
    final l = fill.computeLuminance();
    final whiteRatio = 1.05 / (l + 0.05);
    return whiteRatio >= 3.0 ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final backdrop =
        dimBackdrop ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _OverlapRow(
        overlap: math.max(0, slant - seamWidth),
        children: [
          for (final (i, segment) in segments.indexed)
            _buildSegment(
              segment,
              slantLeading: i > 0,
              slantTrailing: i < segments.length - 1,
              backdrop: backdrop,
            ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    RouteSegmentSpec segment, {
    required bool slantLeading,
    required bool slantTrailing,
    required Color backdrop,
  }) {
    // Every segment wears its route color; unselected ones are only
    // slightly muted (keeping their identity), and the selected one is
    // marked by an inset ring instead of by dimming the others out.
    final fill = segment.dimmed
        ? Color.alphaBlend(segment.color.withValues(alpha: 0.82), backdrop)
        : segment.color;
    final textColor = bestContrastOn(fill);

    return ClipPath(
      clipper: _SlantEdgeClipper(
        slantLeading: slantLeading,
        slantTrailing: slantTrailing,
        slant: slant,
      ),
      child: CustomPaint(
        foregroundPainter: segment.selected
            ? _SlantRingPainter(
                slantLeading: slantLeading,
                slantTrailing: slantTrailing,
                slant: slant,
                color: textColor,
                strokeWidth: 1.8,
                inset: 2.6,
              )
            : null,
        child: _segmentBody(
          segment,
          fill: fill,
          textColor: textColor,
          slantLeading: slantLeading,
          slantTrailing: slantTrailing,
        ),
      ),
    );
  }

  Widget _segmentBody(
    RouteSegmentSpec segment, {
    required Color fill,
    required Color textColor,
    required bool slantLeading,
    required bool slantTrailing,
  }) {
    return Semantics(
      button: segment.onTap != null,
      selected: segment.selected,
      child: Material(
        color: fill,
        child: InkWell(
          key: segment.key,
          onTap: segment.onTap,
          child: Padding(
            padding: EdgeInsets.only(
              left: 8 + (slantLeading ? slant : 0),
              right: 8 + (slantTrailing ? slant : 0),
              top: 5,
              bottom: 5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (segment.icon != null) ...[
                  Icon(segment.icon, size: 15, color: textColor),
                  if (segment.label.isNotEmpty) const SizedBox(width: 4),
                ],
                if (segment.label.isNotEmpty)
                  Text(
                    segment.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                if (segment.trailing != null) ...[
                  if (segment.label.isNotEmpty || segment.icon != null)
                    const SizedBox(width: 5),
                  Text(
                    segment.trailing!,
                    maxLines: 1,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints an inset outline parallel to the segment's parallelogram — the
/// selected option's highlight (the fills all keep their route colors, so
/// dimming can't mark the choice). Stroke color follows the same contrast
/// policy as the segment's text.
class _SlantRingPainter extends CustomPainter {
  const _SlantRingPainter({
    required this.slantLeading,
    required this.slantTrailing,
    required this.slant,
    required this.color,
    required this.strokeWidth,
    required this.inset,
  });

  final bool slantLeading;
  final bool slantTrailing;
  final double slant;
  final Color color;
  final double strokeWidth;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    if (h <= 0 || size.width <= 0) return;
    final leadingSlant = slantLeading ? slant : 0.0;
    final trailingSlant = slantTrailing ? slant : 0.0;
    // Horizontal inset that keeps a slanted edge parallel at distance
    // [inset]: the edge is longer than the height by sec(angle).
    double edgeShift(double edgeSlant) =>
        inset * math.sqrt(edgeSlant * edgeSlant + h * h) / h;
    final dxL = edgeShift(leadingSlant);
    final dxR = edgeShift(trailingSlant);
    final top = inset;
    final bottom = h - inset;
    // Left edge runs (0,h)→(leadingSlant,0); right edge (w,0)→(w−trailingSlant,h).
    double leftX(double y) => leadingSlant * (1 - y / h);
    double rightX(double y) => size.width - trailingSlant * (y / h);

    final path = Path()
      ..moveTo(leftX(top) + dxL, top)
      ..lineTo(rightX(top) - dxR, top)
      ..lineTo(rightX(bottom) - dxR, bottom)
      ..lineTo(leftX(bottom) + dxL, bottom)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SlantRingPainter oldDelegate) =>
      oldDelegate.slantLeading != slantLeading ||
      oldDelegate.slantTrailing != slantTrailing ||
      oldDelegate.slant != slant ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.inset != inset;
}

/// Clips a segment into a parallelogram whose slanted edges run "/" —
/// adjacent segments overlap, so the backdrop sliver between their
/// parallel edges is the seam.
class _SlantEdgeClipper extends CustomClipper<Path> {
  const _SlantEdgeClipper({
    required this.slantLeading,
    required this.slantTrailing,
    required this.slant,
  });

  final bool slantLeading;
  final bool slantTrailing;
  final double slant;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(slantLeading ? slant : 0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - (slantTrailing ? slant : 0), size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_SlantEdgeClipper oldClipper) =>
      oldClipper.slantLeading != slantLeading ||
      oldClipper.slantTrailing != slantTrailing ||
      oldClipper.slant != slant;
}

/// A row that overlaps consecutive children by [overlap] logical pixels
/// (later children paint over earlier ones). Children stay real widgets —
/// texts remain findable and InkWells tappable, which a CustomPainter
/// rendering could not offer.
class _OverlapRow extends MultiChildRenderObjectWidget {
  const _OverlapRow({required this.overlap, required super.children});

  final double overlap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderOverlapRow(overlap: overlap);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderOverlapRow renderObject,
  ) {
    renderObject.overlap = overlap;
  }
}

class _OverlapRowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderOverlapRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverlapRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverlapRowParentData> {
  _RenderOverlapRow({required double overlap}) : _overlap = overlap;

  double _overlap;
  double get overlap => _overlap;
  set overlap(double value) {
    if (_overlap == value) return;
    _overlap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverlapRowParentData) {
      child.parentData = _OverlapRowParentData();
    }
  }

  @override
  void performLayout() {
    final childConstraints = constraints.loosen();
    var maxHeight = 0.0;
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      maxHeight = math.max(maxHeight, child.size.height);
      child = (child.parentData! as _OverlapRowParentData).nextSibling;
    }

    var x = 0.0;
    child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _OverlapRowParentData;
      parentData.offset = Offset(x, (maxHeight - child.size.height) / 2);
      x += child.size.width - _overlap;
      child = parentData.nextSibling;
    }
    // The last child contributes its full width.
    final totalWidth = childCount == 0 ? 0.0 : x + _overlap;
    size = constraints.constrain(Size(totalWidth, maxHeight));
  }

  // Intrinsics and dry layout mirror performLayout — without them the chip
  // reports 0×0 to IntrinsicHeight/Width and Table and silently vanishes.
  // The width accumulation REPEATS performLayout's operation order
  // (x += w - overlap per child, one overlap back at the end) instead of
  // the algebraically equal sum-minus-(n-1)-overlaps: the two differ in
  // floating point and debugCheckIntrinsicSizes compares dry and real
  // layout bit-exactly.

  double _accumulateWidths(double Function(RenderBox child) widthOf) {
    var x = 0.0;
    var count = 0;
    var child = firstChild;
    while (child != null) {
      x += widthOf(child) - _overlap;
      count++;
      child = (child.parentData! as _OverlapRowParentData).nextSibling;
    }
    return count == 0 ? 0.0 : math.max(0, x + _overlap);
  }

  double _tallestChild(double Function(RenderBox child) heightOf) {
    var tallest = 0.0;
    var child = firstChild;
    while (child != null) {
      tallest = math.max(tallest, heightOf(child));
      child = (child.parentData! as _OverlapRowParentData).nextSibling;
    }
    return tallest;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _accumulateWidths((child) => child.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _accumulateWidths((child) => child.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _tallestChild((child) => child.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _tallestChild((child) => child.getMaxIntrinsicHeight(width));

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childConstraints = constraints.loosen();
    var maxHeight = 0.0;
    var x = 0.0;
    var count = 0;
    var child = firstChild;
    while (child != null) {
      final childSize = child.getDryLayout(childConstraints);
      maxHeight = math.max(maxHeight, childSize.height);
      x += childSize.width - _overlap;
      count++;
      child = (child.parentData! as _OverlapRowParentData).nextSibling;
    }
    final totalWidth = count == 0 ? 0.0 : x + _overlap;
    return constraints.constrain(Size(totalWidth, maxHeight));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
