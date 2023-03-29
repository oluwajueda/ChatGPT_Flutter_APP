import 'dart:convert';
import 'dart:io';

import 'package:ask_anything/constant/api_constant.dart';
import 'package:http/http.dart' as http;

import '../models/models_model.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(Uri.parse("$BASE_URL/models"),
          headers: {"Authorization": "Bearer $API_KEY"});

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse["error"] != null) {
        print("jsonResponse['error'] ${jsonResponse["error"]["message"]}");
        throw HttpException(jsonResponse["error"]["message"]);
      }
      print("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        print("temp $value");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (e) {
      print("error $e");
      rethrow;
    }
  }
}
