import 'dart:io';

import 'package:airotrackgit/Model/Rto_model.dart';
import 'package:airotrackgit/Model/imei_model.dart';
import 'package:airotrackgit/Model/vehicle_details_model.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/assets/resources/strings.dart';
import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/ui/CheckInForm/widgets/choose_image_widget.dart';
import 'package:airotrackgit/ui/home/homeNew.dart';
import 'package:airotrackgit/ui/utils/Functions/network_testing.dart';
import 'package:airotrackgit/ui/utils/Functions/on_dio_exception.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/route_manager.dart';
import 'package:airotrackgit/ui/CreateNewWork/LocationPickerScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Top-level function for isolate processing
List<IMEIModel> _parseImeiList(List<dynamic> data) {
  return data
      .map((e) => IMEIModel.fromJson(e as Map<String, dynamic>?))
      .toList();
}

class CreateNewWorkController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint("CreateNewWorkController initialized");
  }

  @override
  void onClose() {
    debugPrint("CreateNewWorkController disposed");
    super.onClose();
  }

  final productList = ["Airotrack Gps", "Camera", "Speed Governor"];
  final workTypes = ["New", "Repair", "Replacement"];
  final rtoList = <RTOData>[];
  RTOData? selectedRto;
  String? selectedProduct = "";
  String? selectedWorkType = "";
  bool isLoading = false;
  Dio dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  int productId = 0;
  int workTypeId = 0;
  TextEditingController customerNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController vehicleTypeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String? latitude = "";
  String? longitude = "";
  String imei = "";
  IMEIModel? selectedImei;
  TextEditingController imeiSearchController = TextEditingController();
  ImagePicker imagePicker = ImagePicker();
  XFile? selectedRcImage;
  PermissionStatus? cameraStatus;
  PermissionStatus? photosStatus;
  String pickedRcImage = "";
  List<IMEIModel> imeiList = [];
  List<VehicleDetails> vehicleList = [];
  VehicleDetails? selectedVehicle;

  void onProductDropDownChange(String value) {
    selectedProduct = value;
    if (selectedProduct == "Airotrack Gps") {
      productId = 1;
    } else if (selectedProduct == "Camera") {
      productId = 2;
    } else if (selectedProduct == "Speed Governor") {
      productId = 3;
    }
    debugPrint("Product ID: $productId");
    debugPrint("Selected Product: $selectedProduct");
    update();
  }

  void onWorkTypeDropDownChange(String value) {
    selectedWorkType = value;
    if (selectedWorkType == "New") {
      workTypeId = 1;
    } else if (selectedWorkType == "Repair") {
      workTypeId = 2;
    } else if (selectedWorkType == "Replacement") {
      workTypeId = 3;
    }
    debugPrint("Work Type ID: $workTypeId");
    debugPrint("Selected Work Type: $selectedWorkType");
    update();
  }

  showRcImageOptions(BuildContext context, dynamic jobDetails) {
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
            text: "Choose RC Image",
            color: Colors.black,
            fontSize: 18,
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: media.width * 0.025,
            vertical: media.height * 0.01,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: media.width * 0.020,
                vertical: media.height * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChooseImageWidget(
                      onTap: () {
                        openCameraForRc();
                      },
                      media: media,
                      icon: Icons.camera_alt,
                      text: Strings.camera),
                  ChooseImageWidget(
                      onTap: () {
                        openGalleryForRc();
                      },
                      media: media,
                      icon: Icons.photo_library,
                      text: Strings.gallery),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> openCameraForRc() async {
    try {
      cameraStatus = await Permission.camera.request();
      if (cameraStatus == PermissionStatus.granted) {
        final XFile? image = await imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image != null) {
          selectedRcImage = image;
          debugPrint("RC Image captured from camera: ${image.path}");
          Get.back(); // Close dialog
          pickedRcImage = image.path;
          update();
        }
      } else {
        showToast("Camera permission is required to capture photos");
      }
    } catch (e) {
      debugPrint("Error capturing RC image: $e");
      showToast("Failed to open camera: ${e.toString()}");
    }
  }

  Future<void> openGalleryForRc() async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        // Check if either Photos or Storage permission is already granted
        var photosStatusCheck = await Permission.photos.status;
        var storageStatusCheck = await Permission.storage.status;

        if (photosStatusCheck.isGranted ||
            photosStatusCheck.isLimited ||
            storageStatusCheck.isGranted) {
          status = PermissionStatus.granted;
        } else {
          // Request Photos first (Android 13+)
          status = await Permission.photos.request();
          // If still not granted, request Storage
          if (!status.isGranted && !status.isLimited) {
            status = await Permission.storage.request();
          }
        }
      } else {
        status = await Permission.photos.status;
        if (!status.isGranted && !status.isLimited) {
          status = await Permission.photos.request();
        }
      }

      if (status.isGranted || status.isLimited) {
        final XFile? image = await imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) {
          selectedRcImage = image;
          debugPrint("RC Image selected from gallery: ${image.path}");
          Get.back();
          pickedRcImage = image.path;
          update();
        }
      } else {
        showToast("Permission is required to access photos from gallery");
      }
    } catch (e) {
      debugPrint("Error selecting RC image: $e");
      showToast("Failed to open gallery: ${e.toString()}");
    }
  }

  void onImeiSelected(IMEIModel? imeiModel) {
    selectedImei = imeiModel;
    if (imeiModel != null) {
      imei = imeiModel.imei ?? "";
      // Auto-fill vehicle number if available
      if (imeiModel.vehicleNo != null && imeiModel.vehicleNo!.isNotEmpty) {
        vehicleNumberController.text = imeiModel.vehicleNo!;
      }
      debugPrint("Selected IMEI: $imei, Vehicle: ${imeiModel.vehicleNo}");
    } else {
      imei = "";
      vehicleNumberController.clear();
    }
    update();
  }

  Future<void> onChooseOnMapTap() async {
    final result = await Get.to(() => const LocationPickerScreen());
    if (result != null && result is Map) {
      final dynamic latRaw = result['latitude'];
      final dynamic lngRaw = result['longitude'];
      final String resolvedLat = latRaw is String
          ? latRaw
          : (latRaw is num)
              ? latRaw.toString()
              : "";
      final String resolvedLng = lngRaw is String
          ? lngRaw
          : (lngRaw is num)
              ? lngRaw.toString()
              : "";
      latitude = resolvedLat;
      longitude = resolvedLng;
      locationController.text = (result['address'] as String?) ?? "";
      debugPrint("Latitude: $latitude");
      debugPrint("Longitude: $longitude");
      debugPrint("Address: ${locationController.text}");
      update();
    }
  }

  void onCreateWorkButtonTap() async {
    if (productId == 0) {
      showToast("Please select a product");
      return;
    } else if (workTypeId == 0) {
      showToast("Please select a work type");
      return;
    } else if (selectedProduct == "Airotrack Gps" &&
        selectedWorkType == "New" &&
        pickedRcImage == "") {
      showToast("Please add a RC image");
      return;
    } else if (selectedRto == null) {
      showToast("Please select a RTO");
      return;
    } else if (selectedVehicle == null) {
      showToast("Please select a vehicle");
      return;
    } else if (selectedProduct == "Airotrack Gps" &&
        (selectedWorkType == "Repair" || selectedWorkType == "Replacement") &&
        imei == "") {
      showToast("Please enter a IMEI number");
      return;
    } else if (customerNameController.text.isEmpty) {
      showToast("Please enter a customer name");
      return;
    } else if (mobileNumberController.text.isEmpty) {
      showToast("Please enter a mobile number");
      return;
    } else if (vehicleNumberController.text.isEmpty) {
      showToast("Please enter a vehicle number");
      return;
    } else if (locationController.text.isEmpty) {
      showToast("Please enter a location");
      return;
    } else if (latitude == null || longitude == null) {
      showToast("Please select a location on the map");
      return;
    } else {
      postNewWorkDetails(
          productId: productId.toString(),
          workType: workTypeId.toString(),
          imei: imei.toString(),
          customerName: customerNameController.text,
          vehicleNo: vehicleNumberController.text,
          vehicleType: vehicleTypeController.text,
          mobile: mobileNumberController.text,
          location: locationController.text,
          latitude: latitude.toString(),
          longitude: longitude.toString(),
          rcImage: pickedRcImage.isNotEmpty ? pickedRcImage : "",
          rtoId: selectedRto?.id?.toString() ?? "");
    }
  }

  Future<void> fetchRtoDetails() async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.fetchRto;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {};
      debugPrint("URL: $url");
      debugPrint("Query Parameters: ${dio.options.queryParameters}");
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        rtoList.clear();
        rtoList.addAll((response.data['data'] as List)
            .map((e) => RTOData.fromJson(e))
            .toList());
        if (rtoList.isNotEmpty) {
          selectedRto = rtoList.first;
        }
        update();
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchVehicleList() async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.vehicleTypes;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {};
      debugPrint("URL: $url");
      debugPrint("Query Parameters: ${dio.options.queryParameters}");
      final response = await dio.post(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        final dynamic dataNode = response.data['data'];
        List<dynamic> rawList = <dynamic>[];
        if (dataNode is Map) {
          if (dataNode['vehicle_details'] is List) {
            rawList = dataNode['vehicle_details'] as List;
          } else if (dataNode['vehicle_types'] is List) {
            rawList = dataNode['vehicle_types'] as List;
          } else if (dataNode['list'] is List) {
            rawList = dataNode['list'] as List;
          } else if (dataNode['data'] is List) {
            rawList = dataNode['data'] as List;
          }
        } else if (dataNode is List) {
          rawList = dataNode;
        }
        vehicleList.clear();
        vehicleList.addAll(rawList
            .map((e) => VehicleDetails.fromJson(e as Map<String, dynamic>?))
            .toList());

        if (vehicleList.isNotEmpty) {
          selectedVehicle = vehicleList.first;
          vehicleTypeController.text = selectedVehicle?.id?.toString() ?? "";
        } else {
          selectedVehicle = null;
          vehicleTypeController.clear();
        }
        update();
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e, stackTrace) {
      debugPrint("Unexpected Error: $e");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading = false;
      update();
    }
  }

  void onVehicleSelected(VehicleDetails? vehicle) {
    selectedVehicle = vehicle;
    vehicleTypeController.text = vehicle?.id?.toString() ?? "";
    update();
  }

  Future<void> fetchImeiDetails() async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.allDevices;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {
        "keyword": "",
      };
      debugPrint("URL: $url");
      debugPrint("Query Parameters: ${dio.options.queryParameters}");
      final response = await dio.get(url);
      debugPrint(
          "Response received with ${response.data['data']?.length ?? 0} items");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List;
        debugPrint("Parsing ${data.length} items in isolate...");
        final List<IMEIModel> parsedList = await compute(_parseImeiList, data);
        debugPrint("Parsed ${parsedList.length} items successfully");
        imeiList.clear();
        imeiList.addAll(parsedList);
        update();
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> postNewWorkDetails(
      {required String productId,
      required String workType,
      required String imei,
      required String customerName,
      required String vehicleNo,
      required String vehicleType,
      required String mobile,
      required String location,
      required String latitude,
      required String longitude,
      required String rcImage,
      required String rtoId}) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.postNewWorkDetails;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {};

      final Map<String, dynamic> payload = {
        "product_id": productId,
        "work_type": workType,
        "imei": imei,
        "customer_name": customerName,
        "vehicle_no": vehicleNo,
        "vehicle_type": vehicleType,
        "mobile": mobile,
        "location": location,
        "latitude": latitude,
        "longitude": longitude,
        "rto_id": rtoId,
      };

      if (rcImage.isNotEmpty) {
        payload["rc_image"] = await MultipartFile.fromFile(rcImage);
      }

      final formData = FormData.fromMap(payload);

      debugPrint("URL: $url");
      debugPrint(
          "Sending multipart form data with keys: ${payload.keys.toList()}");
      final response = await dio.post(url, data: formData);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        showToast(response.data['message']);
        Get.offAll(() => const HomeNew());
        update();
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Widget buildImageBox(File imageFile, Size media) {
    return InkWell(
      onTap: () => showRcImageOptions(Get.context!, null),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          imageFile,
          width: media.width * 0.25,
          height: media.height * 0.12,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildAddImageBox(Size media) {
    return InkWell(
        onTap: () => showRcImageOptions(Get.context!, null),
        child: Container(
          width: media.width * 0.25,
          height: media.height * 0.12,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: const Icon(Icons.add, size: 30, color: colorPrimary),
        ));
  }
}
