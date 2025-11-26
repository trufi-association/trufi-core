import 'package:flutter/material.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

/// POC: Fares (Tickets & Reservations)
/// -----------------------------------
/// A Material 3–style page that shows two tabs:
///  - Purchased tickets
///  - Reservations
///
/// Includes:
///  • Simple in-memory demo data
///  • Empty states
///  • Detail action sheet
///  • Optional external link launcher (Explore fares)
///
/// Notes
///  - Wire the data layer later to your real models & APIs.
///  - Localization keys are referenced but safely fall back to strings
///    if the key is missing.
class TicketsPage extends StatelessWidget {
  static const String route = "tickets";

  /// Optional: deep link for exploring fares / store / web
  final String? exploreFaresUrl;

  const TicketsPage({super.key, this.exploreFaresUrl});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tickets management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'tabPurchased'),
              Tab(text: 'tabReserved'),
            ],
          ),
          actions: [
            if (exploreFaresUrl != null)
              IconButton(
                tooltip: 'actionExplore',
                onPressed: () async {
                  final uri = Uri.parse(exploreFaresUrl!);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new),
              ),
          ],
        ),
        body: const TabBarView(
          children: [
            _TicketsList(kind: _TicketListKind.purchased),
            _TicketsList(kind: _TicketListKind.reserved),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showBuySheet(context);
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: Text('actionBuyTicket'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Demo data models
// ---------------------------------------------------------------------------

enum FareStatus { purchased, reserved, used, cancelled, expired, refunded }

class FareTicket {
  FareTicket({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.validUntil,
    required this.priceMinor,
    required this.currency,
    required this.status,
    this.qrCodeData,
  });

  final String id;
  final String title; // e.g., "Single Ride", "Day Pass"
  final String subtitle; // e.g., zone/route/passenger
  final DateTime? validUntil; // null if not applicable yet
  final int priceMinor; // price in minor units (e.g., cents)
  final String currency; // e.g., "EUR", "BOB"
  final FareStatus status;
  final String? qrCodeData; // present when purchased/activated
}

// ---------------------------------------------------------------------------
// UI: Tickets List
// ---------------------------------------------------------------------------

enum _TicketListKind { purchased, reserved }

class _TicketsList extends StatelessWidget {
  const _TicketsList({required this.kind});
  final _TicketListKind kind;

  @override
  Widget build(BuildContext context) {
    // Demo data — replace with repository/provider/stream
    final items = _demoTickets(kind);

    if (items.isEmpty) {
      return _EmptyState(kind: kind);
    }

    return Scrollbar(
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = items[index];
          return _TicketTile(ticket: t);
        },
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket});
  final FareTicket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusChip = _StatusChip(status: ticket.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: _leadingIcon(ticket.status),
        title: Text(ticket.title, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.subtitle, style: theme.textTheme.bodyMedium),
            if (ticket.validUntil != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'l10n.validUntil(${ticket.validUntil!})',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Wrap(
                spacing: 6,
                runSpacing: -8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  statusChip,
                  _PriceChip(
                    amountMinor: ticket.priceMinor,
                    currency: ticket.currency,
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<_TicketAction>(
          onSelected: (a) => _onAction(context, a, ticket),
          itemBuilder: (context) => _menuFor(ticket),
        ),
        onTap: () => _openDetails(context, ticket),
      ),
    );
  }

  Widget _leadingIcon(FareStatus status) {
    switch (status) {
      case FareStatus.purchased:
        return const Icon(Icons.qr_code_2);
      case FareStatus.reserved:
        return const Icon(Icons.confirmation_number);
      case FareStatus.used:
        return const Icon(Icons.verified);
      case FareStatus.cancelled:
        return const Icon(Icons.cancel);
      case FareStatus.expired:
        return const Icon(Icons.hourglass_bottom);
      case FareStatus.refunded:
        return const Icon(Icons.reply);
    }
  }
}

// ---------------------------------------------------------------------------
// UI: Chips & helpers
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final FareStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      FareStatus.purchased => 'Purchased',
      FareStatus.reserved => 'Reserved',
      FareStatus.used => 'Used',
      FareStatus.cancelled => 'Cancelled',
      FareStatus.expired => 'Expired',
      FareStatus.refunded => 'Refunded',
    };

    Color? bg;
    Color? fg;
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case FareStatus.purchased:
        bg = colorScheme.secondaryContainer;
        fg = colorScheme.onSecondaryContainer;
        break;
      case FareStatus.reserved:
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        break;
      case FareStatus.used:
        bg = colorScheme.primaryContainer;
        fg = colorScheme.onPrimaryContainer;
        break;
      case FareStatus.cancelled:
        bg = colorScheme.errorContainer;
        fg = colorScheme.onErrorContainer;
        break;
      case FareStatus.expired:
        bg = colorScheme.surfaceVariant;
        fg = colorScheme.onSurfaceVariant;
        break;
      case FareStatus.refunded:
        bg = colorScheme.surfaceContainerHigh;
        fg = colorScheme.onSurface;
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: bg,
      labelStyle: TextStyle(color: fg),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.amountMinor, required this.currency});
  final int amountMinor;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final amount = amountMinor / 100.0;
    return Chip(
      avatar: const Icon(Icons.sell, size: 16),
      label: Text("${amount.toStringAsFixed(2)} $currency"),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.kind});
  final _TicketListKind kind;

  @override
  Widget build(BuildContext context) {
    final isPurchased = kind == _TicketListKind.purchased;
    final icon = isPurchased ? Icons.receipt_long : Icons.bookmark_add_outlined;
    final title = isPurchased ? 'No purchased tickets' : 'No reserved tickets';
    final desc = isPurchased
        ? 'You have not purchased any tickets yet.'
        : 'You have not reserved any tickets yet.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              desc,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showBuySheet(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text('Buy Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Actions & menus
// ---------------------------------------------------------------------------

enum _TicketAction { details, showQr, cancelReservation, refund, share }

List<PopupMenuEntry<_TicketAction>> _menuFor(FareTicket t) {
  final items = <PopupMenuEntry<_TicketAction>>[
    PopupMenuItem(value: _TicketAction.details, child: Text('Details')),
    const PopupMenuDivider(),
  ];

  if (t.status == FareStatus.purchased && t.qrCodeData != null) {
    items.add(
      PopupMenuItem(value: _TicketAction.showQr, child: Text('Show QR Code')),
    );
  }
  if (t.status == FareStatus.reserved) {
    items.add(
      PopupMenuItem(
        value: _TicketAction.cancelReservation,
        child: Text('Cancel Reservation'),
      ),
    );
  }
  if (t.status == FareStatus.purchased) {
    items.add(
      PopupMenuItem(value: _TicketAction.refund, child: Text('Request Refund')),
    );
  }

  items
    ..add(const PopupMenuDivider())
    ..add(PopupMenuItem(value: _TicketAction.share, child: Text('Share')));
  return items;
}

void _onAction(BuildContext context, _TicketAction a, FareTicket t) {
  switch (a) {
    case _TicketAction.details:
      _openDetails(context, t);
      break;
    case _TicketAction.showQr:
      _showQr(context, t);
      break;
    case _TicketAction.cancelReservation:
      _confirm(context, 'Are you sure you want to cancel the reservation?', () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Reservation cancelled')));
      });
      break;
    case _TicketAction.refund:
      _confirm(context, 'Are you sure you want to request a refund?', () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Refund requested')));
      });
      break;
    case _TicketAction.share:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Shared successfully')));
      break;
  }
}

