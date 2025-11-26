import 'package:flutter/material.dart';

/// Resultado de la selección
class TicketSelectionResult {
  final String area;
  final String ticketType;
  final Map<String, int> quantities; // RiderType -> count
  final double total;

  const TicketSelectionResult({
    required this.area,
    required this.ticketType,
    required this.quantities,
    required this.total,
  });
}

/// POC de selector de pasajes (UI similar a la imagen)
class TicketSelector extends StatefulWidget {
  static Future<TicketSelectionResult?> show(BuildContext context) {
    return showDialog<TicketSelectionResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(width: 420, child: TicketSelector()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  const TicketSelector({super.key});

  @override
  State<TicketSelector> createState() => _TicketSelectorState();
}

class _TicketSelectorState extends State<TicketSelector> {
  // Datos de ejemplo (puedes cablearlos a tu backend más adelante)
  final List<String> areas = const [
    'Local Bus & LYNX',
    'Regional',
    'All Zones',
  ];
  final List<String> ticketTypes = const [
    'MONTHLY UNLIMITED',
    'WEEKLY',
    'DAY PASS',
  ];

  // Precios por tipo de pasajero
  final Map<String, double> prices = const {
    'Adult': 88.0,
    'Senior': 44.0,
    'Disabled': 44.0,
  };

  String _selectedArea = 'Local Bus & LYNX';
  String _selectedTicketType = 'MONTHLY UNLIMITED';

  final Map<String, int> _qty = {'Adult': 0, 'Senior': 0, 'Disabled': 0};

  bool _riderTypeOpen = true; // para simular el expand/collapse de Rider Type

  double get _total =>
      _qty.entries.fold(0.0, (sum, e) => sum + (prices[e.key]! * e.value));

  int get _tickets => _qty.values.fold(0, (a, b) => a + b);

  void _inc(String key) => setState(() => _qty[key] = (_qty[key]! + 1));

  void _dec(String key) => setState(() {
    if (_qty[key]! > 0) _qty[key] = _qty[key]! - 1;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyLarge = theme.textTheme.bodyLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AppBar “Buy Tickets”
        Material(
          color: theme.scaffoldBackgroundColor,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Buy Tickets',
                    style: bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Contenido scrollable
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // _HeaderRow(
                //   title: 'Area',
                //   value: _selectedArea,
                //   onTap: () async {
                //     final v = await _pickFromList(
                //       context,
                //       'Area',
                //       areas,
                //       _selectedArea,
                //     );
                //     if (v != null) setState(() => _selectedArea = v);
                //   },
                // ),
                // const Divider(height: 1),
                // _HeaderRow(
                //   title: 'Ticket Type',
                //   value: _selectedTicketType,
                //   onTap: () async {
                //     final v = await _pickFromList(
                //       context,
                //       'Ticket Type',
                //       ticketTypes,
                //       _selectedTicketType,
                //     );
                //     if (v != null) setState(() => _selectedTicketType = v);
                //   },
                // ),
                const Divider(height: 1),
                _ExpandableHeader(
                  title: 'Rider Type',
                  expanded: _riderTypeOpen,
                  onToggle: () =>
                      setState(() => _riderTypeOpen = !_riderTypeOpen),
                ),
                if (_riderTypeOpen) ...[
                  const SizedBox(height: 8),
                  ...prices.keys.map(
                    (k) => _RiderRow(
                      title: k,
                      price: prices[k]!,
                      qty: _qty[k]!,
                      onDec: () => _dec(k),
                      onInc: () => _inc(k),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Footer: total + botón
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _TotalBlock(total: _total, tickets: _tickets),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton(
              onPressed: _tickets == 0
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        TicketSelectionResult(
                          area: _selectedArea,
                          ticketType: _selectedTicketType,
                          quantities: Map<String, int>.from(_qty),
                          total: _total,
                        ),
                      );
                    },
              child: const Text('ADD TO CART'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickFromList(
    BuildContext context,
    String title,
    List<String> options,
    String selected,
  ) async {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            ...options.map(
              (o) => RadioListTile<String>(
                value: o,
                groupValue: selected,
                onChanged: (v) => Navigator.pop(context, v),
                title: Text(o),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Header con etiqueta + valor y caret (para Area / Ticket Type)
class _HeaderRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _HeaderRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.primary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Text(title, style: labelStyle),
              const Spacer(),
              Text(value, style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header expandible para “Rider Type”
class _ExpandableHeader extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;

  const _ExpandableHeader({
    required this.title,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.primary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Text(title, style: labelStyle),
              const Spacer(),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de tipo de pasajero (Adult / Senior / Disabled)
class _RiderRow extends StatelessWidget {
  final String title;
  final double price;
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;

  const _RiderRow({
    required this.title,
    required this.price,
    required this.qty,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Título y precio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textStyle),
                const SizedBox(height: 2),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Controles - / count / +
          _RoundIconButton(
            icon: Icons.remove,
            onPressed: qty == 0 ? null : onDec,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 24,
            child: Text('$qty', textAlign: TextAlign.center, style: textStyle),
          ),
          const SizedBox(width: 12),
          _RoundIconButton(icon: Icons.add, onPressed: onInc),
        ],
      ),
    );
  }
}

/// Botón redondo con splash controlado
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundIconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      color: theme.colorScheme.primary.withOpacity(
        onPressed == null ? 0.25 : 0.9,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        splashFactory: InkRipple.splashFactory,
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

/// Bloque de Total + Tickets (igual a la imagen)
class _TotalBlock extends StatelessWidget {
  final double total;
  final int tickets;

  const _TotalBlock({required this.total, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = '\$${total.toStringAsFixed(2)}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('Total', style: theme.textTheme.labelMedium),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$tickets',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text('Tickets', style: theme.textTheme.labelMedium),
          ],
        ),
      ],
    );
  }
}
