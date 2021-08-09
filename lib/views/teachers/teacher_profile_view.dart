import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/common/appBar.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/horizontal_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/views/editProfile.dart';
import 'package:ioc_chatbot/views/teachers/teacher_homeView.dart';
import 'package:localstorage/localstorage.dart';

class TeacherProfileView extends StatefulWidget {
  @override
  _TeacherProfileViewState createState() => _TeacherProfileViewState();
}

class _TeacherProfileViewState extends State<TeacherProfileView> {
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  UserModel userModel = UserModel();
  bool initialized = false;
  File _image;

  File _file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context, text: "profile", showArrow: false),
        body: FutureBuilder(
            future: storage.ready,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!initialized) {
                var items =
                    storage.getItem(BackEndConfigs.userDetailsLocalStorage);

                if (items != null) {
                  print(items);
                  userModel = UserModel(
                    regNo: items['regNo'],
                    semester: items['semester'],
                    email: items['email'],
                    firstName: items['firstName'],
                    lastName: items['lastName'],
                    docID: items['docID'],
                    profilePic: items['profilePic'],
                    gender: items['gender'],
                    subjects: items['subjects'],
                  );
                }

                initialized = true;
              }
              return snapshot.data == null ? LoadingWidget() : _getUI(context);
            }));
  }

  Widget _getUI(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpace(20),
            _getCover(context),
            VerticalSpace(30),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: DynamicFontSize(
                label: "about_me",
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            VerticalSpace(16),
            customRow(context, 'assets/images/mail.png', userModel.email),
            VerticalSpace(10),
            customRow(context, 'assets/images/regNo.png', userModel.regNo),
            VerticalSpace(24),
            AppButton(
              width: MediaQuery.of(context).size.width * 0.45,
              isDark: true,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfile(userModel)));
              },
              text: "edit",
            ),
          ],
        ),
      ),
    );
  }

  _getCover(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        VerticalSpace(20),

        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                userModel.profilePic,
                fit: BoxFit.cover,
              )),
        ),

        VerticalSpace(15),


        Align(
            alignment: Alignment.bottomCenter,
            child: DynamicFontSize(
              label: userModel.firstName + " " + userModel.lastName,
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ))
      ],
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

  customRow(BuildContext context, String imageUrl, String text) {
    return Container(
      color: AppColors.authFieldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                children: [
                  Image.asset(imageUrl, height: 20,),
                  HorizontalSpace(30),
                  Flexible(
                    child: DynamicFontSize(
                      label: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
