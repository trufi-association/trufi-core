// import 'package:flutter/material.dart';
// import 'package:trufi_core/localization/app_localization.dart';
// import 'package:trufi_core/pages/home/widgets/search_bar/full_screen_search_modal.dart';
// import 'package:trufi_core/pages/home/widgets/search_bar/location_search_bar.dart';
// import 'package:trufi_core/pages/home/widgets/search_bar/search_bar_utils.dart';
// import 'package:trufi_core/repositories/location/location_repository.dart';
// import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
// import 'package:trufi_core/utils/icon_utils/icons.dart';
// import 'package:trufi_core/widgets/base_marker/from_marker.dart';
// import 'package:trufi_core/widgets/base_marker/to_marker.dart';
// import 'package:trufi_core/widgets/maps/choose_location/choose_location.dart';

// class FullScreenSelectLocationModal extends StatefulWidget {
//   static Future<RouteEndpoints?> showRouteEndpointsPicker(
//     BuildContext context, {
//     required void Function(TrufiLocation) onSaveFrom,
//     required void Function() onClearFrom,
//     required void Function(TrufiLocation) onSaveTo,
//     required void Function() onClearTo,
//     required void Function() onFetchPlan,
//     required void Function() onReset,
//     required void Function() onSwap,
//     TrufiLocation? origin,
//     TrufiLocation? destination,
//   }) async {
//     return await Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         transitionDuration: const Duration(milliseconds: 300),
//         pageBuilder: (_, __, ___) => FullScreenSelectLocationModal(
//           onSaveFrom: onSaveFrom,
//           onClearFrom: onClearFrom,
//           onSaveTo: onSaveTo,
//           onClearTo: onClearTo,
//           onFetchPlan: onFetchPlan,
//           onReset: onReset,
//           onSwap: onSwap,
//           origin: origin,
//           destination: destination,
//         ),
//       ),
//     );
//   }

//   final void Function(TrufiLocation) onSaveFrom;
//   final void Function() onClearFrom;
//   final void Function(TrufiLocation) onSaveTo;
//   final void Function() onClearTo;
//   final void Function() onFetchPlan;
//   final void Function() onReset;
//   final void Function() onSwap;

//   final TrufiLocation? origin;
//   final TrufiLocation? destination;

//   const FullScreenSelectLocationModal({
//     super.key,
//     required this.onSaveFrom,
//     required this.onClearFrom,
//     required this.onSaveTo,
//     required this.onClearTo,
//     required this.onFetchPlan,
//     required this.onReset,
//     required this.onSwap,
//     required this.origin,
//     required this.destination,
//   });

//   @override
//   State<FullScreenSelectLocationModal> createState() =>
//       _FullScreenSelectLocationModalState();
// }

// class _FullScreenSelectLocationModalState
//     extends State<FullScreenSelectLocationModal> {
//   final locationRepository = LocationRepository();
//   TrufiLocation? origin;
//   TrufiLocation? destination;
//   @override
//   void initState() {
//     super.initState();
//     origin = widget.origin;
//     destination = widget.destination;
//     locationRepository.historyPlaces.addListener(_update);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await locationRepository.initLoad();
//     });
//   }

//   @override
//   void dispose() {
//     locationRepository.historyPlaces.removeListener(_update);
//     super.dispose();
//   }

//   void _update() {
//     if (mounted) setState(() {});
//   }

//   void _setRouteEndpoint(TrufiLocation location) {
//     // Fill the first missing endpoint; do NOT overwrite a value already chosen
//     origin ??= location;
//     destination ??= origin == null ? location : destination ?? location;

