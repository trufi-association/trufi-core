part of 'bus_cubit.dart';

class BusDataHandling {
  List<Map<String, dynamic>> busList = [];

  Future<Map<String, dynamic>> loadDataFromAssets() async {
    final data = await rootBundle.loadString('assets/json/routes.geojson');

    return jsonDecode(data) as Map<String, dynamic>;
    //* this is our required data
  }

  Future<List<Map<String, dynamic>>> loadBussesData() async {
    Map<String, dynamic> data = await loadDataFromAssets();

    final featuresdata = data["features"] as List;

    featuresdata.forEach((element) {
      busList.add(element as Map<String, dynamic>);
    });
    return busList;
  }
}
