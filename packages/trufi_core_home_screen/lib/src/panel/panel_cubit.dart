import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

part 'panel_state.dart';

/// Cubit for managing map panel state.
///
/// Controls the display of marker panels on the map.
class PanelCubit extends Cubit<PanelState> {
  PanelCubit() : super(const PanelState());
  void setPanel(MarkerPanel panel) {
    emit(const PanelState());
    Future.delayed(
      const Duration(milliseconds: 0),
      () => emit(PanelState(panel: panel)),
    );
  }

  void cleanPanel() {
    emit(const PanelState());
  }
}
