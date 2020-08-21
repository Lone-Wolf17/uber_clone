import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uber_rider/src/model/place_item_res.dart';
import 'package:uber_rider/src/model/step_res.dart';
import 'package:uber_rider/src/util/protected_data.dart';

String dfsdfadf =
    "https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&sensor=false&mode=driving&key=$google_maps_api_key";

class PlaceService {
  static Future<List<PlaceItemRes>> searchPlace(String keyWord) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$google_maps_api_key&language=pt&query=" +
            Uri.encodeQueryComponent(keyWord);

    print("search >>: " + url);
    var res = await http.get(url);
    if (res.statusCode == 200) {
      print(res.body);
      return PlaceItemRes.fromJson(json.decode(res.body));
    } else {
      return List();
    }
  }

  static Future<dynamic> getStep(
      double lat, double lng, double tolat, double tolng) async {
    String str_origin = "origin=" + lat.toString() + "," + lng.toString();
    // destination of route
    String str_dest =
        "destination=" + tolat.toString() + "," + tolng.toString();
    //sensor enabled
    String sensor = "sensor=false";
    String mode = "mode=driving";
    //building the parameters to the web service
    String parameters = str_origin + "&" + str_dest + "&" + sensor + "&" + mode;
    //output format
    String output = "json";
    //building the url to the webservice
    String url = "https://maps.googleapis.com/maps/api/directions/" +
        output +
        "?origin=" +
        parameters +
        "&key=$google_maps_api_key";
    final JsonDecoder _decoder = JsonDecoder();
    return http.get(url).then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        res = "{\"status\":" +
            statusCode.toString() +
            ",\"message\":\"error\",\"response\":" +
            res +
            "}";
        throw Exception(res);
      }

      List<StepRes> steps;
      try {
        steps =
            _parseSteps(_decoder.convert(res)["routes"][0]["legs"][0]["steps"]);
      } catch (e) {
        throw new Exception(res);
      }
    });
  }

  static List<StepRes> _parseSteps(final responseBody) {
    var list =
        responseBody.map<StepRes>((json) => StepRes.fromJson(json)).toList();

    return list;
  }
}
