part of 'bus_cubit.dart';

class BusDataHandling {
  List<Map<String, dynamic>> busList = [];

  Future<Map<String, dynamic>> loadDataFromAssets(String path) async {
    final data = await rootBundle.loadString(path);

    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> loadBussesData() async {
    Map<String, dynamic> data =
        await loadDataFromAssets('assets/json/routes.geojson');

    final featuresdata = data["features"] as List;

    featuresdata.forEach((element) {
      busList.add(element as Map<String, dynamic>);
    });
    return busList;
  }

  Future<Map<String, dynamic>> loadStopsData() async {
    Map<String, dynamic> data =
        await loadDataFromAssets('assets/json/stops.json');
    return data;
  }
}
