import 'package:airotrackgit/Controller/JobDetailsController.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/ui/ServiceDetails/ServiceDetails.dart';
import 'package:airotrackgit/ui/job_details/Widgets/technicians_note_widget.dart';
import 'package:airotrackgit/ui/utils/Functions/ProductIdToProduct.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/CallNowButton.dart';
import 'package:airotrackgit/ui/utils/Widgets/NavigateButton.dart';
import 'package:airotrackgit/ui/utils/Widgets/NormalTextPoppins.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../assets/resources/strings.dart';
import '../utils/Widgets/CancelButton.dart';
import '../utils/Widgets/CheckInButton.dart';
import '../utils/Widgets/CustomAppBar.dart';
import '../utils/Widgets/RichtextWidget.dart';
import 'Widgets/RowWidget1.dart';
import 'Widgets/RowWidget2.dart';

class JobDetails extends StatefulWidget {
  final dynamic jobDetails;
  final bool isOngoing;

  const JobDetails({
    super.key,
    required this.jobDetails,
    required this.isOngoing,
  });

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return GetBuilder(
      init: JobDetailsController(),
      didChangeDependencies: (state) {
        state.controller?.addMarker(widget.jobDetails.latitude ?? "",
            widget.jobDetails.longitude ?? "");
      },
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: Strings.jobDetails,
            onBack: () {
              Navigator.pop(context);
            }),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            controller.update();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(media.width * 0.04),
            child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowWidget1(
                  name: widget.jobDetails.customerName ?? "",
                  amount: widget.jobDetails.totalAmount ?? "",
                ),
                SizedBox(height: media.height * 0.015),
                RowWidget2(
                    media: media, phoneNumber: widget.jobDetails.mobile ?? ""),
                SizedBox(height: media.height * 0.015),
                CallNowButton(
                    onTap: () {
                      launchUrl(Uri.parse("tel:${widget.jobDetails.mobile}"));
                    },
                    media: media,
                    text: Strings.callNow,
                    buttonColor: colorPrimary,
                    textColor: Colors.white),
                SizedBox(height: media.height * 0.015),
                RichTextWidget(
                  text1: Strings.device,
                  text2: widget.jobDetails.productName ?? "",
                ),
                SizedBox(height: media.height * 0.01),
                RichTextWidget(
                  text1: Strings.jobType,
                  text2: serviceIdToService(widget.jobDetails.serviceType ?? 0),
                ),
                SizedBox(height: media.height * 0.01),
                RichTextWidget(
                  text1: Strings.vehicleNumber,
                  text2: widget.jobDetails.vehicleNo ?? "",
                ),
                SizedBox(height: media.height * 0.01),
                NormalTextPoppins(
                    text: widget.jobDetails.remarks ?? "",
                    color: Colors.black,
                    fontSize: 15),
                SizedBox(height: media.height * 0.015),
                widget.isOngoing
                    ? const BoldTextPoppins(
                        text: "Technicians Note",
                        color: Colors.black,
                        fontSize: 16)
                    : const SizedBox.shrink(),
                widget.isOngoing
                    ? SizedBox(height: media.height * 0.015)
                    : const SizedBox.shrink(),
                widget.isOngoing
                    ? TechniciansNoteWidget(
                        media: media,
                        techniciansNoteController:
                            controller.techniciansNoteController)
                    : Container(
                        height: media.height * 0.30,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              GoogleMap(
                                onMapCreated: controller.onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      double.parse(
                                          widget.jobDetails.latitude ?? "0.00"),
                                      double.parse(
                                          widget.jobDetails.longitude ??
                                              "0.00")),
                                  zoom: 14,
                                ),
                                markers: controller.markers,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                              ),
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.all(media.width * 0.02),
                                    child: NavigateButton(
                                      onTap: () {
                                        launchUrl(Uri.parse(
                                            "https://maps.google.com/?q=${widget.jobDetails.latitude},${widget.jobDetails.longitude}"));
                                      },
                                      buttonColor: colorPrimary,
                                      textColor: Colors.white,
                                      text: Strings.navigate,
                                      media: media,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                SizedBox(height: media.height * 0.015),
                widget.isOngoing
                    ? CheckInButton(
                        onTap: () {
                          if (controller
                              .techniciansNoteController.text.isEmpty) {
                            showToast(Strings.techniciansNote);
                            return;
                          }
                          Get.to(ServiceDetailsScreen(
                              jobId: widget.jobDetails.id.toString(),
                              amount: double.parse(
                                  widget.jobDetails.totalAmount ?? "0")));
                        },
                        media: media,
                        buttonText: "Finish Job",
                      )
                    : Column(
                        children: [
                          CancelButton(
                            onTap: () => controller.showCancelReasonDialog(
                                context,
                                media,
                                widget.jobDetails.id.toString()),
                            media: media,
                            buttonText: Strings.requestForCancellation,
                          ),
                          SizedBox(height: media.height * 0.01),
                          CheckInButton(
                            onTap: () => controller.showConfirmCheckIn(
                                context, widget.jobDetails, widget.jobDetails),
                            media: media,
                            buttonText: Strings.checkIn,
                          ),
                        ],
                      )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
