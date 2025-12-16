import 'package:flutter/material.dart';

import '../layers/animated_markers_layer.dart';

/// Overlay widget showing real-time performance statistics
class PerformanceStatsOverlay extends StatelessWidget {
  final ValueNotifier<PerformanceStats> statsNotifier;
  final int lineCount;

  const PerformanceStatsOverlay({
    super.key,
    required this.statsNotifier,
    required this.lineCount,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PerformanceStats>(
      valueListenable: statsNotifier,
      builder: (context, stats, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.speed,
                    color: _getFpsColor(stats.fps),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${stats.fps.toStringAsFixed(0)} FPS',
                    style: TextStyle(
                      color: _getFpsColor(stats.fps),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _StatRow(
                label: 'Markers',
                value: '${stats.markerCount}',
                color: Colors.cyan,
              ),
              const SizedBox(height: 2),
              _StatRow(
                label: 'Lines',
                value: '$lineCount',
                color: Colors.amber,
              ),
              const SizedBox(height: 2),
              _StatRow(
                label: 'Frame',
                value: '${stats.frameTimeMs.toStringAsFixed(1)}ms',
                color: stats.frameTimeMs > 16 ? Colors.orange : Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.yellow;
    if (fps >= 15) return Colors.orange;
    return Colors.red;
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// Preset configuration
class Preset {
  final String name;
  final int markers;
  final int lines;
  final int fps;
  final Color color;

  const Preset({
    required this.name,
    required this.markers,
    required this.lines,
    required this.fps,
    required this.color,
  });

  static const List<Preset> all = [
    Preset(name: 'Light', markers: 50, lines: 10, fps: 30, color: Colors.green),
    Preset(name: 'Medium', markers: 200, lines: 50, fps: 30, color: Colors.blue),
    Preset(name: 'Heavy', markers: 500, lines: 100, fps: 30, color: Colors.orange),
    Preset(name: 'Stress', markers: 1000, lines: 200, fps: 60, color: Colors.red),
    Preset(name: 'Extreme', markers: 2000, lines: 500, fps: 60, color: Colors.purple),
  ];

  bool matches(int m, int l, int f) => markers == m && lines == l && fps == f;
}

/// Compact control panel with presets and start/stop control
class PerformanceControlPanel extends StatefulWidget {
  final int markerCount;
  final int lineCount;
  final int fps;
  final bool isAnimating;
  final bool hasData;
  final ValueChanged<int> onMarkerCountChanged;
  final ValueChanged<int> onLineCountChanged;
  final ValueChanged<int> onFpsChanged;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const PerformanceControlPanel({
    super.key,
    required this.markerCount,
    required this.lineCount,
    required this.fps,
    required this.isAnimating,
    required this.hasData,
    required this.onMarkerCountChanged,
    required this.onLineCountChanged,
    required this.onFpsChanged,
    required this.onStart,
    required this.onStop,
  });

  @override
  State<PerformanceControlPanel> createState() =>
      _PerformanceControlPanelState();
}

class _PerformanceControlPanelState extends State<PerformanceControlPanel> {
  Preset? get _activePreset {
    for (final preset in Preset.all) {
      if (preset.matches(widget.markerCount, widget.lineCount, widget.fps)) {
        return preset;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = _activePreset == null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Presets row (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Custom chip (opens dialog)
                _CustomChip(
                  isActive: isCustom && widget.hasData,
                  currentValues:
                      isCustom ? '${widget.markerCount}/${widget.lineCount}' : null,
                  onTap: () => _showCustomDialog(context),
                ),
                const SizedBox(width: 8),
                // Preset chips
                ...Preset.all.map((preset) {
                  final isActive = _activePreset == preset && widget.hasData;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _PresetChip(
                      preset: preset,
                      isActive: isActive,
                      onTap: () => _applyPreset(preset),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Stop button (only visible when running)
          if (widget.hasData)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onStop,
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCustomDialog(BuildContext context) {
    int tempMarkers = widget.markerCount;
    int tempLines = widget.lineCount;
    int tempFps = widget.fps;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.tune, color: Colors.blue),
              SizedBox(width: 8),
              Text('Custom Settings'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SliderRow(
                label: 'Markers',
                value: tempMarkers,
                min: 10,
                max: 3000,
                onChanged: (v) => setDialogState(() => tempMarkers = v),
              ),
              const SizedBox(height: 12),
              _SliderRow(
                label: 'Lines',
                value: tempLines,
                min: 5,
                max: 1000,
                onChanged: (v) => setDialogState(() => tempLines = v),
              ),
              const SizedBox(height: 12),
              _SliderRow(
                label: 'FPS',
                value: tempFps,
                min: 10,
                max: 60,
                onChanged: (v) => setDialogState(() => tempFps = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                widget.onMarkerCountChanged(tempMarkers);
                widget.onLineCountChanged(tempLines);
                widget.onFpsChanged(tempFps);
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onStart();
                });
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyPreset(Preset preset) {
    widget.onMarkerCountChanged(preset.markers);
    widget.onLineCountChanged(preset.lines);
    widget.onFpsChanged(preset.fps);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStart();
    });
  }
}

class _CustomChip extends StatelessWidget {
  final bool isActive;
  final String? currentValues;
  final VoidCallback onTap;

  const _CustomChip({
    required this.isActive,
    required this.currentValues,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.blueGrey : Colors.blueGrey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blueGrey.withValues(alpha: isActive ? 1 : 0.3),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 12,
                    color: isActive ? Colors.white : Colors.blueGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Custom',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              if (currentValues != null)
                Text(
                  currentValues!,
                  style: TextStyle(
                    fontSize: 9,
                    color: isActive ? Colors.white70 : Colors.blueGrey.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final Preset preset;
  final bool isActive;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? preset.color
                : preset.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: preset.color.withValues(alpha: isActive ? 1 : 0.3),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                preset.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : preset.color,
                ),
              ),
              Text(
                '${preset.markers} / ${preset.lines}',
                style: TextStyle(
                  fontSize: 9,
                  color: isActive
                      ? Colors.white70
                      : preset.color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final double min;
  final double max;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min,
              max: max,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
