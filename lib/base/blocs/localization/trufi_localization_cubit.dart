import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'trufi_localization_state.dart';

class TrufiLocalizationCubit extends Cubit<TrufiLocalization> {
  final _localRepository = TrufiLocalizationHiveLocalRepository();

  TrufiLocalizationCubit({required TrufiLocalization state})
      : super(state) {
    _load();
  }

  Future<void> _load() async {
    _localRepository.loadRepository();
    emit(state.copyWith(currentLocale: await _localRepository.getLocale()));
  }

  void changeLocale({
    Locale? currentLocale,
  }) {
    emit(state.copyWith(
      currentLocale: currentLocale,
    ));
    if (currentLocale != null) {
      _localRepository.saveLocale(currentLocale);
    }
  }
}