void _openDetails(BuildContext context, FareTicket t) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.confirmation_number),
                title: Text(t.title),
                subtitle: Text(t.subtitle),
                trailing: _PriceChip(
                  amountMinor: t.priceMinor,
                  currency: t.currency,
                ),
              ),
              if (t.validUntil != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text('l10n.validUntil(${t.validUntil!})'),
                ),
              Wrap(spacing: 8, children: [_StatusChip(status: t.status)]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check),
                      label: Text('Close'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      );
    },
  );
}

void _showQr(BuildContext context, FareTicket t) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 200),
            const SizedBox(height: 8),
            Text(t.qrCodeData ?? 'No QR code available'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

void _confirm(BuildContext context, String message, VoidCallback onYes) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onYes();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

void _showBuySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Ticket',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Select your ticket type'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.directions_bus),
                      label: Text('Buy Single Ride'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.calendar_view_day),
                      label: Text('Buy Day Pass'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Demo data
// ---------------------------------------------------------------------------

List<FareTicket> _demoTickets(_TicketListKind kind) {
  switch (kind) {
    case _TicketListKind.purchased:
      return [
        FareTicket(
          id: 't1',
          title: 'Sample Single Ride',
          subtitle: 'Zone A • Adult',
          validUntil: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
          priceMinor: 350,
          currency: 'BOB',
          status: FareStatus.purchased,
          qrCodeData: 'QR-123-ABC',
        ),
        FareTicket(
          id: 't2',
          title: 'Sample Day Pass',
          subtitle: 'All Zones • Adult',
          validUntil: DateTime.now().add(const Duration(hours: 20)),
          priceMinor: 1200,
          currency: 'BOB',
          status: FareStatus.used,
          qrCodeData: 'QR-XYZ-999',
        ),
      ];
    case _TicketListKind.reserved:
      return [
        FareTicket(
          id: 'r1',
          title: 'Sample Reservation',
          subtitle: 'La Paz → El Alto • 12:30',
          validUntil: DateTime.now().add(const Duration(minutes: 15)),
          priceMinor: 500,
          currency: 'BOB',
          status: FareStatus.reserved,
        ),
      ];
  }
}
