import 'package:airotrackgit/Controller/LoginController.dart';
import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/assets/resources/strings.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    resetSessionExpirationState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GetBuilder<LoginController>(
          init: LoginController(),
          builder: (controller) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 130,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 25, top: 20),
                    child: const Text(
                      Strings.welcome,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 25, top: 10),
                    child: const Text(
                      Strings.loginWithUserName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Poppins-Regular'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 25, top: 35),
                    child: const Text(
                      Strings.username,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins-Light'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 25,
                      top: 15,
                      right: 25,
                    ),
                    child: TextFormField(
                      controller: controller.usernameController,
                      keyboardType: TextInputType.name,
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.allow(
                      //       RegExp(r'[a-zA-Z\s]+')),
                      // ],
                      decoration: InputDecoration(
                        hintText: Strings.enterUserName,
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.3))),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your username";
                        }
                        if (value.length < 3) {
                          return "Enter a valid username";
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 25, top: 25),
                    child: const Text(
                      Strings.password,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins-Light'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 25,
                      top: 15,
                      right: 25,
                    ),
                    child: TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        hintText: Strings.enterPassword,
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.3))),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter password";
                        }
                        if (value.length < 6) {
                          return "Password must contain atleast 6 charaters";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 90,
                  ),
                  Container(
                      height: 55,
                      width: width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: colorPrimary),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              controller.login(context);
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => const DeviceDetail()));
                            }
                          },
                          child: const Text(
                            Strings.continueButton,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )))
                ],
              )),
            );
          }),
    );
  }
}
