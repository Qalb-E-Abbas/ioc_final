import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/app_state.dart';
import 'package:ioc_chatbot/Logics/errorStrings.dart';
import 'package:ioc_chatbot/Logics/loginBusinessLogic.dart';
import 'package:ioc_chatbot/Logics/signUpBusinissLogic.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/authTextField.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/authServices.dart';
import 'package:ioc_chatbot/Backend/services/uploadFileServices.dart';
import 'package:ioc_chatbot/views/elements/dialog.dart';
import 'package:ioc_chatbot/views/elements/navigation_dialog.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../both_apps.dart';
import 'loginView.dart';
import 'loginView.dart';

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController fisrtName = TextEditingController();

  TextEditingController lastName = TextEditingController();

  TextEditingController gender = TextEditingController();

  TextEditingController regNo = TextEditingController();

  TextEditingController _emailController = TextEditingController();

  List<String> sectionList = ["A", "B"];
  String selectedSection;
  TextEditingController _pwdController = TextEditingController();
  File _file;
  TextEditingController semesSec = TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(
      mask: 'CS#########', filter: {"#": RegExp(r'[0-9]')});
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
  bool isVisible = false;
  LoginBusinessLogic data = LoginBusinessLogic();
  UploadFileServices _uploadFileServices = UploadFileServices();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    AuthServices users = Provider.of<AuthServices>(context);
    SignUpBusinessLogic signUp = Provider.of<SignUpBusinessLogic>(context);
    var user = Provider.of<User>(context);
    var auth = Provider.of<AuthServices>(context);
    return WillPopScope(
      onWillPop: () {
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginView()));
      },
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: isLoading,
          progressIndicator: LoadingWidget(),
          color: FrontEndConfigs.blueTextColor,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  VerticalSpace(70),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Image.asset('assets/images/bike.png'),
                  ),
                  VerticalSpace(50),
                  AuthTextField(
                    image: "assets/images/Profile.png",
                    label: "first_name",
                    controller: fisrtName,
                    validator: (val) => val.isEmpty
                        ? "First Name field cannot be empty."
                        : null,
                  ),
                  AuthTextField(
                    image: "assets/images/Profile.png",
                    label: "last_name",
                    controller: lastName,
                    validator: (val) =>
                        val.isEmpty ? "Last Name field cannot be empty." : null,
                  ),
                  AuthTextField(
                    image: "assets/images/Profile.png",
                    label: "gender",
                    controller: gender,
                    validator: (val) =>
                        val.isEmpty ? "Gender field cannot be empty." : null,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12)),
                          height: 61,
                          child: TextFormField(
                            inputFormatters: [maskFormatter],
                            validator: (val) => val.isEmpty
                                ? "Registration No. field cannot be empty."
                                : null,
                            controller: regNo,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                letterSpacing: 1,
                                color: FrontEndConfigs.authTextFieldLabelColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    FrontEndConfigs.authFieldBackgroundColor,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 19.0,
                                      top: 19,
                                      bottom: 19,
                                      right: 10),
                                  child: Image.asset(
                                    "assets/images/Profile.png",
                                    height: 19,
                                    width: 13,
                                  ),
                                ),
                                hintText: "REG",
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12)),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12)),
                                hintStyle: TextStyle(
                                    letterSpacing: 1,
                                    color:
                                        FrontEndConfigs.authTextFieldLabelColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AuthTextField(
                    image: "assets/images/Profile.png",
                    label: "semester_sec",
                    controller: semesSec,
                    validator: (val) => val.isEmpty
                        ? "Semester, Sec Name field cannot be empty."
                        : null,
                  ),
                  AuthTextField(
                    image: "assets/images/Message.png",
                    label: "email",
                    controller: _emailController,
                    validator: (val) =>
                        val.isEmpty ? "Email field cannot be empty." : null,
                  ),
                  AuthTextField(
                    image: "assets/images/Lock.png",
                    label: "password",
                    onPwdTap: () {
                      isVisible = !isVisible;
                      setState(() {});
                    },
                    controller: _pwdController,
                    validator: (val) =>
                        val.isEmpty ? "Password field cannot be empty." : null,
                    isPasswordField: true,
                    visible: !isVisible,
                  ),
                  VerticalSpace(10),
                  _getSubjectDropDown(context),
                  VerticalSpace(10),
                  _getImagePicker(context),
                  VerticalSpace(10),
                  AppButton(
                    onTap: () {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      isLoading = true;
                      setState(() {});
                      _signUpUser(signUp: signUp, user: user, context: context);
                    },
                    text: "sign_up",
                    isDark: true,
                  ),
                  VerticalSpace(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DynamicFontSize(
                          label: "have_an_acc",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: FrontEndConfigs.lightTextColor,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginView()));
                          },
                          child: DynamicFontSize(
                            label: "sign_in",
                            fontSize: 16,
                            color: FrontEndConfigs.blueTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalSpace(20)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getImagePicker(BuildContext context) {
    var status = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(7)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  _file == null
                      ? "Choose an Image..."
                      : _file.path.split('/').last,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  getFile(true);
                })
          ],
        ),
      ),
    );
  }

  Future getFile(bool gallery) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      _file = File(result.files.single.path);
    } else {
      // User canceled the picker
    }

    setState(() {
      if (_file != null) {
        _file = File(_file.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _signUpUser(
      {BuildContext context,
      @required SignUpBusinessLogic signUp,
      @required User user}) {
    _uploadFileServices.getUrl(context, file: _file).then((value) {
      signUp
          .registerNewUser(
              email: _emailController.text,
              password: _pwdController.text,
              userModel: UserModel(
                  firstName: fisrtName.text,
                  lastName: lastName.text,
                  regNo: regNo.text,
                  profilePic: value,
                  password: _pwdController.text,
                  isOnline: false,
                  lastSeen: "",
                  role: "S",
                  section: selectedSection,
                  gender: gender.text,
                  semester: semesSec.text,
                  email: _emailController.text),
              context: context,
              user: user)
          .then((value) {
        if (signUp.status == SignUpStatus.Registered) {
          isLoading = false;
          setState(() {});
          showNavigationDialog(context,
              message:
                  "Thanks for registration. Go to Login to access your dashboard.",
              buttonText: "Go To Login", navigation: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginView()));
          }, secondButtonText: "", showSecondButton: false);
        } else if (signUp.status == SignUpStatus.Failed) {
          isLoading = false;
          setState(() {});
          showErrorDialog(context,
              message: Provider.of<ErrorString>(context, listen: false)
                  .getErrorString());
        }
      });
    });
  }

  Widget _getSubjectDropDown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor)),
        child: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Icon(
                  Icons.room_preferences_outlined,
                  color: Colors.grey[700],
                  size: 27,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: DropdownButton<String>(
                    value: selectedSection,
                    items: sectionList.map((value) {
                      return DropdownMenuItem<String>(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (item) {
                      selectedSection = item;
                      setState(() {});
                    },
                    underline: SizedBox(),
                    hint: Text("Select Subject"),
                    isExpanded: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