//     final o = origin, d = destination;
//     if (o != null && d != null) {
//       Navigator.of(context).pop(RouteEndpoints(origin: o, destination: d));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.only(bottom: 8),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.surface,
//                 boxShadow: [
//                   BoxShadow(
//                     color: theme.colorScheme.shadow.withAlpha(60),
//                     blurRadius: 4,
//                     spreadRadius: 0.1,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           children: [
//                             IconButton(
//                               onPressed: () => Navigator.of(context).pop(),
//                               visualDensity: VisualDensity.compact,
//                               icon: Icon(
//                                 Icons.arrow_back_ios_new,
//                                 color: theme.colorScheme.onSurface,
//                                 size: 20,
//                               ),
//                               tooltip: 'Back',
//                             ),
//                             Expanded(
//                               child: Stack(
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   Positioned(
//                                     bottom: -12,
//                                     child: SearchBarUtils.getDots(
//                                       theme.colorScheme.onSurfaceVariant,
//                                     ),
//                                   ),
//                                   _TextSquareFieldUI(
//                                     onTap: () async {
//                                       final locationSelected =
//                                           await FullScreenSearchModal.onLocationSelected(
//                                             context,
//                                             location: origin,
//                                           );
//                                       if (locationSelected != null) {
//                                         widget.onSaveFrom(locationSelected);
//                                       }
//                                     },
//                                     location: origin,
//                                     hintText: 'Choose start location',
//                                     icon: Container(
//                                       width: 24,
//                                       padding: const EdgeInsets.all(3.5),
//                                       child: const FromMarker(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 40),
//                           child: _TextSquareFieldUI(
//                             onTap: () async {
//                               final locationSelected =
//                                   await FullScreenSearchModal.onLocationSelected(
//                                     context,
//                                     location: destination,
//                                   );
//                               if (locationSelected != null) {
//                                 widget.onSaveTo(locationSelected);
//                               }
//                             },
//                             location: destination,
//                             hintText: 'Choose destination location',
//                             icon: Container(
//                               width: 24,
//                               padding: const EdgeInsets.symmetric(vertical: 8),
//                               child: const ToMarker(),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.swap_vert),
//                     color: theme.colorScheme.onSurface,
//                     visualDensity: VisualDensity.compact,
//                     padding: EdgeInsets.zero,
//                     onPressed: () {
//                       setState(() {
//                         final temp = origin;
//                         origin = destination;
//                         destination = temp;
//                       });
//                     },
//                     tooltip: 'Swap',
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: CustomScrollView(
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: Column(
//                       children: [
//                         Container(
//                           height: 56,
//                           margin: EdgeInsets.only(top: 8),
//                           child: ListView(
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             scrollDirection: Axis.horizontal,
//                             children: [
//                               ...locationRepository.myDefaultPlaces.value.map(
//                                 (e) => QuickActionPill(
//                                   icon: typeToIconData(
//                                     e.type,
//                                     color: theme.colorScheme.onSurface,
//                                   ),
//                                   title: e.description,
//                                   subtitle: e.address ?? '',
//                                   onTap: () async {
//                                     if (e.isLatLngDefined) {
//                                       _setRouteEndpoint(e);
//                                     } else {
//                                       final locationSelected =
//                                           await ChooseLocationPage.selectLocation(
//                                             context,
//                                             hideLocationDetails: true,
//                                           );
//                                       if (locationSelected != null) {
//                                         await locationRepository
//                                             .updateMyDefaultPlace(
//                                               e,
//                                               e.copyWith(
//                                                 position:
//                                                     locationSelected.position,
//                                               ),
//                                             );
//                                       }
//                                     }
//                                   },
//                                 ),
//                               ),
//                               ...locationRepository.myPlaces.value.map(
//                                 (e) => QuickActionPill(
//                                   icon: typeToIconData(
//                                     e.type,
//                                     color: theme.colorScheme.onSurface,
//                                   ),
//                                   title: e.description,
//                                   subtitle: e.address ?? '',
//                                   onTap: () {
//                                     _setRouteEndpoint(e);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Divider(height: 0),
//                         ...locationRepository.historyPlaces.value.reversed.map(
//                           (e) => PlaceTile(
//                             location: e,
//                             onTap: () {
//                               _setRouteEndpoint(e);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TextSquareFieldUI extends StatelessWidget {
//   final TrufiLocation? location;
//   final String hintText;
//   final VoidCallback onTap;
//   final Container icon;

//   const _TextSquareFieldUI({
//     this.location,
//     required this.onTap,
//     required this.icon,
//     required this.hintText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return SizedBox(
//       height: 44,
//       child: Row(
//         children: [
//           icon,
//           const SizedBox(width: 4),
//           Expanded(
//             child: Container(
//               height: 35,
//               padding: EdgeInsets.only(left: 6),
//               decoration: BoxDecoration(
//                 border: Border.all(color: theme.colorScheme.outlineVariant),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Row(
//                 children: [
//                   Flexible(
//                     child: Text(
//                       location?.displayName(AppLocalization.of(context)) ??
//                           hintText,
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: location != null
//                             ? theme.colorScheme.onSurface
//                             : theme.colorScheme.onSurfaceVariant,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   if (location == null)
//                     Icon(
//                       Icons.keyboard_arrow_right,
//                       size: 20,
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
