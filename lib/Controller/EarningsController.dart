import 'package:airotrackgit/Model/EarningsModel.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../ui/utils/Functions/network_testing.dart';
import '../ui/utils/utils.dart';

class EarningsController extends GetxController {

  bool isLoading = true;
  Dio dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  EarningsModel? earningsData;
  List<EarningsByDate>? earningsByDate=[];

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
    debugPrint("EarningsController initialized");

    scrollcontroller = new ScrollController()..addListener(_loadMore);
    getFormattedDate();
    getEarnings();
  }

  @override
  void onClose() {
    debugPrint("EarningsController disposed");
    super.onClose();
  }

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();


  getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    String formattedDate = formatter.format(now);
    fromDateController.text = formattedDate;
    toDateController.text = formattedDate;
    //getEarnings();
  }

  onFromDateTapped(context) {
    pickDate(context:context).then((selectedDate) {
      if (selectedDate != null) {
        fromDateController.text = selectedDate;
        getEarnings();
        update();
      }
    });
  }

  onToDateTapped(context) {
    pickDate(context:context).then((selectedDate) {
      if (selectedDate != null) {
        validateAndSetToDate(selectedDate);
      }
    });
  }
  void validateAndSetToDate(String selectedDate) {
    if (fromDateController.text.isNotEmpty && selectedDate.isNotEmpty) {
      try {
        // Parse both dates manually (format: dd/MM/yyyy)
        final fromParts = fromDateController.text.split('/');
        final selectedParts = selectedDate.split('/');

        if (fromParts.length == 3 && selectedParts.length == 3) {
          final fromDate = DateTime(
            int.parse(fromParts[2]),
            int.parse(fromParts[1]),
            int.parse(fromParts[0]),
          );
          final toDate = DateTime(
            int.parse(selectedParts[2]),
            int.parse(selectedParts[1]),
            int.parse(selectedParts[0]),
          );

          // Compare both dates
          if (toDate.isAfter(fromDate) || toDate.isAtSameMomentAs(fromDate)) {
            toDateController.text = selectedDate;
            getEarnings();
            update();
          } else {
            showToast('The to date must be a date after or equal to from date.');
          }
        } else {
          showToast('Invalid date format.');
        }
      } catch (e) {
        showToast('Error parsing dates: $e');
      }
    } else {
      showToast('Please select both dates.');
    }
  }

  Future<String?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: colorPrimary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      return DateFormat("dd/MM/yyyy").format(picked);
    }
    return null;
  }

  void _loadMore() async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollcontroller.position.extentAfter < 300) {

        isLoadMoreRunning = true; // Display a progress indicator at the bottom
        update();
      page += 1;

      try {
        List<EarningsByDate> fetchedPosts = [];

        EarningsModel? _requests =
        await fetchEarningsData(fromDateController.text, toDateController.text, limit, page);

          print(_requests!.status.toString()=="true");
          if (_requests.status.toString() == "true") {
            fetchedPosts = _requests.data!.earningsByDate!;
            for (EarningsByDate model in fetchedPosts) {
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
          earningsByDate?.addAll(fetchedPosts);
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

  getEarnings() async {
    page = 1;
    limit = 10;
    hasNextPage = true;
    isFirstLoadRunning = false;
    isLoadMoreRunning = false;
    try {

        isFirstLoadRunning = true;
        update();
      // EasyLoading.show();

      EarningsModel? _requests =
      await fetchEarningsData(fromDateController.text, toDateController.text,limit, page);

        print(_requests!.status.toString()=="true");
        if (_requests.status.toString() == "true") {
          earningsByDate!.clear();
          earningsByDate = _requests.data!.earningsByDate;
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

  Future<EarningsModel?> fetchEarningsData(String from_date, String to_date, int limit, int page) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.earnings;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {"from_date": formatDateToISO(from_date),"to_date":formatDateToISO(to_date), "limit":limit,"page":page};
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        earningsData = EarningsModel.fromJson(response.data);
        return earningsData;
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
  String formatDateToISO(String? inputDate) {
    if (inputDate == null || inputDate.isEmpty) return '';

    try {
      // Parse the date in format dd/MM/yyyy
      final parts = inputDate.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day'; // Convert to yyyy-MM-dd
      }
    } catch (e) {
      print('Date format error: $e');
    }

    return inputDate; // fallback to original
  }


}
