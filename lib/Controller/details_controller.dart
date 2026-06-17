import 'package:airotrackgit/Model/details_details.dart';
import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/ui/no_internet/no_internet.dart';
import 'package:airotrackgit/ui/server/serverdown.dart';
import 'package:airotrackgit/ui/utils/Functions/network_testing.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;

class DetailsController extends GetxController {
  bool isLoading = false;
  Dio dio = Dio();
  List<Command> commands = [];
  DeviceDetails? deviceDetails;

  getDeatils(
    String imei,
  ) async {
    checkNetworkAndRedirectOffAll();
    try {
      isLoading = true;
      update();
      var token = getSavedObject('token') ?? "";
      var url = APIConfig.BASE_URL + APIEndpoints.deviceDetails;

      dio.options.headers["Authorization"] = "Bearer $token";
      if (await checkNetwork()) {
        var response = await dio.get(url, queryParameters: {
          "imei": imei,
        });
        debugPrint("URL: $url");
        debugPrint("queryParameters: $imei");
        debugPrint("Response: ${response.data}");
        if (response.statusCode == 200) {
          if (response.data['data']['device_details'] != null) {
            deviceDetails =
                DeviceDetails.fromJson(response.data['data']['device_details']);
            commands.clear();
            response.data['data']['commands']
                .map((e) => commands.add(Command.fromJson(e)))
                .toList();
          }
          update();
        }
      } else {
        Get.to(() => const NoInternet());
      }
    } catch (error) {
      if (error is DioException) {
        print(error.response?.data);
        if (error.response?.data['message'] is Map) {
          Map<String, dynamic> message = error.response?.data['message'];
          showErrorToast(message);
        } else if (error.response?.statusCode == 500) {
          Get.offAll(() => const ServerDown());
        } else {
          showFlushBar(error.response?.data['message']);
        }
      } else {
        showFlushBar(error.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  getDeatilsWithId(
    String id,
  ) async {
    checkNetworkAndRedirectOffAll();
    try {
      isLoading = true;
      update();
      var token = getSavedObject('token') ?? "";
      var url = APIConfig.BASE_URL + APIEndpoints.deviceDetailswithId;
      dio.options.headers["Authorization"] = "Bearer $token";
      if (await checkNetwork()) {
        var response = await dio.get(url, queryParameters: {
          "imei": id,
        });
        if (response.statusCode == 200) {
          if (response.data['data']['device_details'] != null) {
            deviceDetails =
                DeviceDetails.fromJson(response.data['data']['device_details']);
            commands.clear();
            response.data['data']['commands']
                .map((e) => commands.add(Command.fromJson(e)))
                .toList();
          }
          update();
        }
      } else {
        Get.to(() => const NoInternet());
      }
    } catch (error) {
      if (error is DioException) {
        print(error.response?.data);
        if (error.response?.data['message'] is Map) {
          Map<String, dynamic> message = error.response?.data['message'];
          showErrorToast(message);
        } else if (error.response?.statusCode == 500) {
          Get.offAll(() => const ServerDown());
        } else {
          showFlushBar(error.response?.data['message']);
        }
      } else {
        showFlushBar(error.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  sendCommands(String imei, String command) async {
    checkNetworkAndRedirectOffAll();
    try {
      showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) {
            return Center(
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                padding: const EdgeInsets.all(10),
                child: const CircularProgressIndicator(),
              ),
            );
          });
      var token = getSavedObject('token') ?? "";
      var url = APIConfig.BASE_URL + APIEndpoints.sendCommand;
      FormData data = FormData.fromMap({"imei": imei, "command": command});
      dio.options.headers["Authorization"] = "Bearer $token";
      if (await checkNetwork()) {
        var response = await dio.post(url, data: data);
        if (response.statusCode == 200) {
          Get.back();
          showFlushBar(response.data['message']);
        }
      } else {
        Get.to(() => const NoInternet());
      }
    } catch (error) {
      Get.back();
      if (error is DioException) {
        if (error.response?.data['message'] is Map) {
          Map<String, dynamic> message = error.response?.data['message'];
          showErrorToast(message);
        } else if (error.response?.statusCode == 500) {
          Get.offAll(() => const ServerDown());
        } else {
          showFlushBar(error.response?.data['message']);
        }
      } else {
        showFlushBar(error.toString());
      }
    }
  }

  // Future<void> getCommands(String modelName) async {
  //   try {
  //     isLoading = true;
  //     var token = getSavedObject('token') ?? "";
  //     var url = APIConfig.BASE_URL + APIEndpoints.command;
  //     dio.options.headers["Authorization"] = "Bearer $token";
  //     print(url);
  //     FormData body = FormData.fromMap({
  //       "model_name": modelName,
  //     });
  //     var response = await dio.get(url, data: body);
  //     print(response.data);
  //     if (response.statusCode == 200) {
  //       response.data['data']['commands']
  //           .map((e) => commands.add(Command.fromJson(e)))
  //           .toList();
  //       isLoading = false;
  //       update();
  //     }
  //   } catch (e) {
  //     if (e is DioException) {
  //       print(e.response!.data);
  //       // Map<String, dynamic> message = e.response?.data['message'];
  //       // showErrorToast(message);
  //     } else {
  //       showFlushBar(e.toString());
  //     }
  //   }
  // }
}
