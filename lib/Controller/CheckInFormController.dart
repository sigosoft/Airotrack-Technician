import 'dart:io';
import 'dart:typed_data';
import 'package:airotrackgit/Model/work_details_model.dart';
import 'package:airotrackgit/assets/resources/strings.dart';
import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/controller/home_controller.dart';
import 'package:airotrackgit/ui/job_details/job_details.dart';
import 'package:airotrackgit/ui/home/homeNew.dart';
import 'package:airotrackgit/ui/home/home.dart';
import 'package:airotrackgit/ui/utils/Functions/network_testing.dart';
import 'package:airotrackgit/ui/utils/Functions/on_dio_exception.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/NormalTextPoppins.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../assets/resources/colors.dart';
import '../ui/CheckInForm/widgets/choose_image_widget.dart';

class CheckInFormController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    debugPrint("CheckInFormController initialized");
  }

  @override
  void onClose() {
    debugPrint("CheckInFormController disposed");
    super.onClose();
  }

// the variables should be declared here
  bool isLoading = true;
  bool isCheckInLoading = false;
  Dio dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  WorkDetailsModel? workDetails;
  ImagePicker imagePicker = ImagePicker();
  XFile? selectedImage;
  XFile? selectedRcImage;
  PermissionStatus? cameraStatus;
  PermissionStatus? photosStatus;
  String pickedImage = "";
  String pickedRcImage = "";
  RxString qrCode = "".obs;
  final TextEditingController imeiController = TextEditingController();
  // variables must be declared below this line

  // Helper functions should be declared here

  String _getSafeString(String? value, String fallback) {
    if (value == null || value.isEmpty || value == "null") {
      return fallback;
    }
    return value;
  }

  String _getSafeImei() {
    final imeiFromServer = workDetails?.data?.details?.imei?.toString();

    // Priority: Typed -> Scanned -> Server
    if (imeiController.text.isNotEmpty) {
      return imeiController.text;
    }
    if (qrCode.value.isNotEmpty) {
      return qrCode.value;
    }
    if (imeiFromServer != null &&
        imeiFromServer != "null" &&
        imeiFromServer.isNotEmpty) {
      return imeiFromServer;
    }
    return "";
  }

  String _getSafeDeviceImage() {
    final deviceImage =
        workDetails?.data?.details?.images?.deviceImage?.toString();
    return _getSafeString(deviceImage, pickedImage);
  }

  String _getSafeRcImage() {
    final rcImage = workDetails?.data?.details?.images?.rcImage?.toString();
    return _getSafeString(rcImage, pickedRcImage);
  }

  bool _isFieldValid(String? value) {
    return value != null && value.isNotEmpty && value != "null";
  }

  bool _validateRequiredFields() {
    final productId = workDetails?.data?.details?.productId;
    final serviceType = workDetails?.data?.details?.serviceType;

    final deviceImage = _getSafeDeviceImage();
    final rcImage = _getSafeRcImage();

    // Only validate IMEI if productId is "1" AND serviceType is "1" or "3"
    bool isImeiValid = true;
    if (productId.toString() == "1" &&
        (serviceType.toString() == "1" || serviceType.toString() == "3")) {
      final imei = _getSafeImei();
      isImeiValid = imei.isNotEmpty;
    }

    return isImeiValid && _isFieldValid(deviceImage) && _isFieldValid(rcImage);
  }

  List<String> _getMissingFields() {
    final productId = workDetails?.data?.details?.productId;
    final serviceType = workDetails?.data?.details?.serviceType;
    debugPrint("Product ID: $productId");
    debugPrint("Service Type: $serviceType");

    final missingFields = <String>[];
    if (productId.toString() == "1" &&
        (serviceType.toString() == "1" || serviceType.toString() == "3")) {
      final imei = _getSafeImei();
      if (imei.isEmpty) {
        missingFields.add("IMEI");
      }
    }
    if (!_isFieldValid(_getSafeDeviceImage())) {
      missingFields.add("Device Image");
    }
    if (!_isFieldValid(_getSafeRcImage())) {
      missingFields.add("RC Image");
    }

    return missingFields;
  }

  void requestPermissions() async {
    debugPrint("Requesting permissions");
    cameraStatus = await Permission.camera.request();
    photosStatus = await Permission.photos.request();
    debugPrint("Camera permission: $cameraStatus");
    debugPrint("Photos permission: $photosStatus");
  }

  // Helper functions should be declared here

  Future<void> openCamera() async {
    try {
      cameraStatus = await Permission.camera.request();
      if (cameraStatus == PermissionStatus.granted) {
        final XFile? image = await imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 25,
          maxWidth: 720,
          maxHeight: 720,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image != null) {
          selectedImage = image;
          debugPrint("Image captured from camera: ${image.path}");
          Get.back(); // Close dialog
          pickedImage = image.path;
          update();
        }
      } else {
        showToast("Camera permission is required to capture photos");
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
      showToast("Failed to open camera: ${e.toString()}");
    }
  }

  Future<void> openGallery() async {
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
          imageQuality: 25,
          maxWidth: 720,
          maxHeight: 720,
        );
        if (image != null) {
          selectedImage = image;
          debugPrint("Image selected from gallery: ${image.path}");
          Get.back(); // Close existing dialog
          pickedImage = image.path;
          update();
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog("Gallery");
      } else {
        showToast("Permission is required to access gallery");
      }
    } catch (e) {
      debugPrint("Error selecting image: $e");
      showToast("Failed to open gallery: ${e.toString()}");
    }
  }

  Future<void> openCameraForRc() async {
    try {
      cameraStatus = await Permission.camera.request();
      if (cameraStatus == PermissionStatus.granted) {
        final XFile? image = await imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 25,
          maxWidth: 720,
          maxHeight: 720,
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
          status = await Permission.photos.request();
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
          imageQuality: 25,
          maxWidth: 720,
          maxHeight: 720,
        );
        if (image != null) {
          selectedRcImage = image;
          debugPrint("RC Image selected from gallery: ${image.path}");
          Get.back(); // Close existing dialog
          pickedRcImage = image.path;
          update();
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog("Gallery");
      } else {
        showToast("Permission is required to access gallery for RC");
      }
    } catch (e) {
      debugPrint("Error selecting RC image: $e");
      showToast("Failed to open gallery: ${e.toString()}");
    }
  }

  void _showPermissionSettingsDialog(String permissionName) {
    Get.dialog(
      AlertDialog(
        title: BoldTextPoppins(
          text: "$permissionName Permission Required",
          color: Colors.black,
          fontSize: 18,
        ),
        content: NormalTextPoppins(
          text:
              "Permission for $permissionName is permanently denied. Please enable it in the app settings to continue.",
          color: Colors.black,
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text("OPEN SETTINGS"),
          ),
        ],
      ),
    );
  }

  Widget buildImageBox(Size media, String imageUrl, bool isPicked) {
    debugPrint("Device Image URL: $imageUrl");
    debugPrint("Device Image isPicked: $isPicked");
    debugPrint("Device Image pickedImage: $pickedImage");
    return Container(
      height: media.width * 0.3,
      width: media.width * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: isPicked
          ? Image.file(File(pickedImage), fit: BoxFit.cover)
          : imageUrl.isNotEmpty && imageUrl != APIConfig.Image_URL
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      height: media.width * 0.1,
                      width: media.width * 0.1,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    debugPrint("Device Image Error: $error");
                    return const Icon(
                      Icons.image_not_supported,
                      color: colorPrimary,
                      size: 40,
                    );
                  },
                )
              : const Icon(
                  Icons.image_not_supported,
                  color: colorPrimary,
                  size: 40,
                ),
    );
  }

  Widget buildRcImageBox(Size media, String imageUrl, bool isPicked) {
    debugPrint("RC Image URL: $imageUrl");
    debugPrint("RC Image isPicked: $isPicked");
    debugPrint("RC Image pickedRcImage: $pickedRcImage");
    return Container(
      height: media.width * 0.3,
      width: media.width * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: isPicked
          ? Image.file(File(pickedRcImage), fit: BoxFit.cover)
          : imageUrl.isNotEmpty && imageUrl != APIConfig.Image_URL
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      height: media.width * 0.1,
                      width: media.width * 0.1,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    debugPrint("RC Image Error: $error");
                    return const Icon(
                      Icons.image_not_supported,
                      color: colorPrimary,
                      size: 40,
                    );
                  },
                )
              : const Icon(
                  Icons.image_not_supported,
                  color: colorPrimary,
                  size: 40,
                ),
    );
  }

  Widget buildAddImageBox(Size media) {
    return InkWell(
      onTap: () => showImageOptions(Get.context!, workDetails!),
      child: Container(
        height: media.width * 0.3,
        width: media.width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: greyFillColor,
        ),
        child: const Center(
          child: Icon(Icons.add, size: 40, color: colorPrimary),
        ),
      ),
    );
  }

  Widget buildAddRcImageBox(Size media) {
    return InkWell(
      onTap: () => showRcImageOptions(Get.context!, workDetails!),
      child: Container(
        height: media.width * 0.3,
        width: media.width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: greyFillColor,
        ),
        child: const Center(
          child: Icon(Icons.add, size: 40, color: colorPrimary),
        ),
      ),
    );
  }

  Future<bool> postCheckinData(
      {required String jobId,
      required String latitude,
      required String longitude,
      required String imei,
      required String deviceImage,
      required String rcImage}) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.checkIn;
      dio.options.headers["Authorization"] = "Bearer $token";
      Map<String, dynamic> formFields = {
        "job_id": jobId,
        "latitude": latitude,
        "longitude": longitude,
        "imei": imei,
        "device_serial_no": imei,
      };
      if (deviceImage.isNotEmpty && !deviceImage.startsWith('http')) {
        File imageFile = File(deviceImage);
        if (await imageFile.exists()) {
          // Compress image before upload
          imageFile = await _compressImage(imageFile);
          formFields["device_image"] = await MultipartFile.fromFile(
            imageFile.path,
            filename:
                "device_image_${DateTime.now().millisecondsSinceEpoch}.jpg",
          );
          debugPrint(
              "Sending device image as MultipartFile: ${imageFile.path}");
        } else {
          debugPrint("Device image file not found: ${imageFile.path}");
        }
      } else if (deviceImage.isNotEmpty && deviceImage.startsWith('http')) {
        formFields["device_image"] = deviceImage;
        debugPrint("Sending device image URL as String: $deviceImage");
      }
      if (rcImage.isNotEmpty && !rcImage.startsWith('http')) {
        File imageFile = File(rcImage);
        if (await imageFile.exists()) {
          // Compress RC image before upload
          imageFile = await _compressImage(imageFile);
          formFields["rc_image"] = await MultipartFile.fromFile(
            imageFile.path,
            filename: "rc_image_${DateTime.now().millisecondsSinceEpoch}.jpg",
          );
          debugPrint("Sending RC image as MultipartFile: ${imageFile.path}");
        } else {
          debugPrint("RC image file not found: ${imageFile.path}");
        }
      } else if (rcImage.isNotEmpty && rcImage.startsWith('http')) {
        formFields["rc_image"] = rcImage;
        debugPrint("Sending RC image URL as String: $rcImage");
      }
      FormData formData = FormData.fromMap(formFields);
      dio.options.headers['Content-Type'] = 'multipart/form-data';
      debugPrint("Form Data Fields:");
      debugPrint("  job_id: $jobId");
      debugPrint("  latitude: $latitude");
      debugPrint("  longitude: $longitude");
      debugPrint("  imei: $imei");
      debugPrint("  device_image: $deviceImage");
      debugPrint("  rc_image: $rcImage");
      final response = await dio.post(url, data: formData);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        showToast("Dio Exception without response: ${e.message}");
        debugPrint("Dio Exception without response: ${e.message}");
      }
      return false;
    } catch (e) {
      showToast("Unexpected Error: $e");
      debugPrint("Unexpected Error: $e");
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchWorkDetails(String id) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.workDetails;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {"job_id": id};
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        workDetails = WorkDetailsModel.fromJson(response.data);
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

  showImageOptions(BuildContext context, dynamic jobDetails) {
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
            text: Strings.chooseImage,
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
                        openCamera();
                      },
                      media: media,
                      icon: Icons.camera_alt,
                      text: Strings.camera),
                  ChooseImageWidget(
                      onTap: () {
                        openGallery();
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

  Future<void> checkIn(
      {required String jobId, required dynamic jobDetails}) async {
    if (isCheckInLoading) return; // Prevent multiple taps

    try {
      isCheckInLoading = true;
      update(['checkInButton']); // Update only the button area

      checkNetworkAndRedirectOffAll();
      debugPrint("Starting check-in process...");
      if (!_validateRequiredFields()) {
        final missingFields = _getMissingFields();
        final missingFieldsText = missingFields.join(", ");
        debugPrint(
            "Check-in failed: Missing required fields - $missingFieldsText");
        showToast(
            "Please provide the following fields before checking in: $missingFieldsText");
        isCheckInLoading = false;
        update(['checkInButton']); // Update only the button area
        return;
      }
      debugPrint("All required fields validated successfully");

      String currentLat = workDetails?.data?.details?.latitude ?? "";
      String currentLong = workDetails?.data?.details?.longitude ?? "";

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);
            currentLat = position.latitude.toString();
            currentLong = position.longitude.toString();
            debugPrint(
                "Using current location for check-in: $currentLat, $currentLong");
          } else {
            debugPrint(
                "Location permission denied. Using default/job location.");
          }
        } else {
          debugPrint("Location service disabled. Using default/job location.");
        }
      } catch (e) {
        debugPrint(
            "Error fetching current location: $e. Using default/job location.");
      }

      final result = await postCheckinData(
        jobId: jobId,
        latitude: currentLat,
        longitude: currentLong,
        imei: _getSafeImei(),
        deviceImage: _getSafeDeviceImage(),
        rcImage: _getSafeRcImage(),
      );
      if (result) {
        debugPrint("Check-in completed successfully");
        showToast("Check-in completed successfully");
        try {
          if (Get.isRegistered<HomeController>()) {
            final homeController = Get.find<HomeController>();
            await homeController.refreshHomeData("");
          }
        } catch (e) {
          debugPrint("Error refreshing home data: $e");
        }
        var role_id = await getSavedObject("role_id");
        if (role_id.toString() == "3") {
          Get.offAll(() => const Home());
        } else {
          Get.offAll(() => const HomeNew());
        }
        Future.delayed(Duration.zero, () {
          Get.to(() => JobDetails(
                jobDetails: jobDetails,
                isOngoing: true,
              ));
        });
      } else {
        debugPrint("Unable to check in. Please try again.");
        isCheckInLoading = false;
        update(['checkInButton']);
      }
    } catch (e) {
      debugPrint("Error in checkIn: ${e.toString()}");
      isCheckInLoading = false;
      update(['checkInButton']);
    }
  }

  Future<File> _compressImage(File imageFile) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      // Decode image
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        debugPrint("Failed to decode image");
        return imageFile;
      }
      int width = originalImage.width;
      int height = originalImage.height;
      if (width > 1080) {
        height = (height * 1080 / width).round();
        width = 1080;
      }
      img.Image resizedImage =
          img.copyResize(originalImage, width: width, height: height);
      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 30);
      String compressedPath =
          imageFile.path.replaceAll('.jpg', '_compressed.jpg');
      File compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);
      debugPrint(
          "Image compressed from ${imageBytes.length} to ${compressedBytes.length} bytes");
      return compressedFile;
    } catch (e) {
      debugPrint("Error compressing image: ${e.toString()}");
      return imageFile; // Return original if compression fails
    }
  }
}
