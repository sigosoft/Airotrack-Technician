import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/ui/CreateNewWork/CreateNewWork.dart';
import 'package:airotrackgit/ui/Payment/Payment.dart';
import 'package:airotrackgit/ui/home/JobItem.dart';
import 'package:airotrackgit/ui/home/widget/home_welcome_card.dart';
import 'package:airotrackgit/ui/home/widget/work_type_details.dart';
import 'package:airotrackgit/ui/job_details/job_details.dart';
import 'package:airotrackgit/ui/utils/Functions/ProductIdToProduct.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:airotrackgit/Controller/home_controller.dart';
import 'package:airotrackgit/Model/home_model.dart';
import '../../assets/resources/strings.dart';
import '../utils/utils.dart';
import 'home.dart';
import 'widget/create_new_work_button.dart';

class HomeNew extends StatefulWidget {
  const HomeNew({super.key});

  @override
  State<HomeNew> createState() => _HomeNewState();
}

class _HomeNewState extends State<HomeNew> with SingleTickerProviderStateMixin {
  PackageInfo? packageInfo;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late final TabController tabController;
  bool lodingHome = true;
  var role_id;
  final List<String> tabs = const [
    'All',
    'New Installations',
    'Repair',
    'Replace',
  ];

  @override
  void initState() {
    setupTabController();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        lodingHome = false;
      });
    });
    super.initState();
  }

  void setupTabController() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      packageInfo = await PackageInfo.fromPlatform();
      role_id = await getSavedObject("role_id");
      tabController = TabController(length: tabs.length, vsync: this);
      tabController.addListener(() {
        if (!tabController.indexIsChanging) {
          final c = Get.find<HomeController>();
          final i = tabController.index;
          final serviceType = i == 0 ? "" : i.toString();
          c.fetchHomeData(serviceType);
        }
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  TextEditingController deviceIdController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context).size;
    return GetBuilder<HomeController>(
        init: HomeController(),
        initState: (_) {
          // Refresh data when HomeNew is initialized/opened
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isRegistered<HomeController>()) {
              final controller = Get.find<HomeController>();
              controller.refreshHomeData("");
            }
          });
        },
        builder: (controller) {
          var technician = controller.homeData?.data?.technician;
          return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  toolbarHeight: media.height * 0.10,
                  title: SvgPicture.asset(
                    'lib/assets/images/logosplash.svg',
                    height: media.height * 0.10,
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(end: 10),
                      child: SvgPicture.asset(
                        'lib/assets/images/notifications.svg',
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ]),
              drawer: UserDrawer(
                packageInfo: packageInfo,
                scaffoldKey: scaffoldKey,
                role_id: role_id,
              ),
              body: () {
                if (lodingHome) {
                  return const Center(
                    child: CircularProgressIndicator(color: colorPrimary),
                  );
                } else {
                  List<UpcomingWorks> upcomingWorks =
                      controller.homeData?.data?.upcomingWorks ??
                          <UpcomingWorks>[];
                  List<Work> pendingWorks =
                      controller.homeData?.data?.pendingWorks ?? <Work>[];
                  List<Work> ongoingWorks =
                      controller.homeData?.data?.ongoingWorks ?? <Work>[];
                  return RefreshIndicator(
                    color: colorPrimary,
                    backgroundColor: Colors.white,
                    strokeWidth: 3.0,
                    displacement: 40.0,
                    onRefresh: () async {
                      final serviceType = tabController.index == 0
                          ? ""
                          : tabController.index.toString();
                      await controller.refreshHomeData(serviceType);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: media.width * 0.040,
                            vertical: media.height * 0.020),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeWelcomeCard(
                                media: media, userName: technician?.name ?? ""),
                            SizedBox(height: media.height * 0.020),
                            CreateNewWorkButton(
                              media: media,
                              onPressed: () =>
                                  Get.to(() => const CreateNewWorkScreen()),
                            ),
                            SizedBox(height: media.height * 0.010),
                            ongoingWorks.isEmpty
                                ? const SizedBox.shrink()
                                : const Text(
                                    Strings.ongoingJobs,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins-Bold'),
                                  ),
                            SizedBox(height: media.height * 0.010),
                            ongoingWorks.isEmpty
                                ? const SizedBox.shrink()
                                : Column(
                                    children: List.generate(
                                        ongoingWorks.length,
                                        (index) => Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: media.height * 0.015),
                                              child: JobItem(
                                                onAcceptTapped: () => ongoingWorks[
                                                                index]
                                                            .jobStatus
                                                            .toString() ==
                                                        "3"
                                                    ? Get.to(() => PaymentScreen(
                                                        amount: double.parse(
                                                            ongoingWorks[index]
                                                                    .totalAmount ??
                                                                "0.0"),
                                                        jobId:
                                                            ongoingWorks[index]
                                                                .id
                                                                .toString()))
                                                    : Get.to(() => JobDetails(
                                                          isOngoing: true,
                                                          jobDetails:
                                                              ongoingWorks[
                                                                  index],
                                                        )),
                                                deviceName: ongoingWorks[index]
                                                        .productName ??
                                                    "",
                                                workType: serviceIdToService(
                                                    ongoingWorks[index]
                                                            .serviceType
                                                            ?.toInt() ??
                                                        0),
                                                location: ongoingWorks[index]
                                                        .location ??
                                                    "",
                                                price: ongoingWorks[index]
                                                        .totalAmount ??
                                                    "",
                                                isUpcoming: true,
                                                createdDate: ongoingWorks[index]
                                                        .convertedCreatedAt ??
                                                    "",
                                              ),
                                            )),
                                  ),
                            SizedBox(height: media.height * 0.010),
                            upcomingWorks.isEmpty
                                ? const SizedBox.shrink()
                                : const Text(
                                    Strings.upComingJobs,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins-Bold'),
                                  ),
                            SizedBox(height: media.height * 0.010),
                            upcomingWorks.isEmpty
                                ? const SizedBox.shrink()
                                : Column(
                                    children: List.generate(
                                        upcomingWorks.length,
                                        (index) => Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: media.height * 0.015),
                                              child: JobItem(
                                                onAcceptTapped: () =>
                                                    Get.to(() => JobDetails(
                                                          isOngoing: false,
                                                          jobDetails:
                                                              upcomingWorks[
                                                                  index],
                                                        )),
                                                deviceName: upcomingWorks[index]
                                                        .productName ??
                                                    "",
                                                workType: serviceIdToService(
                                                    upcomingWorks[index]
                                                            .serviceType
                                                            ?.toInt() ??
                                                        0),
                                                location: upcomingWorks[index]
                                                        .location ??
                                                    "",
                                                price: upcomingWorks[index]
                                                        .totalAmount ??
                                                    "",
                                                isUpcoming: true,
                                                createdDate: upcomingWorks[
                                                            index]
                                                        .convertedCreatedAt ??
                                                    "",
                                              ),
                                            )),
                                  ),
                            WorkTypeDetails(
                              isLoading: controller.isLoading,
                              pendingWorks: pendingWorks,
                              workStatus: Strings.jobRequest,
                              theme: theme,
                              onAcceptTapped: (work) =>
                                  controller.showAcceptJobDialog(context, work),
                              tabController: tabController,
                              tab: tabs,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }());
        });
  }
}
