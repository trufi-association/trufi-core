import 'dart:convert';
import 'dart:ffi';
import 'package:bloc/bloc.dart';

import 'package:flutter/services.dart' show rootBundle;

part 'bus_state.dart';
part 'busdatahandling.dart';

class BusCubit extends Cubit<Bus> {
  BusCubit() : super(Bus());
  //TODO: data handling
  BusDataHandling datahandler = BusDataHandling();

  List<Map<String, dynamic>> busseslist;

  Future<List<Bus>> getBusses() async {
    List<Bus> _buslist = [];
    busseslist = await datahandler.loadBussesData();
    busseslist.forEach((element) {
      _buslist.add(Bus.fromJson(element));
    });
    return _buslist;
  }
}
