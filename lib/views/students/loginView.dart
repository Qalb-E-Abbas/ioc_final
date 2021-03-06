import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/Logics/errorStrings.dart';
import 'package:ioc_chatbot/Logics/loginBusinessLogic.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/authTextField.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/horizontal_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/enums.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/Backend/services/authServices.dart';
import 'package:ioc_chatbot/views/elements/dialog.dart';
import 'package:ioc_chatbot/views/students/signUp.dart';
import 'package:ioc_chatbot/views/students/wrapper.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../forgot_pwd.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController _pwdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  var node;

  LoginBusinessLogic data = LoginBusinessLogic();
  bool isVisible = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    node = FocusScope.of(context);

    var auth = Provider.of<AuthServices>(context);

    print(auth.status);

    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      body: LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: LoadingWidget(),
        color: AppColors.blueTextColor,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                VerticalSpace(70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Image.asset('assets/images/Logo2.png'),
                ),

                AuthTextField(
                  image: "assets/images/regNo1.png",
                  label: "reg_No",
                  controller: _emailController,
                  validator: (val) =>
                      val.isEmpty ? "Email field cannot be empty." : null,
                ),
                AuthTextField(
                  image: "assets/images/password.png",
                  label: "password",
                  validator: (val) =>
                      val.isEmpty ? "Password field cannot be empty." : null,
                  controller: _pwdController,
                  isPasswordField: true,
                  onPwdTap: () {
                    isVisible = !isVisible;
                    setState(() {});
                  },
                  visible: !isVisible,
                ),
                VerticalSpace(15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ForgotPasswordView()));
                        },
                        child: DynamicFontSize(
                          label: 'forgot_password',
                          fontSize: 16,
                          color: AppColors.blueTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                VerticalSpace(30),
                AppButton(
                  text: "sign_in",
                  isDark: true,
                  onTap: () {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    isLoading = true;
                    setState(() {});
                    loginUser(
                        context: context,
                        data: data,
                        email: _emailController.text,
                        auth: auth,
                        password: _pwdController.text);
                  },
                ),
                VerticalSpace(40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DynamicFontSize(
                        label: "Don't_have_acc",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightTextColor,
                      ),
                      HorizontalSpace(5),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpView()));
                        },
                        child: DynamicFontSize(
                          label: "sign_up",
                          fontSize: 16,
                          color: AppColors.blueTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loginUser(
      {@required BuildContext context,
      @required LoginBusinessLogic data,
      @required String email,
      @required AuthServices auth,
      @required String password}) {
    data
        .loginStudentLogic(
      context,
      regNo: email,
      password: password,
    )
        .then((val) async {
      if (auth.status == Status.Authenticated) {
        isLoading = false;
        setState(() {});

        UserLoginStateHandler.saveUserLoggedInSharedPreference(true);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      } else {
        isLoading = false;
        setState(() {});
        print(auth.status);
        showErrorDialog(context,
            message: Provider.of<ErrorString>(context, listen: false)
                .getErrorString());
      }
    });
  }
}
