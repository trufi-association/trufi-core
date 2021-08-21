import 'dart:convert';
import 'dart:ffi';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:trufi_core/services/models_otp/geometry.dart';

part 'bus_state.dart';
part 'busdatahandling.dart';

class BusCubit extends Cubit<Bus> {
  BusCubit() : super(Bus());
  //TODO: data handling
  BusDataHandling datahandler = BusDataHandling();

  List<Map<String, dynamic>> rawbussesdata;

  Future<List<Bus>> getBusses() async {
    List<Bus> buslist = [];
    rawbussesdata = await datahandler.loadBussesData();
    rawbussesdata.forEach((element) {
      buslist.add(Bus.fromJson(element));
    });
    return buslist;
  }
}
