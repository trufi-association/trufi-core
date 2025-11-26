import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/repositories/location/location_repository.dart';
import 'package:trufi_core/repositories/location/models/defaults_location.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/utils/icon_utils/icons.dart';
import 'package:trufi_core/widgets/maps/choose_location/choose_location.dart';

class FullScreenSearchModal extends StatefulWidget {
  static Future<TrufiLocation?> onLocationSelected(
    BuildContext context, {
    TrufiLocation? location,
  }) async {
    final defaultSearch = (location != null)
        ? location.displayName(AppLocalization.of(context))
        : '';
    return await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => FullScreenSearchModal(
          location: location,
          defaultSearch: defaultSearch,
        ),
      ),
    );
  }

  final TrufiLocation? location;
  final String defaultSearch;
  const FullScreenSearchModal({
    super.key,
    this.location,
    required this.defaultSearch,
  });

  @override
  State<FullScreenSearchModal> createState() => _FullScreenSearchModalState();
}

class _FullScreenSearchModalState extends State<FullScreenSearchModal> {
  late TextEditingController _controller;
  final locationRepository = LocationRepository();
  String _currentSearch = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentSearch = widget.defaultSearch;
    _controller = TextEditingController(text: _currentSearch);
    locationRepository.searchResult.addListener(_update);
    locationRepository.myDefaultPlaces.addListener(_update);
    locationRepository.myPlaces.addListener(_update);
    locationRepository.historyPlaces.addListener(_update);
    locationRepository.favoritePlaces.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationRepository.initLoad();
      if (_currentSearch != '') {
        await locationRepository.fetchLocations(_controller.text.toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    locationRepository.searchResult.removeListener(_update);
    locationRepository.myDefaultPlaces.removeListener(_update);
    locationRepository.myPlaces.removeListener(_update);
    locationRepository.historyPlaces.removeListener(_update);
    locationRepository.favoritePlaces.removeListener(_update);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  Future<void> _setLocation({required TrufiLocation location}) async {
    await locationRepository.insertHistoryPlace(location);
    if (mounted) Navigator.of(context).pop(location);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      if (_currentSearch != query) {
        _currentSearch = query;
        locationRepository.fetchLocations(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final divider = Divider(
      color: theme.colorScheme.surfaceVariant,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 8),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      cursorColor: theme.colorScheme.primary,
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: (text) {
                        _onSearchChanged(text);
                      },
                      onSubmitted: (text) {
                        _onSearchChanged(text);
                      },
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _controller.clear();
                        locationRepository.fetchLocations('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.highlight_remove),
                      color: theme.colorScheme.onSurface,
                      tooltip: 'Clear',
                    ),
                ],
              ),
            ),

            ValueListenableBuilder<bool>(
              valueListenable: locationRepository.isLoading,
              builder: (context, loading, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: loading
                      ? const LinearProgressIndicator(
                          key: ValueKey('progress'),
                          minHeight: 4,
                        )
                      : const SizedBox(key: ValueKey('noprog'), height: 4),
                );
              },
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (locationRepository.searchResult.value == null)
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SearchOption(
                            onTap: () async {},
                            title: "Your location",
                            icon: const Icon(Icons.my_location),
                          ),
                          Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: 54,
                            color: theme.dividerColor,
                          ),
                          _SearchOption(
                            onTap: () async {
                              final locationSelected =
                                  await ChooseLocationPage.selectLocation(
                                    context,
                                  );
                              if (locationSelected != null) {
                                _setLocation(location: locationSelected);
                              }
                            },
                            title: "Choose on map",
                            icon: const Icon(Icons.pin_drop),
                            iconBackgorundColor: Colors.grey.shade300,
                          ),
                          divider,
                          SizedBox(
                            height: 56,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              scrollDirection: Axis.horizontal,
                              children: [
                                ...locationRepository.myDefaultPlaces.value.map(
                                  (e) => QuickActionPill(
                                    icon: typeToIconData(
                                      e.type,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    title: localization.translate(
                                      DefaultLocationExt.detect(e)?.l10nKey,
                                    ),
                                    subtitle: e.isLatLngDefined
                                        ? e.subTitle
                                        : localization.translate(
                                            LocalizationKey
                                                .defaultLocationSetLocation,
                                          ),
                                    onTap: () async {
                                      if (e.isLatLngDefined) {
                                        _setLocation(location: e);
                                      } else {
                                        final locationSelected =
                                            await ChooseLocationPage.selectLocation(
                                              context,
                                              hideLocationDetails: true,
                                            );
                                        if (locationSelected != null) {
                                          await locationRepository
                                              .updateMyDefaultPlace(
                                                e,
                                                e.copyWith(
                                                  position:
                                                      locationSelected.position,
                                                ),
                                              );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                ...locationRepository.myPlaces.value.map(
                                  (e) => QuickActionPill(
                                    icon: typeToIconData(
                                      e.type,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    title: e.description,
                                    subtitle: e.address ?? '',
                                    onTap: () => _setLocation(location: e),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          divider,
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Text(
                                  'Recent',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  SliverList.list(
                    children: [
                      if (locationRepository.searchResult.value != null)
                        if (locationRepository.searchResult.value!.isNotEmpty)
                          ...locationRepository.searchResult.value!.map(
                            (location) => PlaceTile(
                              location: location,
                              onTap: () => _setLocation(location: location),
                            ),
                          )
                        else
                          Container()
                      else ...[
                        ...locationRepository.historyPlaces.value.reversed.map(
                          (location) => PlaceTile(
                            location: location,
                            onTap: () => _setLocation(location: location),
                          ),
                        ),
                        // const _MoreFromHistory(),
                        ...locationRepository.favoritePlaces.value.reversed.map(
                          (location) => PlaceTile(
                            location: location,
                            onTap: () => _setLocation(location: location),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchOption extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final Color iconBackgorundColor;

  const _SearchOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconBackgorundColor = const Color(0xFFD9E5EB),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      visualDensity: VisualDensity.compact,
      horizontalTitleGap: 12,
      onTap: onTap,
      minVerticalPadding: 12,
      leading: CircleAvatar(
        radius: 15,
        backgroundColor: iconBackgorundColor,
        child: SizedBox(width: 18, height: 18, child: FittedBox(child: icon)),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class QuickActionPill extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color iconBackgorundColor;

  const QuickActionPill({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconBackgorundColor = const Color(0xFFD9E5EB),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: iconBackgorundColor,
              child: SizedBox(
                width: 18,
                height: 18,
                child: FittedBox(child: icon),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceTile extends StatelessWidget {
  final TrufiLocation location;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final Color? leadingColor;

  const PlaceTile({
    super.key,
    required this.location,
    required this.onTap,
    this.leadingIcon,
    this.leadingColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = location.displayName(AppLocalization.of(context));
    final String? subtitle = location.subTitle;
    final String? metaPrimary = null;
    final Color? metaPrimaryColor = null;
    final String? metaSecondary = null;

    return Column(
      children: [
        ListTile(
          visualDensity: VisualDensity.compact,
          horizontalTitleGap: 12,
          onTap: onTap,
          minVerticalPadding: (subtitle != null && subtitle.isNotEmpty)
              ? 12
              : 20,
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.surfaceVariant,
            radius: 15,
            child: leadingIcon != null
                ? Icon(
                    leadingIcon,
                    color: leadingColor ?? theme.colorScheme.onSurface,
                    size: 20,
                  )
                : typeToIconData(
                    location.type,
                    color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
                  ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: (subtitle != null && subtitle.isNotEmpty)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (metaPrimary != null)
                          Text(
                            metaPrimary,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  metaPrimaryColor ??
                                  theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        if (metaPrimary != null && metaSecondary != null)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('·'),
                          ),
                        if (metaSecondary != null)
                          Text(
                            metaSecondary,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1,
                            ),
                          ),
                      ],
                    ),
                  ],
                )
              : null,
        ),
        Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 54,
          color: theme.dividerColor,
        ),
      ],
    );
  }
}

class _MoreFromHistory extends StatelessWidget {
  const _MoreFromHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'More from recent history',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF008080),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
