import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/repository/wfs_weather_data_repository.dart';

void main() {
  group("WFSWeatherDataRepository", () {
    WFSWeatherDataRepository subject;

    test("should throw HttpException if the Client response with error",
        () async {
      final mockClient = MockClient((request) async {
        return http.Response("Error", 400);
      });

      subject = WFSWeatherDataRepository(client: mockClient);
      final now = DateTime.now();

      expect(
        () async => subject.getCurrentWeatherAtLocation(
          now,
          LatLng(48.59523, 8.86648),
        ),
        throwsA(predicate((e) =>
            e is HttpException &&
            e.message ==
                "Could not get the current Weather at your location 400")),
      );
    });

    test("should return a valid WeatherInfo", () async {
      final mockClient = MockClient((request) async {
        return http.Response(_weatherResponse, 200);
      });

      subject = WFSWeatherDataRepository(client: mockClient);
      final now = DateTime(2021, 05, 08);
      final result = await subject.getCurrentWeatherAtLocation(
          now, LatLng(48.59523, 8.86648));

      expect(result.temperature, "19.08");
      expect(result.windSpeed, "4.8");
      expect(result.weatherSymbol, "3.0");
    });
  });
}

const String _weatherResponse = """
<?xml version="1.0" encoding="UTF-8"?>
<wfs:FeatureCollection
  timeStamp="2021-05-09T08:59:43Z"
  numberReturned="3"
  numberMatched="3"
      xmlns:wfs="http://www.opengis.net/wfs/2.0"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:BsWfs="http://xml.fmi.fi/schema/wfs/2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/wfs/2.0 http://schemas.opengis.net/wfs/2.0/wfs.xsd
                        http://xml.fmi.fi/schema/wfs/2.0 http://xml.fmi.fi/schema/wfs/2.0/fmi_wfs_simplefeature.xsd"
>
  	
	<wfs:member>
            <BsWfs:BsWfsElement gml:id="BsWfsElement.1.1.1">
                <BsWfs:Location>
                    <gml:Point gml:id="BsWfsElementP.1.1.1" srsDimension="2" srsName="http://www.opengis.net/def/crs/EPSG/0/4258">
                        <gml:pos>48.59523 8.86648 </gml:pos>
                    </gml:Point>
                </BsWfs:Location>
                <BsWfs:Time>2021-05-09T08:00:00Z</BsWfs:Time>
                <BsWfs:ParameterName>temperature</BsWfs:ParameterName>
                <BsWfs:ParameterValue>19.08</BsWfs:ParameterValue>
            </BsWfs:BsWfsElement>
	</wfs:member>
	
	<wfs:member>
            <BsWfs:BsWfsElement gml:id="BsWfsElement.1.1.2">
                <BsWfs:Location>
                    <gml:Point gml:id="BsWfsElementP.1.1.2" srsDimension="2" srsName="http://www.opengis.net/def/crs/EPSG/0/4258">
                        <gml:pos>48.59523 8.86648 </gml:pos>
                    </gml:Point>
                </BsWfs:Location>
                <BsWfs:Time>2021-05-09T08:00:00Z</BsWfs:Time>
                <BsWfs:ParameterName>WindSpeedMS</BsWfs:ParameterName>
                <BsWfs:ParameterValue>4.8</BsWfs:ParameterValue>
            </BsWfs:BsWfsElement>
	</wfs:member>
	
	<wfs:member>
            <BsWfs:BsWfsElement gml:id="BsWfsElement.1.1.3">
                <BsWfs:Location>
                    <gml:Point gml:id="BsWfsElementP.1.1.3" srsDimension="2" srsName="http://www.opengis.net/def/crs/EPSG/0/4258">
                        <gml:pos>48.59523 8.86648 </gml:pos>
                    </gml:Point>
                </BsWfs:Location>
                <BsWfs:Time>2021-05-09T08:00:00Z</BsWfs:Time>
                <BsWfs:ParameterName>WeatherSymbol3</BsWfs:ParameterName>
                <BsWfs:ParameterValue>3.0</BsWfs:ParameterValue>
            </BsWfs:BsWfsElement>
	</wfs:member>
	

</wfs:FeatureCollection>
""";
