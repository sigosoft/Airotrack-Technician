import 'dart:io';

import 'package:airotrackgit/Controller/CreateNewWorkController.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/ui/CreateNewWork/Widgets/rto_dropdown.dart';
import 'package:airotrackgit/ui/CreateNewWork/Widgets/search_location.dart';
import 'package:airotrackgit/ui/CreateNewWork/Widgets/imei_searchField.dart';
import 'package:airotrackgit/ui/utils/Widgets/CheckInButton.dart';
import 'package:airotrackgit/ui/utils/Widgets/CustomAppBar.dart';
import 'package:airotrackgit/ui/utils/Widgets/NormalTextPoppins.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../assets/resources/strings.dart';
import 'Widgets/CountryCodeAndMobile.dart';
import 'Widgets/CreateNewWorkDropDown.dart';
import 'Widgets/CreateNewWorkTextField.dart';
import 'Widgets/LabelTextWidget.dart';
import 'Widgets/vehicle_dropdown.dart';

class CreateNewWorkScreen extends StatelessWidget {
  const CreateNewWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: GetBuilder(
        init: CreateNewWorkController(),
        didChangeDependencies: (state) {
          state.controller?.fetchRtoDetails();
          state.controller?.fetchImeiDetails();
          state.controller?.fetchVehicleList();
        },
        builder: (controller) => Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
              title: Strings.createNewWork, onBack: () => Get.back()),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchRtoDetails();
              await controller.fetchImeiDetails();
              await controller.fetchVehicleList();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(media.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LabelTextWidget(label: Strings.productName),
                SizedBox(height: media.height * 0.005),
                CreateNewWorkDropDown(
                  media: media,
                  hintText: Strings.pickAProduct,
                  items: controller.productList,
                  value: controller.selectedProduct,
                  onChanged: (value) =>
                      controller.onProductDropDownChange(value ?? ""),
                ),
                SizedBox(height: media.height * 0.018),
                const LabelTextWidget(label: Strings.workType),
                SizedBox(height: media.height * 0.005),
                CreateNewWorkDropDown(
                  media: media,
                  hintText: Strings.selectWorkType,
                  items: controller.workTypes,
                  value: controller.selectedWorkType,
                  onChanged: (value) =>
                      controller.onWorkTypeDropDownChange(value ?? ""),
                ),
                SizedBox(height: media.height * 0.018),
                const LabelTextWidget(label: Strings.selectRto),
                SizedBox(height: media.height * 0.005),
                RtoSearchField(
                    media: media,
                    hintText: Strings.selectRto,
                    items: controller.rtoList,
                    value: controller.selectedRto,
                    onChanged: (value) {
                      controller.selectedRto = value;
                    }),
                SizedBox(height: media.height * 0.018),
                const LabelTextWidget(label: Strings.selectVehicle),
                SizedBox(height: media.height * 0.005),
                VehicleDropdown(
                  media: media,
                  hintText: Strings.selectVehicle,
                  items: controller.vehicleList,
                  value: controller.selectedVehicle,
                  onChanged: (value) => controller.onVehicleSelected(value),
                ),
                SizedBox(height: media.height * 0.018),
                controller.selectedProduct == "Airotrack Gps" &&
                        controller.selectedWorkType == "New"
                    ? const LabelTextWidget(label: Strings.rcImage)
                    : const SizedBox.shrink(),
                controller.selectedProduct == "Airotrack Gps" &&
                        controller.selectedWorkType == "New"
                    ? SizedBox(height: media.height * 0.005)
                    : const SizedBox.shrink(),
                controller.selectedProduct == "Airotrack Gps" &&
                        controller.selectedWorkType == "New"
                    ? (controller.pickedRcImage.isEmpty
                        ? controller.buildAddImageBox(media)
                        : controller.buildImageBox(
                            File(controller.pickedRcImage), media))
                    : const SizedBox.shrink(),
                controller.selectedProduct == "Airotrack Gps" &&
                        controller.selectedWorkType == "New"
                    ? SizedBox(height: media.height * 0.018)
                    : const SizedBox.shrink(),
                controller.selectedProduct == "Airotrack Gps" &&
                        (controller.selectedWorkType == "Repair" ||
                            controller.selectedWorkType == "Replacement")
                    ? const LabelTextWidget(label: Strings.selectIMEINumber)
                    : const SizedBox.shrink(),
                controller.selectedProduct == "Airotrack Gps" &&
                        (controller.selectedWorkType == "Repair" ||
                            controller.selectedWorkType == "Replacement")
                    ? SizedBox(height: media.height * 0.005)
                    : const SizedBox.shrink(),
                controller.selectedProduct == "Airotrack Gps" &&
                        (controller.selectedWorkType == "Repair" ||
                            controller.selectedWorkType == "Replacement")
                    ? ImeiSearchField(
                        controller: controller.imeiSearchController,
                        hintText: Strings.searchIMEIorVehicle,
                        media: media,
                        items: controller.imeiList,
                        onChanged: (value) => controller.onImeiSelected(value))
                    : const SizedBox.shrink(),
                controller.selectedProduct == "Airotrack Gps" &&
                        controller.selectedWorkType == "Repair"
                    ? SizedBox(height: media.height * 0.018)
                    : const SizedBox.shrink(),
                (controller.selectedProduct == "Camera" ||
                            controller.selectedProduct == "Speed Governor") &&
                        (controller.selectedWorkType == "Repair" ||
                            controller.selectedWorkType == "Replacement")
                    ? const LabelTextWidget(label: Strings.vehicleNumber)
                    : const SizedBox.shrink(),
                (controller.selectedProduct == "Camera" ||
                            controller.selectedProduct == "Speed Governor") &&
                        (controller.selectedWorkType == "Repair" ||
                            controller.selectedWorkType == "Replacement")
                    ? SizedBox(height: media.height * 0.005)
                    : const SizedBox.shrink(),
                (controller.selectedProduct == "Camera" ||
                            controller.selectedProduct == "Speed Governor") &&
                        (controller.selectedWorkType == "Repair" ||
                            controller.selectedWorkType == "Replacement")
                    ? ImeiSearchField(
                        controller: controller.imeiSearchController,
                        hintText: Strings.searchIMEIorVehicle,
                        media: media,
                        items: controller.imeiList,
                        onChanged: (value) => controller.onImeiSelected(value))
                    : const SizedBox.shrink(),
                (controller.selectedProduct == "Camera" ||
                            controller.selectedProduct == "Speed Governor") &&
                        (controller.selectedWorkType == "Repair" ||
                            controller.selectedWorkType == "Replacement")
                    ? SizedBox(height: media.height * 0.018)
                    : const SizedBox.shrink(),
                const LabelTextWidget(label: Strings.customerName),
                SizedBox(height: media.height * 0.005),
                CreateNewWorkTextField(
                    controller: controller.customerNameController,
                    hintText: Strings.enterCustomerName,
                    media: media),
                const SizedBox(height: 16),
                const LabelTextWidget(label: Strings.mobileNumber),
                SizedBox(height: media.height * 0.005),
                CountryCodeAndMobile(
                    media: media,
                    controller: controller.mobileNumberController),
                SizedBox(height: media.height * 0.018),
                const LabelTextWidget(label: Strings.vehicleNumber2),
                SizedBox(height: media.height * 0.005),
                CreateNewWorkTextField(
                    controller: controller.vehicleNumberController,
                    hintText: Strings.vehicleNumber2,
                    media: media),
                SizedBox(height: media.height * 0.018),
                const LabelTextWidget(label: Strings.location),
                SizedBox(height: media.height * 0.005),
                SearchLocationField(
                    media: media,
                    hintText: Strings.searchLocation,
                    controller: controller.locationController),
                SizedBox(height: media.height * 0.018),
                InkWell(
                  onTap: () async => await controller.onChooseOnMapTap(),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: colorPrimary),
                      SizedBox(width: media.width * 0.02),
                      const NormalTextPoppins(
                          text: Strings.chooseOnMap,
                          color: colorPrimary,
                          fontSize: 15)
                    ],
                  ),
                ),
                SizedBox(height: media.height * 0.04),
                CheckInButton(
                    onTap: () => controller.onCreateWorkButtonTap(),
                    media: media,
                    buttonText: Strings.createWork)
              ],
            ),
          )),
        ),
      ),
    );
  }
}
