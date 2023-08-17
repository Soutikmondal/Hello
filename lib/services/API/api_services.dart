import 'dart:convert';
import 'dart:developer';

import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../constants/api_constants.dart';

class ApiServices {
  static Future<void> uploadVitals(
      {required String tempurature,
      required String resprate,
      required String pulse,
      required String bldPres,
      required String entrydate,
      required String testdate}) async {
    try {
      var response = await http.post(
        Uri.parse("$BASE_URL1/add-general-examination"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "pat_id": "VBCR0190810200002",
          "temperature": tempurature,
          "resp-rate": resprate,
          "pulse": resprate,
          "blood-pressure": bldPres,
          "pulse-oximeter": entrydate,
          "testdate": "2021-04-20"
        }),
      );
      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] != "success") {
        throw io.HttpException('Error:${jsonResponse["message"]}');
      } else {
        // await showErrorDialog(context, jsonResponse['message']);
        print("message: $jsonResponse['message']");
      }
    } catch (e) {
      log("error $e");
      rethrow;
    }
  }

  static Future<void> uploadComplaint({
    required String comp1,
    required String comp2,
    required String comp3,
    required String dur1,
    required String dur2,
    required String dur3,
    required String durUnit1,
    required String durUnit2,
    required String durUnit3,
  }) async {
    try {
      var response = await http.post(
        Uri.parse("$BASE_URL1/add-chief-complaints"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "pat_id": "VBCR0190810200002",
          "complain-1": comp1,
          "duration-1": dur1,
          "duration-unit-1": durUnit1,
          "complain-2": comp2,
          "duration-2": dur2,
          "duration-unit-2": durUnit2,
          "complain-3": comp3,
          "duration-3": dur3,
          "duration-unit-3": durUnit3,
          "report-link": "VBCR0191903220000a141650269151788.jpg"
        }),
      );
      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] != "success") {
        throw io.HttpException('Error:${jsonResponse["message"]}');
      } else {
        print("message: $jsonResponse['message']");
      }
    } catch (e) {
      log("error $e");
      rethrow;
    }
  }

  static Future<void> uploadPatientFile(
      {required String pat_id, required String path}) async {
    Image file = Image.file(io.File(path));

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$BASE_URL2/upload-file"),
      );
      request.headers['Authorization'] = 'Bearer $API_KEY';
      request.fields['pat_id'] = 'VBCR0192105200002';
      var picture = await http.MultipartFile.fromPath('file', path);
      request.files.add(picture);
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = String.fromCharCodes(responseData);

      print(result);
    // Dio dio = new Dio(); // with default Options

    // FormData formData = new FormData.fromMap({
    //   "file": await MultipartFile.fromFile(path),
    //   "pat_id": "1234",
    // });

    // var response = await dio.post("$BASE_URL2/upload-file", data: formData);

    // if (response.statusCode == 200) {
    //   //apiResponse.onSuccess(response.toString(), eventType);
    //   print("Image Uploaded");
    // } else {
    //   //apiResponse.onError('Failed to load post');
    //   print("Upload Failed");
    // }
  }
}
