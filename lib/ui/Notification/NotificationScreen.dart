import 'package:airotrackgit/Controller/NotificationController.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/RecentJobsAppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../assets/resources/strings.dart';
import 'Widgets/NotificationTile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return GetBuilder(
      init: NotificationController(),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: RecentJobsAppBar(
            title: Strings.notifications, onTap: () => Get.back()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: greyFillColor,
                child: const BoldTextPoppins(
                    text: Strings.today, color: Colors.black, fontSize: 15)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  controller.update();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) => NotificationTile(
                    message: controller.notifications[index],
                  ),
                  separatorBuilder: (context, index) =>
                      SizedBox(height: media.height * 0.01),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
