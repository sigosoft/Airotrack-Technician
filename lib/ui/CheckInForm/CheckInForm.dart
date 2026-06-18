import 'package:airotrackgit/Controller/CheckInFormController.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/ui/ScanDevices/Widgets/OpenScannerButton.dart';
import 'package:airotrackgit/ui/devices/qrview.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/CheckInButton.dart';
import 'package:airotrackgit/ui/utils/Widgets/CustomAppBar.dart';
import 'package:airotrackgit/ui/utils/Widgets/NormalTextPoppins.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../assets/resources/strings.dart';

class CheckInFormScreen extends StatelessWidget {
  final String jobId;
  final String productId;
  final String serviceType;
  final dynamic ongoingWorks;

  const CheckInFormScreen(
      {super.key,
      required this.jobId,
      required this.productId,
      required this.serviceType,
      required this.ongoingWorks});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: GetBuilder(
        init: CheckInFormController(),
        initState: (state) {
          debugPrint("Product Id: $productId");
          debugPrint("Service Type: $serviceType");
        },
        didChangeDependencies: (state) {
          state.controller?.fetchWorkDetails(jobId);
          if (Get.arguments != null) {
            state.controller?.qrCode.value = Get.arguments;
          }
        },
        builder: (controller) => controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: CustomAppBar(
                    title: Strings.checkInForm, onBack: () => Get.back()),
                body: RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchWorkDetails(jobId);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                    padding: EdgeInsets.all(media.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BoldTextPoppins(
                            text: Strings.registrationCertificate,
                            color: Colors.black,
                            fontSize: 15),
                        SizedBox(height: media.height * 0.01),
                        controller.workDetails?.data?.details?.images
                                        ?.rcImage !=
                                    null ||
                                controller.pickedRcImage.isNotEmpty
                            ? Row(
                                children: [
                                  controller.buildRcImageBox(
                                      media,
                                      APIConfig.Image_URL +
                                          (controller.workDetails?.data?.details
                                                  ?.images?.rcImage ??
                                              ""),
                                      controller.pickedRcImage.isNotEmpty),
                                  SizedBox(width: media.width * 0.03),
                                  controller.buildAddRcImageBox(media)
                                ],
                              )
                            : controller.buildAddRcImageBox(media),
                        SizedBox(height: media.height * 0.03),
                        const BoldTextPoppins(
                            text: Strings.devicePhoto,
                            color: Colors.black,
                            fontSize: 15),
                        const SizedBox(height: 8),
                        controller.workDetails?.data?.details?.images
                                        ?.deviceImage !=
                                    null ||
                                controller.pickedImage.isNotEmpty
                            ? Row(
                                children: [
                                  controller.buildImageBox(
                                      media,
                                      APIConfig.Image_URL +
                                          (controller.workDetails?.data?.details
                                                  ?.images?.deviceImage ??
                                              ""),
                                      controller.pickedImage.isNotEmpty),
                                  SizedBox(width: media.width * 0.03),
                                  controller.buildAddImageBox(media)
                                ],
                              )
                            : controller.buildAddImageBox(media),
                        SizedBox(height: media.height * 0.03),
                        productId.toString().trim() == "1" &&
                                (serviceType.toString().trim() == "1" ||
                                    serviceType.toString().trim() == "3")
                            ? const BoldTextPoppins(
                                text: Strings.scanDevice,
                                color: Colors.black,
                                fontSize: 15)
                            : const SizedBox.shrink(),
                        SizedBox(height: media.height * 0.01),
                        productId.toString().trim() == "1" &&
                                (serviceType.toString().trim() == "1" ||
                                    serviceType.toString().trim() == "3")
                            ? Column(
                                children: [
                                  OpenScannerButton(
                                    media: media,
                                    buttonColor: colorPrimary,
                                    onPressed: () async {
                                      final result = await Get.to(() =>
                                          const QRViewExample(
                                              fromCheckinForm: true));
                                      if (result != null) {
                                        debugPrint('QR Code Result: $result');
                                        controller.qrCode.value = result;
                                      }
                                    },
                                  ),
                                  SizedBox(height: media.height * 0.015),
                                  const Center(
                                    child: NormalTextPoppins(
                                        text: "OR",
                                        color: Colors.grey,
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: media.height * 0.015),
                                  TextField(
                                      controller: controller.imeiController,
                                      onChanged: (value) {
                                        // Force refresh to update the IMEI label via update()
                                        // if qrCode was empty but now there's manual text.
                                        // Or we can just rely on the displayed logic.
                                        if (controller.qrCode.value.isEmpty) {
                                          controller.update();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        hintText: Strings.enterImei,
                                        hintStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Poppins-Regular'),
                                        fillColor: textFieldFillColor,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: media.width * 0.03,
                                          vertical: media.height * 0.015,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: colorPrimary),
                                        ),
                                      )),
                                ],
                              )
                            : const SizedBox.shrink(),
                        SizedBox(height: media.height * 0.03),
                        productId.toString().trim() == "1" &&
                                (serviceType.toString().trim() == "1" ||
                                    serviceType.toString().trim() == "3")
                            ? Obx(() {
                                // Access the observable immediately to prevent Obx error
                                final scannedImei = controller.qrCode.value;
                                final productId = controller
                                    .workDetails?.data?.details?.productId
                                    .toString();
                                final imeiFromServer = controller
                                    .workDetails?.data?.details?.imei
                                    .toString();

                                if (productId == "1" || productId == "3") {
                                  // Priority: Typed -> Scanned -> Server
                                  String displayedImei = "";
                                  if (controller
                                      .imeiController.text.isNotEmpty) {
                                    displayedImei =
                                        controller.imeiController.text;
                                  } else if (scannedImei.isNotEmpty) {
                                    displayedImei = scannedImei;
                                  } else if (imeiFromServer != null &&
                                      imeiFromServer != "null" &&
                                      imeiFromServer.isNotEmpty) {
                                    displayedImei = imeiFromServer;
                                  }

                                  if (displayedImei.isNotEmpty) {
                                    return Row(
                                      children: [
                                        const NormalTextPoppins(
                                            text: "IMEI :",
                                            color: Colors.black,
                                            fontSize: 15),
                                        SizedBox(width: media.width * 0.03),
                                        NormalTextPoppins(
                                            text: displayedImei,
                                            color: Colors.black,
                                            fontSize: 15),
                                      ],
                                    );
                                  }
                                }
                                return const SizedBox.shrink();
                              })
                            : const SizedBox.shrink(),
                        SizedBox(height: media.height * 0.03),
                        GetBuilder<CheckInFormController>(
                          id: 'checkInButton',
                          builder: (ctrl) => ctrl.isCheckInLoading
                              ? SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    height: media.height * 0.06,
                                    width: media.width * 0.4,
                                    padding: EdgeInsets.symmetric(
                                        vertical: media.height * 0.015),
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : CheckInButton(
                                  media: media,
                                  buttonText: Strings.checkIn,
                                  onTap: () async {
                                    await controller.checkIn(
                                        jobId: jobId, jobDetails: ongoingWorks);
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                 )),
              ),
      ),
    );
  }
}
