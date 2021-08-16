import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/plan_map/widget/custom_text_button.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/location_icon.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

import '../../../keys.dart' as keys;
import '../../choose_location.dart';
import '../home_page.dart';
import '../setting_payload/date_time_picker/itinerary_date_selector.dart';
import 'widgets/ba_form_field_landscape.dart';
import 'widgets/ba_form_field_portrait.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool firstScreen = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final homePageCubit = context.watch<HomePageCubit>();
    return Scaffold(
      key: const ValueKey(keys.homePage),
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: theme.primaryColor,
            height: isPortrait ? 110 : 50,
            child: Text(
              isPortrait
                  ? "Hallo, finde deinen\n Bike & Bahn Weg"
                  : "Hallo, finde deinen Bike & Bahn Weg",
              style: const TextStyle(fontSize: 30, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  if (isPortrait)
                    BAFormFieldsPortrait(
                      spaceBetween: 10,
                      onSaveFrom: (TrufiLocation fromPlace) =>
                          homePageCubit.setFromPlace(fromPlace),
                      onSaveTo: (TrufiLocation fromPlace) =>
                          homePageCubit.setToPlace(fromPlace),
                    )
                  else
                    BAFormFieldsLandscape(
                      onSaveFrom: (TrufiLocation fromPlace) =>
                          homePageCubit.setFromPlace(fromPlace),
                      onSaveTo: (TrufiLocation fromPlace) =>
                          homePageCubit.setToPlace(fromPlace),
                    ),
                  const SizedBox(height: 15),
                  ItineraryDateSelector(
                    color: Colors.black,
                    onFetchPlan: () {},
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        Flexible(
                          child: BlocBuilder<SearchLocationsCubit,
                              SearchLocationsState>(
                            builder: (context, state) {
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  Row(
                                    children: [
                                      ...state.myDefaultPlaces
                                          .map(
                                            (place) => LocationIcon(
                                              location: place,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                            ),
                                          )
                                          .toList(),
                                      ...state.myPlaces
                                          .map(
                                            (place) => LocationIcon(
                                              location: place,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                            ),
                                          )
                                          .toList(),
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: InkWell(
                                          onTap: () {
                                            _addNewPlace(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: theme.primaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.white,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(0.0, 1.0),
                                                  blurRadius: 5.0,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  CustomTextButton(
                    text: 'Suchen',
                    height: 45,
                    onPressed: () {
                      _callFetchPlan(context);
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: const TrufiDrawer(HomePage.route),
    );
  }

  Future<void> _addNewPlace(BuildContext context) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final ChooseLocationDetail chooseLocationDetail =
        await ChooseLocationPage.selectPosition(
      context,
    );
    if (chooseLocationDetail != null) {
      searchLocationsCubit.insertMyPlace(TrufiLocation(
        description: chooseLocationDetail.description,
        address: chooseLocationDetail.street,
        latitude: chooseLocationDetail.location.latitude,
        longitude: chooseLocationDetail.location.longitude,
        type: 'saved_place:map',
      ));
    }
  }

  Future<void> _callFetchPlan(BuildContext context) async {
    final TrufiLocalization localization = TrufiLocalization.of(context);
    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    await homePageCubit
        .fetchPlan(
          correlationId,
          localization,
        )
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
  }
}
