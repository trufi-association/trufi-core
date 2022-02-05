import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/widgets/location_search_delegate/favorite_button.dart';
import 'package:trufi_core/base/widgets/location_search_delegate/suggestion_list.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class BuildStreetResults extends StatelessWidget {
  final TrufiStreet street;
  final void Function(TrufiLocation) onTap;

  const BuildStreetResults({
    Key? key,
    required this.street,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BaseTrufiPage(
        child: Builder(builder: (buildContext) {
          final searchLocationsCubit = buildContext.watch<SearchLocationsCubit>();
          final localizationSP = SavedPlacesLocalization.of(buildContext);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomScrollView(slivers: [
              const SliverPadding(padding: EdgeInsets.all(4.0)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Center
                    if (index == 0) {
                      return BuildItem(
                        onTap: () {
                          searchLocationsCubit
                              .insertHistoryPlace(street.location);
                          onTap(street.location);
                        },
                        iconData: const Icon(Icons.label),
                        title: street.displayName(localizationSP),
                        trailing: FavoriteButton(
                          location: street.location,
                        ),
                      );
                    }
                    // Junctions
                    final junction = street.junctions[index - 1];
                    return BuildItem(
                      onTap: () {
                        searchLocationsCubit.insertHistoryPlace(
                          junction.location(localizationSP),
                        );
                        onTap(
                          junction.location(localizationSP),
                        );
                      },
                      iconData: const Icon(Icons.label_outline),
                      title: localizationSP.instructionJunction(
                        "...",
                        junction.street2.displayName(localizationSP),
                      ),
                      trailing: FavoriteButton(
                        location: junction.location(localizationSP),
                      ),
                    );
                  },
                  childCount: street.junctions.length + 1,
                ),
              ),
              const SliverPadding(padding: EdgeInsets.all(4.0))
            ]),
          );
        }),
      ),
    );
  }
}
