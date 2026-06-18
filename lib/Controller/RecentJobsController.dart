import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Model/RecentJobsModel.dart';
import '../config/api_config.dart';
import '../ui/utils/Functions/network_testing.dart';
import '../ui/utils/utils.dart';

class RecentJobsController extends GetxController {

  bool isLoading = true;
  Dio dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  RecentJobsModel? recentJobsData;
  List<RecentJobsDateData>? recentJobsByDate=[];

  var day;
  int page = 1;
  int limit = 3;
  bool hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  ScrollController scrollcontroller = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollcontroller = new ScrollController()..addListener(_loadMore);
    getRecentJobs();
    debugPrint("RecentJobsController initialized");
  }

  @override
  void onClose() {
    debugPrint("RecentJobsController disposed");
    super.onClose();
  }

  final filters = ["All", "New Installation", "Repair", "Replacement"];
  int selectedFilterIndex = 0;

  void _loadMore() async {
    String service_type;
    if(selectedFilterIndex==0){
      service_type = "";
    }else if(selectedFilterIndex==1){
      service_type = "1";
    }else if(selectedFilterIndex==2){
      service_type = "2";
    }else{
      service_type = "3";
    }
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollcontroller.position.extentAfter < 300) {

      isLoadMoreRunning = true; // Display a progress indicator at the bottom
      update();
      page += 1;

      try {
        List<RecentJobsDateData> fetchedPosts = [];

        RecentJobsModel? _requests =
        await fetchRecentJobsData(service_type, limit, page);

        print(_requests!.status.toString()=="true");
        if (_requests.status.toString() == "true") {
          fetchedPosts = _requests.data!.data!;
          for (RecentJobsDateData model in fetchedPosts) {
            var date = DateTime.parse(model.date!);
            final currentDate = DateTime.now();
            DateTime dateServer = DateTime(date.year, date.month, date.day);
            final difference = currentDate.difference(dateServer).inDays;
            if (difference == 0) {
              day = "Today";
            } else if (difference == 1) {
              day = "Yesterday";
            }
          }
        } else {
          showToast(_requests.message!);
        }
        update();
        if (fetchedPosts.length > 0) {
          recentJobsByDate?.addAll(fetchedPosts);
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request

          hasNextPage = false;
          update();
        }
      } catch (e) {
        print('Something went wrong!');
        hasNextPage = false;
        // print("error" + e.toString());
        // showErrorMessage(e);
      }


      isLoadMoreRunning = false;
      update();
    }
  }

  getRecentJobs() async {
    page = 1;
    limit = 10;
    hasNextPage = true;
    isFirstLoadRunning = false;
    isLoadMoreRunning = false;
    try {
       String service_type;
       if(selectedFilterIndex==0){
         service_type = "";
       }else if(selectedFilterIndex==1){
         service_type = "1";
       }else if(selectedFilterIndex==2){
         service_type = "2";
       }else{
         service_type = "3";
       }
      isFirstLoadRunning = true;
      update();
      // EasyLoading.show();

      RecentJobsModel? _requests =
      await fetchRecentJobsData(service_type,limit, page);

      print(_requests!.status.toString()=="true");
      if (_requests.status.toString() == "true") {
        recentJobsByDate!.clear();
        recentJobsByDate = _requests.data!.data;
      } else {
        // showToast(_requests.message);
      }
      update();
    } catch (e) {
      print('Something went wrong!');
      print("error" + e.toString());
      // showErrorMessage(e);
    }

    isFirstLoadRunning = false;
    update();
  }

  Future<RecentJobsModel?> fetchRecentJobsData(String service_type, int limit, int page) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.rcentJobs;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {"service_type": service_type, "limit":limit,"page":page};
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        recentJobsData = RecentJobsModel.fromJson(response.data);
        return recentJobsData;
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 400:
            debugPrint("Bad Request: ${e.response?.data}");
            break;
          case 422:
            debugPrint("Validation Error: ${e.response?.data}");
            break;
          case 500:
            debugPrint("Server Error: ${e.response?.data}");
            break;
          default:
            debugPrint(
                "Dio Error: ${e.response?.statusCode} -> ${e.response?.data}");
        }
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint("Unexpected Error: $e $stackTrace");
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }
}