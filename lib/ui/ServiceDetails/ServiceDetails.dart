import 'package:airotrackgit/Controller/JobDetailsController.dart';
import 'package:airotrackgit/ui/ServiceDetails/Widgets/ServiceDetailsTextFiedl.dart';
import 'package:airotrackgit/ui/ServiceDetails/Widgets/speed_governor_search_field.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/CheckInButton.dart';
import 'package:airotrackgit/ui/utils/Widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../assets/resources/strings.dart';
import '../CreateNewWork/Widgets/LabelTextWidget.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen(
      {super.key, required this.jobId, required this.amount});
  final String jobId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return SafeArea(
        top: false,
        child: Scaffold(
          appBar: CustomAppBar(
              title: Strings.serviceDetails, onBack: () => Get.back()),
          body: GetBuilder<JobDetailsController>(
            init: JobDetailsController(),
            initState: (state) {
              debugPrint(
                  "Product Id: ${state.controller?.productId.toString()}");
            },
            didChangeDependencies: (state) {
              state.controller?.getServiceDetails(jobId);
              state.controller?.getSpeedGovernorDetails();
            },
            builder: (controller) => RefreshIndicator(
              onRefresh: () async {
                await controller.getServiceDetails(jobId);
                await controller.getSpeedGovernorDetails();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(media.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LabelTextWidget(label: Strings.engineNumber),
                    SizedBox(height: media.height * 0.005),
                    ServiceDetailsTextField(
                        controller: controller.engineNumberController,
                        hintText: Strings.enterEngineNumber,
                        media: media),
                    SizedBox(height: media.height * 0.018),
                    const LabelTextWidget(label: Strings.chassisNumber),
                    SizedBox(height: media.height * 0.005),
                    ServiceDetailsTextField(
                        controller: controller.chassisNumberController,
                        hintText: Strings.enterChassisNumber,
                        media: media),
                    controller.productId.toString() == "2" ||
                            controller.productId.toString() == "3"
                        ? SizedBox(height: media.height * 0.018)
                        : const SizedBox.shrink(),
                    (controller.productId.toString() == "2" ||
                            controller.productId.toString() == "3")
                        ? const LabelTextWidget(
                            label: Strings.deviceSerialNumber)
                        : const SizedBox.shrink(),
                    (controller.productId.toString() == "2" ||
                            controller.productId.toString() == "3")
                        ? SizedBox(height: media.height * 0.005)
                        : const SizedBox.shrink(),
                    (controller.productId.toString() == "2" ||
                            controller.productId.toString() == "3")
                        ? ServiceDetailsTextField(
                            controller: controller.deviceSerialNumberController,
                            hintText: Strings.enterDeviceSerialNumber,
                            media: media)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "2"
                        ? SizedBox(height: media.height * 0.018)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "2"
                        ? const LabelTextWidget(label: Strings.cameraName)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "2"
                        ? SizedBox(height: media.height * 0.005)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "2"
                        ? ServiceDetailsTextField(
                            controller: controller.cameraNameController,
                            hintText: Strings.cameraName,
                            media: media)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "3"
                        ? SizedBox(height: media.height * 0.018)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "3"
                        ? const LabelTextWidget(label: Strings.speedGovernorId)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "3"
                        ? SizedBox(height: media.height * 0.005)
                        : const SizedBox.shrink(),
                    controller.productId.toString() == "3"
                        ? SpeedGovernorSearchField(
                            hintText: Strings.speedGovernorId,
                            items: controller.speedGovernorDetails?.data
                                    ?.speedGovernors ??
                                [],
                            onChanged: (value) => controller
                                .speedGovernorIdController
                                .text = value?.id.toString() ?? "",
                            media: media,
                          )
                        : const SizedBox.shrink(),
                    SizedBox(height: media.height * 0.018),
                    const BoldTextPoppins(
                        text: Strings.vehicleImage,
                        color: Colors.black,
                        fontSize: 15),
                    SizedBox(height: media.height * 0.01),
                    controller.vehicleImages.isNotEmpty ||
                            controller.pickedVehicleImage.isNotEmpty
                        ? Row(
                            children: [
                              controller.buildImageBox(
                                  controller.vehicleImages.isNotEmpty
                                      ? controller.vehicleImages[0]
                                      : "",
                                  media,
                                  controller.pickedVehicleImage.isNotEmpty,
                                  true),
                              SizedBox(width: media.width * 0.03),
                              controller.buildAddImageBox(media, true),
                            ],
                          )
                        : controller.buildAddImageBox(media, true),
                    (controller.productId.toString() == "2")
                        ? SizedBox(height: media.height * 0.01)
                        : const SizedBox.shrink(),
                    (controller.productId.toString() == "2")
                        ? const BoldTextPoppins(
                            text: Strings.cameraView,
                            color: Colors.black,
                            fontSize: 15)
                        : const SizedBox.shrink(),
                    (controller.productId.toString() == "2")
                        ? SizedBox(height: media.height * 0.01)
                        : const SizedBox.shrink(),
                    (controller.productId.toString() == "2")
                        ? controller.cameraImages.isNotEmpty ||
                                controller.pickedCameraImage.isNotEmpty
                            ? Row(
                                children: [
                                  controller.buildImageBox(
                                      controller.cameraImages.isNotEmpty
                                          ? controller.cameraImages[0]
                                          : "",
                                      media,
                                      controller.pickedCameraImage.isNotEmpty,
                                      false),
                                  SizedBox(width: media.width * 0.03),
                                  controller.buildAddImageBox(media, false),
                                ],
                              )
                            : controller.buildAddImageBox(media, false)
                        : const SizedBox.shrink(),
                    SizedBox(height: media.height * 0.018),
                    CheckInButton(
                      media: media,
                      buttonText: Strings.goToPayment,
                      onTap: () =>
                          controller.updateServiceDetails(amount, jobId),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
