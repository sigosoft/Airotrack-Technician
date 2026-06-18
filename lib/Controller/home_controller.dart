import 'package:airotrackgit/Model/home_model_old.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/ui/utils/Functions/network_testing.dart';
import 'package:airotrackgit/ui/utils/Functions/on_dio_exception.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:airotrackgit/Model/MaintenanceModel.dart';
import 'package:airotrackgit/Model/home_model.dart';
import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/ui/login/view/login.dart';
import 'package:airotrackgit/ui/maintenance/maintenance.dart';
import 'package:airotrackgit/ui/no_internet/no_internet.dart';
import 'package:airotrackgit/ui/update/force_update.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../assets/resources/strings.dart';
import '../ui/utils/Widgets/NormalTextPoppins.dart';
import '../ui/utils/Widgets/YesButtonWidget.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    _requestLocationPermission();
    getMaintenanceAPI();
    super.onInit();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
      }
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
    }
  }

  // declare all the variable only here
  bool isLoading = true;
  Dio dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  dynamic homeData;
  List workTypes = ["Pending Works", "Ongoing Works", "Completed Works"];
  MaintenanceData? settings;

  // No variables should be declared below this line

  getMaintenanceAPI() async {
    checkNetworkAndRedirectOffAll();
    var role_id = await getSavedObject("role_id");
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String buildNumber = packageInfo.version;
      var url = APIConfig.BASE_URL + APIEndpoints.setting;
      if (await checkNetwork()) {
        var response = await dio.get(url);
        if (response.statusCode == 200) {
          settings = MaintenanceData.fromJson(response.data['data']);
          debugPrint(response.data.toString());
          if (settings != null && settings!.maintenance == 1) {
            Get.offAll(() => const MaintenanceScreen());
          } else if (settings!.androidUpdate == 1) {
            if (settings!.androidVersion.toString() != buildNumber) {
              Get.offAll(() => const ForceUpdate());
            } else {
              if (role_id.toString() == "3") {
                homeData = await fetchHomeDataOld("");
              } else {
                homeData = await fetchHomeData("");
              }
            }
          } else {
            if (role_id.toString() == "3") {
              homeData = await fetchHomeDataOld("");
            } else {
              homeData = await fetchHomeData("");
            }
          }
        }
      } else {
        Get.to(() => const NoInternet());
      }
    } catch (error) {
      if (error is DioException) {
        handleDioException(error);
      } else {
        showFlushBar(error.toString());
      }
    }
  }

  Future<HomeModel?> fetchHomeData(String serviceType) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.home;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {"service_type": serviceType};
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        homeData = HomeModel.fromJson(response.data);
        return homeData;
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint("Unexpected Error: $e $stackTrace");
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<HomeData?> fetchHomeDataOld(String serviceType) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.home;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {"service_type": serviceType};
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        final dynamic payload = response.data;
        Map<String, dynamic> source = <String, dynamic>{};
        if (payload is Map) {
          final Map<String, dynamic> root = Map<String, dynamic>.from(payload);
          final dynamic dataNode = root['data'];
          if (dataNode is Map) {
            final Map<String, dynamic> dataMap =
                Map<String, dynamic>.from(dataNode as Map);
            source = (dataMap['user'] is Map)
                ? Map<String, dynamic>.from(dataMap['user'] as Map)
                : (dataMap['technician'] is Map)
                    ? Map<String, dynamic>.from(dataMap['technician'] as Map)
                    : (dataMap['details'] is Map)
                        ? Map<String, dynamic>.from(dataMap['details'] as Map)
                        : dataMap;
          } else {
            source = root;
          }
        }
        homeData = HomeData.fromJson(source);
        debugPrint("Home Data: ${homeData?.toJson()}");
        debugPrint("Home Data: ${homeData?.userName}");
        return homeData;
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint("Unexpected Error: $e $stackTrace");
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }

  logoutAPI() async {
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
      var url = APIConfig.BASE_URL + APIEndpoints.logout;
      var token = getSavedObject('token') ?? "";
      dio.options.headers["Authorization"] = "Bearer $token";
      if (await checkNetwork()) {
        var response = await dio.get(url);
        if (response.statusCode == 200) {
          Get.back();
          showFlushBar(response.data['message']);
          removename('token');
          Get.offAll(() => const Login());
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
        } else {
          showFlushBar(error.response?.data['message']);
        }
      } else {
        showFlushBar(error.toString());
      }
    }
  }

  showAcceptJobDialog(BuildContext context, Work jobDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final media = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const BoldTextPoppins(
            text: Strings.acceptJobRequest,
            color: Colors.black,
            fontSize: 18,
          ),
          content: const NormalTextPoppins(
            text: Strings.areYouSureYouWantThisJob,
            color: Colors.black,
            fontSize: 14,
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: media.width * 0.025,
            vertical: media.height * 0.01,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: media.width * 0.025,
                vertical: media.height * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  YesButtonWidget(
                      onTap: () => Get.back(),
                      media: media,
                      text: Strings.no,
                      textColor: Colors.black,
                      buttonColor: lightBlue),
                  YesButtonWidget(
                      onTap: () => acceptJob(jobDetails),
                      media: media,
                      text: Strings.yes,
                      textColor: Colors.white,
                      buttonColor: colorPrimary),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final media = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: SvgPicture.asset("lib/assets/images/logout_icon.svg"),
          content: const NormalTextPoppins(
            text: Strings.areYouSureYouWantToLogout,
            color: Colors.black,
            fontSize: 14,
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: media.width * 0.025,
            vertical: media.height * 0.01,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: media.width * 0.025,
                vertical: media.height * 0.01,
              ),
              child: Row(
                children: [
                  YesButtonWidget(
                      onTap: () => Get.back(),
                      media: media,
                      text: Strings.no,
                      textColor: Colors.black,
                      buttonColor: lightBlue),
                  SizedBox(width: media.width * 0.03),
                  YesButtonWidget(
                      onTap: () => logoutAPI(),
                      media: media,
                      text: Strings.yes,
                      textColor: Colors.white,
                      buttonColor: colorPrimary),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> acceptJob(Work jobDetails) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.acceptWork;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {"job_id": jobDetails.id};
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        Get.back();
        showToast(response.data['message']);
        fetchHomeData("");
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint("Unexpected Error: $e $stackTrace");
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshHomeData([String serviceType = ""]) async {
    isLoading = true;
    update();
    try {
      // First check maintenance status
      checkNetworkAndRedirectOffAll();
      var role_id = await getSavedObject("role_id");
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String buildNumber = packageInfo.version;
      var url = APIConfig.BASE_URL + APIEndpoints.setting;
      
      if (await checkNetwork()) {
        var response = await dio.get(url);
        if (response.statusCode == 200) {
          settings = MaintenanceData.fromJson(response.data['data']);
          if (settings != null && settings!.maintenance == 1) {
            Get.offAll(() => const MaintenanceScreen());
            return;
          } else if (settings!.androidUpdate == 1) {
            if (settings!.androidVersion.toString() != buildNumber) {
              Get.offAll(() => const ForceUpdate());
              return;
            }
          }
          // If not in maintenance mode, fetch home data with current service type
          if (role_id.toString() == "3") {
            await fetchHomeDataOld(serviceType);
          } else {
            await fetchHomeData(serviceType);
          }
        }
      } else {
        Get.to(() => const NoInternet());
      }
    } catch (error) {
      if (error is DioException) {
        handleDioException(error);
      } else {
        showFlushBar(error.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }
}
