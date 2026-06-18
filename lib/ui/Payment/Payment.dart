import 'package:airotrackgit/Controller/PaymentController.dart';
import 'package:airotrackgit/ui/CreateNewWork/Widgets/CreateNewWorkTextField.dart';
import 'package:airotrackgit/ui/CreateNewWork/Widgets/LabelTextWidget.dart';
import 'package:airotrackgit/ui/utils/Widgets/CustomAppBar.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../assets/resources/strings.dart';
import '../utils/Widgets/ColorChangingButton.dart';
import '../utils/Widgets/CustomDropDown.dart';
import 'RowWidgets/RowWidget3.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.amount,
    required this.jobId,
  });
  final double amount;
  final String jobId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: Strings.payment,
        onBack: () => Get.back(),
      ),
      body: Padding(
        padding: EdgeInsets.all(media.width * 0.04),
        child: RefreshIndicator(
          onRefresh: () async {
            if (Get.isRegistered<PaymentController>()) {
              await Get.find<PaymentController>().getCompanyTitles();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: media.height,
            width: media.width,
            child: SafeArea(
              top: false,
              child: GetBuilder(
                init: PaymentController(),
                didChangeDependencies: (state) {
                  state.controller?.getCompanyTitles();
                  state.controller?.update();
                },
                builder: (controller) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowWidget3(
                      text1: Strings.total,
                      text2: "₹${widget.amount.toStringAsFixed(0)}",
                    ),
                    SizedBox(height: media.height * 0.025),
                    CustomDropdown(
                      media: media,
                      hintText: Strings.pickAPaymentMethod,
                      items: controller.paymentMethods,
                      value: controller.selectedMethod,
                      onChanged: (value) {
                        controller.selectedMethod = value;
                        if (value == "Online") {
                          controller.generateQrCode(
                              widget.jobId, widget.amount, 2);
                        }
                        controller.update();
                      },
                    ),
                    SizedBox(height: media.height * 0.025),
                    controller.selectedMethod == "Online" ||
                            controller.selectedMethod == "Cash + Online"
                        ? const LabelTextWidget(label: Strings.paymentId)
                        : const SizedBox.shrink(),
                    controller.selectedMethod == "Online" ||
                            controller.selectedMethod == "Cash + Online"
                        ? SizedBox(height: media.height * 0.005)
                        : const SizedBox.shrink(),
                    controller.selectedMethod == "Online" ||
                            controller.selectedMethod == "Cash + Online"
                        ? CreateNewWorkTextField(
                            controller: controller.paymentIdController,
                            media: media,
                            hintText: Strings.paymentId,
                          )
                        : const SizedBox.shrink(),
                    controller.selectedMethod == "Online" ||
                            controller.selectedMethod == "Cash + Online"
                        ? SizedBox(height: media.height * 0.025)
                        : const SizedBox.shrink(),
                    controller.buildPaymentWidget(
                        controller, media, widget.amount),
                    const Spacer(),
                    ColorChangingButton(
                        amount: widget.amount,
                        onTap: () => controller.selectedMethod ==
                                "Cash + Online"
                            ? controller.cashController.text.isEmpty
                                ? showToast("Please enter the cash amount")
                                : controller.onCashAndOnlinePayment(
                                    widget.amount, widget.jobId)
                            : controller.selectCompanyDialog(
                                context,
                                widget.amount,
                                widget.jobId,
                                "3",
                                controller.selectedMethod == "Cash"
                                    ? "1"
                                    : controller.selectedMethod == "Online"
                                        ? "2"
                                        : "3",
                                controller.companyId,
                                controller.cashController.text.isEmpty
                                    ? 0.0
                                    : double.parse(
                                        controller.cashController.text),
                                controller.paymentIdController.text.isEmpty &&
                                        (controller.selectedMethod ==
                                                "Online" ||
                                            controller.selectedMethod ==
                                                "Cash + Online")
                                    ? showToast("Please enter the payment id")
                                    : controller.paymentIdController.text ),
                        selectedMethod: controller.selectedMethod,
                        media: media),
                    SizedBox(height: media.height * 0.16),
                  ],
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
