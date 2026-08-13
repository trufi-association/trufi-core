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

  /// Dimmed fill — an unselected option. The text keeps full opacity.
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

  /// White or near-black, whichever contrasts more (WCAG ratio) with
  /// [fill] — luminance thresholds pick the wrong side in the 0.18–0.5
  /// band.
  static Color bestContrastOn(Color fill) {
    final l = fill.computeLuminance();
    final whiteRatio = 1.05 / (l + 0.05);
    final blackRatio = (l + 0.05) / 0.05;
    return whiteRatio >= blackRatio ? Colors.white : Colors.black87;
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
    final fill = segment.dimmed
        ? Color.alphaBlend(segment.color.withValues(alpha: 0.45), backdrop)
        : segment.color;
    final textColor = bestContrastOn(fill);

    return ClipPath(
      clipper: _SlantEdgeClipper(
        slantLeading: slantLeading,
        slantTrailing: slantTrailing,
        slant: slant,
      ),
      child: Semantics(
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
      ),
    );
  }
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

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
