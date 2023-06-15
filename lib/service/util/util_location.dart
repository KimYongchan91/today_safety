import 'dart:convert';

import 'package:dart_geohash/dart_geohash.dart';
import 'package:today_safety/my_app.dart';
import 'package:today_safety/service/util/util_snackbar.dart';

import '../../const/model/model_location.dart';
import 'package:http/http.dart' as http;

Future<ModelLocation?> getModelLocationFromLatLng(double lat, double lng) async {
  ModelLocation modelLocation = ModelLocation.fromJson({});
  modelLocation.lat = lat;
  modelLocation.lng = lng;

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'KakaoAK de2c9d30f737be6f897916c21f92c156'
  };

  String url = 'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lng&y=$lat';
  MyApp.logger.d('url : $url ');
  //MyApp.logger.d('인코딩 url : ${Uri.encodeFull(url + query)}');

  try {
    var response = await http.get(Uri.parse(Uri.encodeFull(url)), headers: requestHeaders);

    if (response.statusCode != 200) {
      throw Exception("Request to $url failed with status ${response.statusCode}: ${response.body}");
    } else {
      //성공
      MyApp.logger.d('${response.body.toString()}');
      List<dynamic> listMapAddressData = jsonDecode(response.body)['documents'] ?? [];
      if (listMapAddressData.isEmpty) {
        throw Exception("empty listMapAddressData");
      }
      dynamic docFirst = listMapAddressData.first;

      modelLocation.addressLoad = docFirst['road_address']?['address_name'];
      modelLocation.addressJibun = docFirst['address']?['address_name'];
      modelLocation.addressBuildingName = docFirst['road_address']?['building_name'];

      modelLocation.si =
          docFirst['road_address']?['region_1depth_name'] ?? docFirst['address']?['region_1depth_name'];
      modelLocation.gu =
          docFirst['road_address']?['region_2depth_name'] ?? docFirst['address']?['region_2depth_name'];
      modelLocation.dong =
          docFirst['road_address']?['region_3depth_name'] ?? docFirst['address']?['region_3depth_name'];

      if (modelLocation.si == null || modelLocation.gu == null || modelLocation.dong == null) {
        throw Exception("empty si, gu, dong");
      }
    }
  } on Exception catch (e) {
    MyApp.logger.wtf("카카오 rest api 요청 실패 : ${e.toString()}");
    return null;
  }

  GeoHash geoHash7 = GeoHash.fromDecimalDegrees(modelLocation.lng!, modelLocation.lat!, precision: 7);

  modelLocation.gh7 = geoHash7.geohash;
  modelLocation.gh6 = geoHash7.geohash.substring(0, 6);
  modelLocation.gh5 = geoHash7.geohash.substring(0, 5);
  modelLocation.gh4 = geoHash7.geohash.substring(0, 4);

  return modelLocation;
}
