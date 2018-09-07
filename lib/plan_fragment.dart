import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_bloc.dart';
import 'package:trufi_app/location/location_map_controller.dart';
import 'package:trufi_app/plan/plan_view.dart';
import 'package:trufi_app/trufi_models.dart';

class PlanFragment extends StatelessWidget {
  final Plan _plan;

  PlanFragment(this._plan);

  @override
  Widget build(BuildContext context) {
    PlanError error = _plan?.error;
    return Container(
      child: error != null
          ? _buildBodyError(error)
          : _plan != null ? PlanView(_plan) : _buildBodyEmpty(context),
    );
  }

  Widget _buildBodyError(PlanError error) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          error.message,
        ),
      ),
    );
  }

  Widget _buildBodyEmpty(BuildContext context) {
    LocationBloc locationBloc = BlocProvider.of<LocationBloc>(context);
    return StreamBuilder<LatLng>(
      stream: locationBloc.outLocationUpdate,
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        return MapControllerPage(snapshot.data);
      },
    );
  }
}
