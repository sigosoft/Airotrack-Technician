import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/ui/devices/devicedetails.dart';
import 'package:airotrackgit/ui/devices/qrview.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/RecentJobsAppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../assets/resources/strings.dart';
import 'Widgets/DeviceIdTextField.dart';
import 'Widgets/OpenScannerButton.dart';

// ignore: must_be_immutable
class ScanDeviceScreen extends StatelessWidget {
  ScanDeviceScreen({super.key});

  TextEditingController deviceIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      appBar:
          RecentJobsAppBar(title: Strings.scanDevice, onTap: () => Get.back()),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: media.height - 80,
            ),
            child: Padding(
              padding: EdgeInsets.all(media.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoldTextPoppins(
                      text: Strings.scanDevice, color: Colors.black, fontSize: 18),
                  SizedBox(height: media.height * 0.015),
                  OpenScannerButton(
                    media: media,
                    buttonColor: colorPrimary,
                    onPressed: () => Get.to(() => const QRViewExample()),
                  ),
                  SizedBox(height: media.height * 0.025),
                  const BoldTextPoppins(
                      text: Strings.deviceID, color: Colors.black, fontSize: 18),
                  SizedBox(height: media.height * 0.01),
                  DeviceIdTextField(
                    deviceIdController: deviceIdController,
                    media: media,
                    onPressed: () => Get.to(
                        () => DeviceDetail(imei: deviceIdController.text.trim())),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
