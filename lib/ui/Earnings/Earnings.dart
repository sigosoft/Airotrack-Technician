import 'package:airotrackgit/Controller/EarningsController.dart';
import 'package:airotrackgit/ui/Earnings/Widgets/TotalEarningsWidget.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/RecentJobsAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';

import '../../Model/EarningsModel.dart';
import '../../assets/resources/colors.dart';
import '../../assets/resources/strings.dart';
import 'Widgets/DateSelectionWidget.dart';
import 'Widgets/EarningCard.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: GetBuilder(
        init: EarningsController(),
        builder: (controller) => Scaffold(
          appBar: RecentJobsAppBar(
            title: Strings.earnings,
            onTap: () => Get.back(),
          ),
          body: Padding(
            padding: EdgeInsets.all(media.width * 0.04),
            child: controller.isFirstLoadRunning && controller.earningsByDate!.length == 0
                ? Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: colorPrimary,
                  ),
                ))

                :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateSelectionWidget(
                  media: media,
                  fromDate: controller.fromDateController.text,
                  toDate: controller.toDateController.text,
                  onFromDateTap: () => controller.onFromDateTapped(context),
                  onToDateTap: () => controller.onToDateTapped(context),
                ),
                SizedBox(height: media.height * 0.02),
                TotalEarningsWidget(
                  media: media,
                  fromDate: controller.fromDateController.text,
                  toDate: controller.toDateController.text,
                  totalAmount: controller.earningsByDate!.length == 0?"₹0":"₹"+ controller.earningsData!.data!.totalEarnings.toString(),
                ),
                SizedBox(height: media.height * 0.02),
              controller.earningsByDate!.length == 0
          ? Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.getEarnings();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: media.height * 0.6,
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
                              SizedBox(height: 100,),
                              Container(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      "No Earnings Found",
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
                                      "There is no earnings to show",
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
            ):
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.getEarnings();
                    },
                    child: SingleChildScrollView(
                        controller: controller.scrollcontroller,
                        physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        color: Colors.white,
                        child: Column(children: [
                          ListView.builder(
                            itemCount: controller.earningsByDate!.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              EarningsByDate model = controller.earningsByDate![index];
                              var date = DateTime.parse(controller.earningsByDate![index].date.toString());
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
                                   BoldTextPoppins(
                                      text: controller.day, color: Colors.black, fontSize: 17),
                                  SizedBox(height: media.height * 0.01),
                                  ListView.separated(
                                      itemCount: model.earnings!.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return EarningCard(
                                        media: media,
                                        location:model.earnings![index].location.toString(),
                                        product:model.earnings![index].productName.toString(),
                                        amount: model.earnings![index].amount.toString(),
                                      );
                                    },
                                    separatorBuilder: (context, index) => SizedBox(
                                      height: media.height * 0.003,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
