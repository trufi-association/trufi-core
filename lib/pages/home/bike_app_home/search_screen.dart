import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/plan_map/widget/custom_text_button.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/location_icon.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedRadio = 0;
  bool firstScreen = true;

  void setSelectedRadio(int value) {
    setState(() {
      selectedRadio = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final homePageCubit = context.watch<HomePageCubit>();
    return Scaffold(
      // key: const ValueKey(keys.homePage),
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // here the desired height
        child: AppBar(
          elevation: 0,
          toolbarHeight: 100,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: IconButton(
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
              icon: const Icon(
                Icons.menu_outlined,
                size: 35,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  "Bike & Bahn",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TODO translate
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Willkomment!",
                    style: theme.textTheme.subtitle1.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: RadioListTile<int>(
                          value: 0,
                          title: const Text(
                            'Mehr Rad',
                            style: TextStyle(fontSize: 16),
                          ),
                          groupValue: selectedRadio,
                          onChanged: setSelectedRadio,
                          selected: 0 == selectedRadio,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: RadioListTile<int>(
                          value: 1,
                          title: const Text(
                            'Mehr Offi',
                            style: TextStyle(fontSize: 16),
                          ),
                          groupValue: selectedRadio,
                          onChanged: setSelectedRadio,
                          selected: 1 == selectedRadio,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Favoriten",
                    style: theme.textTheme.subtitle1.copyWith(fontSize: 17),
                  ),
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
                                        margin: const EdgeInsets.only(left: 5),
                                        child: InkWell(
                                          onTap: () {
                                            _addNewPlace(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: theme.accentColor,
                                              ),
                                              // boxShadow: const [
                                              //   BoxShadow(
                                              //     color: Colors.grey,
                                              //     offset: Offset(0.0, 1.0),
                                              //     blurRadius: 5.0,
                                              //   ),
                                              // ],
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: theme.accentColor,
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
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: CustomTextButton(
                      text: 'SUCHEN',
                      onPressed: () {
                        _callFetchPlan(context);
                      },
                      color: theme.accentColor,
                      borderRadius: 10,
                      height: 45,
                    ),
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
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    await homePageCubit
        .fetchPlan(correlationId, localization,
            advancedOptions: payloadDataPlanCubit.state)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
  }
}
