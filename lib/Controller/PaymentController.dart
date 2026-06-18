import 'package:airotrackgit/Model/company_title_model.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/ui/Payment/PaymentSuccess.dart';
import 'package:airotrackgit/ui/Payment/RowWidgets/Company_name_dropdown.dart';
import 'package:airotrackgit/ui/utils/Functions/network_testing.dart';
import 'package:airotrackgit/ui/utils/Functions/on_dio_exception.dart';
import 'package:airotrackgit/ui/utils/Widgets/BoldTextPoppins.dart';
import 'package:airotrackgit/ui/utils/Widgets/YesButtonWidget.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

import '../assets/resources/strings.dart';
import '../ui/utils/Widgets/CashAmountField.dart';
import '../ui/utils/Widgets/NormalTextPoppins.dart';
import '../ui/utils/Widgets/PaymentQRWidget.dart';

class PaymentController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint("PaymentController initialized");
  }

  @override
  void onClose() {
    debugPrint("PaymentController disposed");
    super.onClose();
  }

  String? selectedMethod;
  TextEditingController cashController = TextEditingController();
  TextEditingController paymentIdController = TextEditingController();
  final List<String> paymentMethods = ["Cash", "Online", "Cash + Online"];
  bool isLoading = false;
  Dio dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  String qrCode = "";
  double qrCodeAmount = 0.0;
  List<CompanyData> companyTitles = [];
  String? selectedCompanyTitle;
  String companyTitle = "";
  String companyId = "";

  Widget buildPaymentWidget(controller, Size media, double amount) {
    final method = controller.selectedMethod.toString();
    if (method == "Cash") {
      return NormalTextPoppins(
        text:
            "${Strings.pleaseCollect} ₹${amount.toStringAsFixed(0)} ${Strings.inCash}",
        color: Colors.black,
        fontSize: 13,
      );
    } else if (method == "Online") {
      return Center(
        child: qrCode.isNotEmpty
            ? PaymentQRWidget(
                amount: qrCodeAmount,
                qrImage: qrCode,
              )
            : const Center(child: CircularProgressIndicator()),
      );
    } else if (method == "Cash + Online") {
      return CashAmountField(
        media: media,
        controller: controller.cashController,
        onChanged: (val) {
          debugPrint("Amount: $val");
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> generateQrCode(
      String id, double amount, int paymentMethod) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.generateQrCode;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {
        "job_id": id,
        "amount": amount.round(),
        "payment_type": paymentMethod,
      };
      debugPrint("URL: $url");
      debugPrint("Query Parameters: ${dio.options.queryParameters}");
      debugPrint("Generating QR Code for amount: $amount");
      final response = await dio.post(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        qrCode = response.data;
        qrCodeAmount = amount;
        update();
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void onCashAndOnlinePayment(double amount, String jobId) {
    double cashAmount = double.parse(cashController.text);
    debugPrint("Cash Amount: $cashAmount");
    debugPrint("Amount: $amount");
    if (cashAmount == amount) {
      showToast("Amount equals total — choose online or cash payment.");
    } else if (amount > 0 && cashAmount < amount) {
      amount = amount - cashAmount;
      debugPrint("Amount after deduction: $amount");
      selectedMethod = "Online";
      generateQrCode(jobId, amount, 2);
      update();
    } else {
      showToast("Invalid amount");
    }
  }

  selectCompanyDialog(
    BuildContext context,
    double amount,
    String jobId,
    String paymentStatus,
    String paymentType,
    String companyId,
    double cashAmount,
    String paymentId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final media = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                  "lib/assets/images/company_title.svg",
                  width: media.width * 0.07,
                  height: media.height * 0.07,
                  color: colorPrimary,
                ),
              ),
              SizedBox(height: media.height * 0.03),
              const BoldTextPoppins(
                  text: "Select Company Title",
                  color: Colors.black,
                  fontSize: 16),
            ],
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: media.width * 0.025,
            vertical: media.height * 0.01,
          ),
          actions: [
            CompanyNameDropdown(
              hintText: "Select Company Title",
              items: companyTitles,
              value: companyTitles.isNotEmpty && selectedCompanyTitle != null
                  ? companyTitles.firstWhere(
                      (e) => e.id?.toString() == selectedCompanyTitle,
                      orElse: () => companyTitles.first,
                    )
                  : null,
              onChanged: (value) {
                debugPrint("Selected Company Title: $value");
                debugPrint(
                    "Selected Company Title ID: ${value?.id?.toString()}");
                selectedCompanyTitle = value?.id?.toString();
                companyTitle = value?.title ?? "";
                companyId = value?.id?.toString() ?? "";
                Navigator.pop(context);
                paymentDialog(
                    context,
                    amount,
                    jobId,
                    companyTitle,
                    paymentStatus,
                    paymentType,
                    companyId,
                    cashAmount,
                    paymentId);
                update();
              },
              media: media,
            ),
            SizedBox(height: media.height * 0.03),
          ],
        );
      },
    );
  }

  paymentDialog(
    BuildContext context,
    double amount,
    String jobId,
    String companyTitle,
    String paymentStatus,
    String paymentType,
    String companyId,
    double cashAmount,
    String paymentId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final media = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: SvgPicture.asset(
            "lib/assets/images/confirm_payment_icon.svg",
            width: media.width * 0.1,
            height: media.height * 0.1,
            color: colorPrimary,
          ),
          content: const BoldTextPoppins(
            text: Strings.doYouWantToConfirmThePayment,
            color: Colors.black,
            fontSize: 16,
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: media.width * 0.025,
            vertical: media.height * 0.01,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: media.width * 0.025,
                vertical: media.height * 0.01,
              ),
              child: Row(
                children: [
                  YesButtonWidget(
                      onTap: () => Get.back(),
                      media: media,
                      text: Strings.no,
                      textColor: Colors.black,
                      buttonColor: lightBlue),
                  SizedBox(width: media.width * 0.03),
                  YesButtonWidget(
                      onTap: () => postCheckoutConfirm(
                          jobId,
                          amount,
                          companyTitle,
                          paymentStatus,
                          paymentType,
                          companyId,
                          cashAmount,
                          paymentId),
                      media: media,
                      text: Strings.yes,
                      textColor: Colors.white,
                      buttonColor: colorPrimary),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> postCheckoutConfirm(
    String id,
    double amount,
    String companyTitle,
    String paymentStatus,
    String paymentType,
    String companyId,
    double cashAmount,
    String paymentId,
  ) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.postCheckoutConfirm;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {
        "job_id": id,
        "amount": amount.round(),
        "company_title": companyTitle,
        "payment_type":
            cashAmount > 0 && (amount - cashAmount) > 0 ? "3" : paymentType,
        "company_title_id": companyId,
        "cash_amount": cashAmount,
        "online_amount": paymentType != "1" ? amount - cashAmount : 0.0,
        "payment_id": paymentType != "1" ? paymentId : "",
      };
      debugPrint("URL: $url");
      debugPrint("Query Parameters: ${dio.options.queryParameters}");
      debugPrint("Generating QR Code for amount: $amount");
      final response = await dio.post(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        showToast(response.data['message']);
        Get.offAll(PaymentSuccess(
          amount: amount,
          jobId: id,
        ));
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getCompanyTitles() async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.companyTitles;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {};
      debugPrint("URL: $url");
      debugPrint("Query Parameters: ${dio.options.queryParameters}");
      final response = await dio.get(url);
      debugPrint("Response Data: ${response.data}");
      if (response.statusCode == 200) {
        if (response.data is List) {
          companyTitles = (response.data as List)
              .map((e) => CompanyData.fromJson(e as Map<String, dynamic>?))
              .toList();
        } else if (response.data is Map) {
          // If it's a Map, parse as CompanyTitleModel and extract data
          final companyTitleModel = CompanyTitleModel.fromJson(
              response.data as Map<String, dynamic>?);
          companyTitles = companyTitleModel.data ?? [];
        } else {
          companyTitles = [];
        }

        debugPrint("Company Titles: ${companyTitles.length} items loaded");
        update();
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }
}
