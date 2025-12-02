import 'package:flutter/material.dart';

import '../main.dart';

class LayerInfo {
  final String id;
  final String name;
  final IconData icon;
  final bool visible;

  const LayerInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.visible,
  });
}

class GridConfig {
  final bool showGrid;
  final int granularityLevels;

  const GridConfig({
    this.showGrid = false,
    this.granularityLevels = 0,
  });
}

class MapControls extends StatelessWidget {
  final MapRenderType currentRender;
  final void Function(MapRenderType) onRenderChanged;
  final List<LayerInfo> layers;
  final void Function(String layerId, bool visible) onLayerToggle;
  final GridConfig gridConfig;
  final void Function(bool showGrid) onGridToggle;
  final void Function(int level) onGranularityChanged;

  const MapControls({
    super.key,
    required this.currentRender,
    required this.onRenderChanged,
    required this.layers,
    required this.onLayerToggle,
    required this.gridConfig,
    required this.onGridToggle,
    required this.onGranularityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              // Map Render Section
              _buildSection(
                icon: Icons.layers_outlined,
                title: 'Map',
                child: _SegmentedControl(
                  items: [
                    _SegmentItem(
                      label: 'OSM',
                      isSelected: currentRender == MapRenderType.flutterMap,
                      onTap: () => onRenderChanged(MapRenderType.flutterMap),
                    ),
                    _SegmentItem(
                      label: 'Vector',
                      isSelected: currentRender == MapRenderType.mapLibre,
                      onTap: () => onRenderChanged(MapRenderType.mapLibre),
                    ),
                  ],
                ),
              ),

              // Layers Section
              _buildSection(
                icon: Icons.visibility_outlined,
                title: 'Layers',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: layers
                      .map(
                        (layer) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _LayerChip(
                            layer: layer,
                            onToggle: () =>
                                onLayerToggle(layer.id, !layer.visible),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              // Grid Section
              _buildSection(
                icon: Icons.grid_4x4_outlined,
                title: 'Grid',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GridToggle(
                      isEnabled: gridConfig.showGrid,
                      onToggle: () => onGridToggle(!gridConfig.showGrid),
                    ),
                    const SizedBox(width: 12),
                    Opacity(
                      opacity: gridConfig.showGrid ? 1.0 : 0.4,
                      child: IgnorePointer(
                        ignoring: !gridConfig.showGrid,
                        child: _GranularityStepper(
                          value: gridConfig.granularityLevels,
                          onChanged: onGranularityChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SegmentItem {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
}

class _SegmentedControl extends StatelessWidget {
  final List<_SegmentItem> items;

  const _SegmentedControl({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return GestureDetector(
            onTap: item.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: item.isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: item.isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      item.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: item.isSelected
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  final LayerInfo layer;
  final VoidCallback onToggle;

  const _LayerChip({
    required this.layer,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: layer.visible ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  layer.visible ? Colors.blue.shade200 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                layer.icon,
                size: 16,
                color:
                    layer.visible ? Colors.blue.shade700 : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                layer.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: layer.visible ? FontWeight.w600 : FontWeight.w500,
                  color: layer.visible
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridToggle extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;

  const _GridToggle({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.red.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEnabled ? Colors.red.shade200 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.grid_on_rounded,
                size: 16,
                color: isEnabled ? Colors.red.shade700 : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                isEnabled ? 'On' : 'Off',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                  color: isEnabled ? Colors.red.shade700 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GranularityStepper extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const _GranularityStepper({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: value > -3 ? () => onChanged(value - 1) : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: value < 5 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
      ),
    );
  }
}

class MapActionButtons extends StatelessWidget {
  final VoidCallback onFitToPoints;
  final VoidCallback onResetCamera;
  final bool showRecenter;
  final VoidCallback? onRecenter;

  const MapActionButtons({
    super.key,
    required this.onFitToPoints,
    required this.onResetCamera,
    this.showRecenter = false,
    this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.crop_free_rounded,
            tooltip: 'Fit to all points',
            onPressed: onFitToPoints,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.my_location_rounded,
            tooltip: 'Reset camera',
            onPressed: onResetCamera,
          ),
          if (showRecenter && onRecenter != null) ...[
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.center_focus_strong_rounded,
              tooltip: 'Re-center',
              onPressed: onRecenter!,
              highlighted: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool highlighted;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? Colors.blue : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: highlighted ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
