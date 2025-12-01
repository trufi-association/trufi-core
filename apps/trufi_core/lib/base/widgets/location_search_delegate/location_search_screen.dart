import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';
import 'package:trufi_core/base/widgets/location_search_delegate/build_street_results.dart';
import 'package:trufi_core/base/widgets/location_search_delegate/suggestion_list.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class LocationSearchScreen extends StatefulWidget {
  static Future<TrufiLocation?> searchLocation(
    BuildContext buildContext, {
    required SelectLocationData selectPositionOnPage,
    bool isOrigin = true,
  }) async {
    return await showTrufiDialog<TrufiLocation?>(
      context: buildContext,
      builder: (BuildContext context) => LocationSearchScreen(
        selectPositionOnPage: selectPositionOnPage,
        isOrigin: isOrigin,
      ),
    );
  }

  const LocationSearchScreen({
    super.key,
    required this.selectPositionOnPage,
    required this.isOrigin,
  });

  final SelectLocationData selectPositionOnPage;
  final bool isOrigin;

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _textController = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor, context: context);
  }

  @override
  void dispose() {
    _textController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!stopDefaultButtonEvent) {
      Navigator.pop(context);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor:
            theme.brightness == Brightness.dark ? Colors.grey[900] : null,
        textSelectionTheme: theme.textSelectionTheme.copyWith(
          cursorColor: theme.colorScheme.secondary,
          selectionColor: theme.colorScheme.secondary.withOpacity(0.7),
        ),
        hintColor: Colors.grey[300],
        textTheme: theme.textTheme.copyWith(
          titleLarge: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  autocorrect: false,
                  onChanged: (data) {
                    searchLocationsCubit.fetchLocations(
                      data.trim().toLowerCase(),
                    );
                    setState(() {
                      query = data;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.isOrigin
                        ? localization.searchHintOrigin
                        : localization.searchHintDestination,
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchLocationsCubit.fetchLocations("");
                  _textController.text = "";
                  setState(() {
                    query = "";
                  });
                },
              ),
            const SizedBox(width: 5),
          ],
        ),
        body: SuggestionList(
          query: query.trim(),
          isOrigin: widget.isOrigin,
          selectPositionOnPage: widget.selectPositionOnPage,
          onSelected: (locationSelected) {
            Navigator.of(context).pop(locationSelected);
          },
          onSelectedMap: (locationSelected) {
            Navigator.of(context).pop(locationSelected);
          },
          onStreetTapped: (TrufiStreet streetSelected) {
            showTrufiDialog(
              context: context,
              builder: (buildContext) {
                return BuildStreetResults(
                  street: streetSelected,
                  onTap: (locationSelected) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(locationSelected);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
