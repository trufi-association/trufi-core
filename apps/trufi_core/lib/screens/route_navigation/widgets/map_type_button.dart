import 'package:flutter/material.dart';

class MapTypeButton extends StatelessWidget {
  final int currentMapIndex;
  final List<MapTypeOption> mapOptions;
  final ValueChanged<int> onMapTypeChanged;

  const MapTypeButton({
    super.key,
    required this.currentMapIndex,
    required this.mapOptions,
    required this.onMapTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: 'Cambiar tipo de mapa',
        child: IconButton(
          iconSize: 24,
          icon: const Icon(
            Icons.layers,
            color: Colors.blueAccent,
          ),
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(
              Colors.white,
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.all(12),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapTypeSettingsScreen(
                  currentMapIndex: currentMapIndex,
                  mapOptions: mapOptions,
                  onMapTypeChanged: onMapTypeChanged,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MapTypeOption {
  final String id;
  final String name;
  final String description;
  final Widget? previewImage;

  MapTypeOption({
    required this.id,
    required this.name,
    required this.description,
    this.previewImage,
  });
}

class MapTypeSettingsScreen extends StatefulWidget {
  final int currentMapIndex;
  final List<MapTypeOption> mapOptions;
  final ValueChanged<int> onMapTypeChanged;

  const MapTypeSettingsScreen({
    super.key,
    required this.currentMapIndex,
    required this.mapOptions,
    required this.onMapTypeChanged,
  });

  @override
  State<MapTypeSettingsScreen> createState() => _MapTypeSettingsScreenState();
}

class _MapTypeSettingsScreenState extends State<MapTypeSettingsScreen> {
  late int selectedMapIndex;

  @override
  void initState() {
    super.initState();
    selectedMapIndex = widget.currentMapIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Mapa'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tipo de Mapa',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.mapOptions.length,
                itemBuilder: (context, index) {
                  final option = widget.mapOptions[index];
                  final isSelected = selectedMapIndex == index;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedMapIndex = index;
                        });
                        widget.onMapTypeChanged(index);
                        
                        // Show a snackbar confirming the change
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mapa cambiado a: ${option.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Preview image or placeholder
                            if (option.previewImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: option.previewImage,
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.map,
                                  size: 40,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            const SizedBox(width: 16),
                            // Map info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 32,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: theme.colorScheme.outlineVariant,
                                size: 32,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Aplicar Cambios'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
