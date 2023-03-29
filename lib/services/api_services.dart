import 'dart:convert';
import 'dart:io';

import 'package:ask_anything/constant/api_constant.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> getModels() async {
    try {
      var response = await http.get(Uri.parse("$BASE_URL/modelss"),
          headers: {"Authorization": "Bearer $API_KEY"});

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse["error"] != null) {
        print("jsonResponse['error'] ${jsonResponse["error"]["message"]}");
        throw HttpException(jsonResponse["error"]["message"]);
      }
      print("jsonResponse $jsonResponse");
    } catch (e) {
      print("error $e");
    }
  }
}