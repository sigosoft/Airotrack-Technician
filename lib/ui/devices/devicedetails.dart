import 'package:airotrackgit/ui/utils/utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/assets/resources/strings.dart';
import 'package:airotrackgit/Controller/details_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceDetail extends StatefulWidget {
  const DeviceDetail({super.key, this.imei, this.deviceId});

  final String? imei;
  final String? deviceId;

  @override
  State<DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<DeviceDetail> {
  Timer? _autoUpdateTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _autoUpdateTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _autoUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        if (Get.isRegistered<DetailsController>()) {
          final controller = Get.find<DetailsController>();
          if (widget.imei != null) {
            controller.getDeatils(widget.imei!.toString(), showLoading: false);
          } else if (widget.deviceId != null) {
            controller.getDeatilsWithId(widget.deviceId!.toString(),
                showLoading: false);
          }
        }
      }
    });
  }

  Future<bool> _showBackConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Go Back",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          content: const Text(
            "Are you sure you want to go back?",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Yes",
                style: TextStyle(color: colorPrimary),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<DetailsController>(
      init: DetailsController(),
      initState: (_) {},
      didChangeDependencies: (state) {
        debugPrint("widget.imei: ${widget.imei?.toString()}");
        debugPrint("widget.deviceId: ${widget.deviceId.toString()}");
        if (widget.imei != null) {
          state.controller?.getDeatils(widget.imei.toString());
        } else if (widget.deviceId != null) {
          state.controller?.getDeatils(widget.deviceId!.toString());
        }
      },
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await _showBackConfirmationDialog(context);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: colorPrimary,
              leading: InkWell(
                onTap: () {
                  Navigator.of(context).maybePop();
                },
                child: SvgPicture.asset('lib/assets/images/back.svg',
                    height: 20, width: 20, fit: BoxFit.scaleDown),
              ),
              title: const Text(
                Strings.devices,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins-Bold',
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : controller.deviceDetails == null
                    ? Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                                "lib/assets/images/device_error_id.png"),
                            const SizedBox(height: 7),
                            Text(
                                "Oops! We couldn't find a device ID. \nPlease enter the ID associated with your device to proceed.",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(letterSpacing: .5)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (widget.imei != null) {
                            await controller.getDeatils(widget.imei.toString());
                          } else if (widget.deviceId != null) {
                            await controller
                                .getDeatils(widget.deviceId!.toString());
                          }
                        },
                        child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 25, top: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            Strings.imei,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontFamily: 'Poppins-Light',
                                            ),
                                          ),
                                          Text(
                                            controller.deviceDetails?.imei
                                                    .toString() ??
                                                "id",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontFamily: 'Poppins-Light',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(
                                            right: 20, top: 15),
                                        child: SvgPicture.asset(
                                          "lib/assets/images/scan.svg",
                                          fit: BoxFit.fill,
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(
                                      left: 25, right: 25, bottom: 10),
                                  decoration: BoxDecoration(
                                      color: grey,
                                      border: Border.all(color: grey),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin:
                                              const EdgeInsets.only(right: 40),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "Data",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              SvgPicture.asset(
                                                'lib/assets/images/power.svg',
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                child: const Text(
                                                  Strings.power,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  controller.deviceDetails!
                                                              .power ==
                                                          1
                                                      ? "Primary"
                                                      : "Off",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: controller
                                                                .deviceDetails!
                                                                .power ==
                                                            1
                                                        ? Colors.green
                                                        : Colors.red),
                                                width: 20,
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, right: 20, top: 15),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 1,
                                          color: greylight,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              SvgPicture.asset(
                                                'lib/assets/images/gnss.svg',
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                child: const Text(
                                                  Strings.gnss,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  controller.deviceDetails!
                                                              .gnssFix ==
                                                          1
                                                      ? "Fixed"
                                                      : "Not fixed",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Icon(
                                                Icons.visibility,
                                                color: controller.deviceDetails!
                                                            .gnssFix ==
                                                        1
                                                    ? Colors.green
                                                    : Colors.black,
                                              )
                                              // Container(
                                              //   decoration: BoxDecoration(
                                              //       shape: BoxShape.circle,
                                              //       color: controller.deviceDetails!
                                              //                   .gnssFix ==
                                              //               1
                                              //           ? Colors.green
                                              //           : Colors.red),
                                              //   width: 20,
                                              //   height: 20,
                                              // ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, right: 20, top: 15),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 1,
                                          color: greylight,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              SvgPicture.asset(
                                                'lib/assets/images/schedule.svg',
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                child: const Text(
                                                  Strings.gsm,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "${Strings.date}: ",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins-Light',
                                                        ),
                                                      ),
                                                      Text(
                                                        controller.deviceDetails
                                                                ?.lastUpdateDate
                                                                .toString() ??
                                                            "",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins-Light',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "${Strings.time}: ",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins-Light',
                                                        ),
                                                      ),
                                                      Text(
                                                        controller.deviceDetails
                                                                ?.lastUpdateTime
                                                                .toString() ??
                                                            "",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins-Light',
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, right: 20, top: 15),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 1,
                                          color: greylight,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              SvgPicture.asset(
                                                'lib/assets/images/ignition.svg',
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                child: const Text(
                                                  Strings.ignition,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: controller
                                                                .deviceDetails!
                                                                .ignition ==
                                                            1
                                                        ? Colors.green
                                                        : Colors.red),
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              const SizedBox(
                                                height: 20,
                                                child: VerticalDivider(
                                                  color: Colors.grey,
                                                  thickness: 1,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  controller.deviceDetails!
                                                              .ignition ==
                                                          1
                                                      ? "On"
                                                      : "Off",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: const Text(
                                                  Strings.idea,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  controller.deviceDetails!
                                                      .primaryMobileNumber,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 2),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: const Text(
                                                  Strings.bsnl,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  controller.deviceDetails!
                                                      .secondaryMobileNumber,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 3),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: const Text(
                                                  Strings.currentOperation,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  controller.deviceDetails!
                                                      .simProvider,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        // Container(
                                        //   margin: const EdgeInsets.only(
                                        //       left: 15, right: 20, top: 5),
                                        //   width: MediaQuery.of(context).size.width,
                                        //   height: 1,
                                        //   color: greylight,
                                        // ),
                                        // Container(
                                        //   width: MediaQuery.of(context).size.width,
                                        //   height: 40,
                                        //   margin:
                                        //       const EdgeInsets.only(left: 10, top: 3),
                                        //   child: Row(
                                        //     children: [
                                        //       const SizedBox(
                                        //         width: 15,
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             MediaQuery.of(context).size.width *
                                        //                 0.3,
                                        //         child: const Text(
                                        //           Strings.activationDate,
                                        //           style: TextStyle(
                                        //             fontSize: 15,
                                        //             color: Colors.black,
                                        //             fontFamily: 'Poppins-Light',
                                        //           ),
                                        //           maxLines: 3,
                                        //         ),
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             MediaQuery.of(context).size.width *
                                        //                 0.06,
                                        //         child: const Text(
                                        //           " :",
                                        //           style: TextStyle(
                                        //             fontSize: 15,
                                        //             color: Colors.black,
                                        //             fontFamily: 'Poppins-Light',
                                        //           ),
                                        //           maxLines: 3,
                                        //         ),
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             MediaQuery.of(context).size.width *
                                        //                 0.3,
                                        //         child: Text(
                                        //           controller.deviceDetails!
                                        //                       .simActivationDate ==
                                        //                   null
                                        //               ? ""
                                        //               : DateFormat('dd MMM yyyy')
                                        //                   .format(controller
                                        //                       .deviceDetails!
                                        //                       .simActivationDate!),
                                        //           style: const TextStyle(
                                        //             fontSize: 15,
                                        //             color: Colors.black,
                                        //             fontFamily: 'Poppins-Light',
                                        //           ),
                                        //           maxLines: 3,
                                        //         ),
                                        //       )
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //   margin: const EdgeInsets.only(
                                        //       left: 15, right: 20, top: 5),
                                        //   width: MediaQuery.of(context).size.width,
                                        //   height: 1,
                                        //   color: greylight,
                                        // ),
                                        // Container(
                                        //   width: MediaQuery.of(context).size.width,
                                        //   height: 40,
                                        //   margin:
                                        //       const EdgeInsets.only(left: 10, top: 3),
                                        //   child: Row(
                                        //     children: [
                                        //       const SizedBox(
                                        //         width: 15,
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             MediaQuery.of(context).size.width *
                                        //                 0.3,
                                        //         child: const Text(
                                        //           Strings.expiryDate,
                                        //           style: TextStyle(
                                        //             fontSize: 15,
                                        //             color: Colors.black,
                                        //             fontFamily: 'Poppins-Light',
                                        //           ),
                                        //           maxLines: 3,
                                        //         ),
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             MediaQuery.of(context).size.width *
                                        //                 0.06,
                                        //         child: const Text(
                                        //           " :",
                                        //           style: TextStyle(
                                        //             fontSize: 15,
                                        //             color: Colors.black,
                                        //             fontFamily: 'Poppins-Light',
                                        //           ),
                                        //           maxLines: 3,
                                        //         ),
                                        //       ),
                                        //       SizedBox(
                                        //         width:
                                        //             MediaQuery.of(context).size.width *
                                        //                 0.3,
                                        //         child: Text(
                                        //           controller.deviceDetails!
                                        //                       .expirationtime ==
                                        //                   null
                                        //               ? ""
                                        //               : DateFormat('dd MMM yyyy')
                                        //                   .format(controller
                                        //                       .deviceDetails!
                                        //                       .expirationtime!),
                                        //           style: const TextStyle(
                                        //             fontSize: 15,
                                        //             color: Colors.black,
                                        //             fontFamily: 'Poppins-Light',
                                        //           ),
                                        //           maxLines: 3,
                                        //         ),
                                        //       )
                                        //     ],
                                        //   ),
                                        // ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, right: 20, top: 5),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 1,
                                          color: greylight,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 3),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: const Text(
                                                  Strings.location,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              double.parse(controller
                                                              .deviceDetails!
                                                              .latitude) ==
                                                          0.0 ||
                                                      double.parse(controller
                                                              .deviceDetails!
                                                              .longitude) ==
                                                          0.0
                                                  ? const SizedBox()
                                                  : SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          showDialog(
                                                              context:
                                                                  Get.context!,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return Center(
                                                                  child:
                                                                      Container(
                                                                    decoration: const BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .white),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                    child:
                                                                        const CircularProgressIndicator(),
                                                                  ),
                                                                );
                                                              });

                                                          if (double.parse(controller
                                                                      .deviceDetails!
                                                                      .latitude) ==
                                                                  0.0 ||
                                                              double.parse(controller
                                                                      .deviceDetails!
                                                                      .longitude) ==
                                                                  0.0) {
                                                            if (context
                                                                .mounted) {
                                                              showToast(
                                                                "Data was not received from the device.",
                                                              );
                                                            }
                                                          } else {
                                                            await launchUrl(
                                                                Uri.parse(
                                                                    'https://maps.google.com/?q=${controller.deviceDetails!.latitude},${controller.deviceDetails!.longitude}'));
                                                          }
                                                          Get.back();
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "lib/assets/images/googlemap.svg",
                                                              width: 20,
                                                              height: 20,
                                                            ),
                                                            const Text(
                                                              "Google Map",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins-Light',
                                                              ),
                                                              maxLines: 3,
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, right: 20, top: 5),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 1,
                                          color: greylight,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              left: 10, top: 3),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: const Text(
                                                  Strings.status,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: const Text(
                                                  " :",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              if (controller.deviceDetails!.alertId == '10' ||
                                                  controller.deviceDetails!
                                                          .alertId ==
                                                      '16' ||
                                                  controller.deviceDetails!
                                                          .alertId ==
                                                      '22') ...[
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.red),
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                  child: VerticalDivider(
                                                    color: Colors.grey,
                                                    thickness: 1,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                              ],
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  controller
                                                      .deviceDetails!.status,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins-Light',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(
                                      left: 25, right: 25, bottom: 10),
                                  decoration: BoxDecoration(
                                      color: grey,
                                      border: Border.all(color: grey),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin:
                                              const EdgeInsets.only(right: 20),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "Commander",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        ListView.separated(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 20),
                                            separatorBuilder: (_, i) =>
                                                const Divider(
                                                  color: Colors.grey,
                                                  thickness: 1,
                                                ),
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                controller.commands.length,
                                            itemBuilder: (_, i) {
                                              var command =
                                                  controller.commands[i];
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          command.command,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15),
                                                        ),
                                                        if (command.commandFor
                                                            .isNotEmpty)
                                                          Text(
                                                            command.commandFor,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        13),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                          height: 35,
                                                          child:
                                                              VerticalDivider(
                                                            color: Colors.grey,
                                                            thickness: 3,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12)),
                                                                backgroundColor:
                                                                    colorPrimary),
                                                            onPressed:
                                                                () async {
                                                              await controller
                                                                  .sendCommands(
                                                                      controller
                                                                          .deviceDetails!
                                                                          .imei,
                                                                      command
                                                                          .command);
                                                            },
                                                            child: const Text(
                                                              "Send",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'Poppins-Bold'),
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            })
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    height: 55,
                                    width: width,
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 20, bottom: 20),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            backgroundColor: colorPrimary),
                                        onPressed: () {
                                          if (widget.imei != null) {
                                            controller.getDeatils(widget.imei!);
                                          } else if (widget.deviceId != null) {
                                            controller.getDeatilsWithId(
                                                widget.deviceId!);
                                          }
                                        },
                                        child: const Text(
                                          Strings.refresh,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        )))
                              ],
                            ))),
          ),
        );
      },
    );
  }
}
