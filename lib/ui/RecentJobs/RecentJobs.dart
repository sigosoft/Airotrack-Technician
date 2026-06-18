import 'package:airotrackgit/Controller/RecentJobsController.dart';
import 'package:airotrackgit/Model/RecentJobsModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../assets/resources/colors.dart';
import '../../assets/resources/strings.dart';
import '../utils/Widgets/BoldTextPoppins.dart';
import '../utils/Widgets/RecentJobsAppBar.dart';
import 'Widgets/DateText.dart';
import 'Widgets/FilterChipSet.dart';
import 'Widgets/JobCard.dart';

class RecentJobsScreen extends StatelessWidget {
  const RecentJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return GetBuilder(
      init: RecentJobsController(),
      builder: (controller) => Scaffold(
        appBar: RecentJobsAppBar(
            title: Strings.recentJobs, onTap: () => Get.back()),
        body: Padding(
          padding: EdgeInsets.all(media.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterChipsList(
                filters: controller.filters,
                selectedIndex: controller.selectedFilterIndex,
                onSelected: (index) {
                  controller.selectedFilterIndex = index;
                  controller.recentJobsByDate =[];
                  controller.getRecentJobs();
                  controller.update();
                },
                media: media,
              ),
              SizedBox(height: media.height * 0.02),
              controller.isFirstLoadRunning && controller.recentJobsByDate!.length == 0
                  ? Expanded(
                    child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: colorPrimary,
                      ),
                    )),
                  ):
              controller.recentJobsByDate!.length == 0
                  ? Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await controller.getRecentJobs();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: media.height * 0.7,
                            color: Colors.white,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(15),
                            child: SafeArea(
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: [
                                            Text(
                                              "No Recent Jobs Found",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins-Regular',
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "There is no recent jobs to show",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins-Regular',
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "you right now.",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins-Regular',
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  :
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.getRecentJobs();
                  },
                  child: SingleChildScrollView(
                      controller: controller.scrollcontroller,
                      physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      color: Colors.white,
                      child: Column(children: [
                        ListView.builder(
                          itemCount: controller.recentJobsByDate!.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            RecentJobsDateData model = controller.recentJobsByDate![index];
                            var date = DateTime.parse(controller.recentJobsByDate![index].date.toString());
                            final currentDate = DateTime.now();
                            DateTime dateServer =
                            DateTime(date.year, date.month, date.day);
                            final difference =
                                currentDate.difference(dateServer).inDays;
                            if (difference == 0) {
                              controller.day = "Today";
                            } else if (difference == 1) {
                              controller.day = "Yesterday";
                            } else {
                              final DateFormat formatter =
                              DateFormat('dd MMM yyy');
                              controller.day = formatter.format(dateServer);
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.day,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17, fontFamily: 'Poppins-Regular',fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: media.height * 0.01),
                                ListView.separated(
                                  itemCount: model.jobs!.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => JobCard(
                                    title: model.jobs![index].productName.toString(),
                                    subtitle:model.jobs![index].serviceTypeText.toString(),
                                    location: model.jobs![index].location.toString(),
                                    media: media,
                                    amount: model.jobs![index].totalAmount.toString(),
                                    paymentId:model.jobs![index].paymentId.toString(),
                                  ),
                                  separatorBuilder: (context, index) => SizedBox(
                                    height: media.height * 0.01,
                                  ),),
                                // when the _loadMore function is running

                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            );
                          },
                        ),
                        if (controller.isLoadMoreRunning == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colorPrimary,
                              ),
                            ),
                          ),
                      ]),
                    ))),
              ),
              // const DateText(date: "20 Aug 2023"),
              // SizedBox(height: media.height * 0.02),
              // Expanded(
              //     child: ListView.separated(
              //         itemBuilder: (context, index) => JobCard(
              //               title: controller.jobData[index]["title"],
              //               subtitle: controller.jobData[index]["subtitle"],
              //               location: controller.jobData[index]["location"],
              //               media: media,
              //               amount: controller.jobData[index]["amount"],
              //               statusText: controller.jobData[index]["statusText"],
              //             ),
              //         separatorBuilder: (context, index) =>
              //             SizedBox(height: media.height * 0.01),
              //         itemCount: controller.jobData.length))
            ],
          ),
        ),
      ),
    );
  }
}
