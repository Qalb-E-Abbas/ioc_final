import 'package:flutter/material.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/views/students/language_view.dart';
import 'package:ioc_chatbot/views/students/loginView.dart';
import 'package:ioc_chatbot/views/teachers/teacher_loginView.dart';
import 'package:ioc_chatbot/views/teachers/wrapper.dart';

import 'views/students/loginView.dart';
import 'views/students/wrapper.dart';

class BothApps extends StatefulWidget {
  const BothApps({Key key}) : super(key: key);

  @override
  _BothAppsState createState() => _BothAppsState();
}

class _BothAppsState extends State<BothApps> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              VerticalSpace(20),

              Container(
                height: MediaQuery.of(context).size.height * 0.36,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // borderRadius: BorderRadius.circular(200),

                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/screen1.png',
                    ),
                  ),
                ),
              ),
              VerticalSpace(100,),
              AppButton(
                width: MediaQuery.of(context).size.width * 0.7,
                text: 'Students',
                isDark: true,
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (builder) => LoginView()));
                },
              ),
              VerticalSpace(15),
              AppButton(
                  width: MediaQuery.of(context).size.width * 0.7,
                  text: 'Teachers',
                  isDark: true,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => TeacherLoginView()));
                  }),

              VerticalSpace(15),

              AppButton(
                  width: MediaQuery.of(context).size.width * 0.7,
                  text: 'Change Language',
                  isDark: true,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => LanguageView()));
                  }),

            ],
          ),
        ),
      ),
    );
  }
}
