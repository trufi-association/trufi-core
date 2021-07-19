import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
part 'panel_state.dart';

class PanelCubit extends Cubit<PanelState> {
  PanelCubit() : super(const PanelState());
  void setPanel(CustomMarkerPanel panel) {
    emit(const PanelState());
    emit(PanelState(panel: panel));
  }

  void cleanPanel() {
    emit(const PanelState());
  }
}
