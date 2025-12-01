import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/trufi_latlng.dart';
part 'panel_state.dart';

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
