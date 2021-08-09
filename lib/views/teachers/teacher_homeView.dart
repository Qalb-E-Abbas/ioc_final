import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/views/elements/navigation_dialog.dart';
import 'package:ioc_chatbot/views/teachers/make_announcement.dart';
import 'package:ioc_chatbot/views/teachers/student_chatList.dart';
import 'package:ioc_chatbot/views/teachers/teacher_profile_view.dart';
import 'package:localstorage/localstorage.dart';
import 'package:easy_localization/easy_localization.dart';

import 'makeAdvAnnouncements.dart';

class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({Key key}) : super(key: key);

  @override
  _TeacherHomeViewState createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  int currentPage = 0;
  PageController _pageController;

  List pages = [];

  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;
  UserModel userModel = UserModel();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  initState() {
    _initFcm();
    UserLoginStateHandler.saveUserLoggedInSharedPreference(true);
    super.initState();
  }

  Future<void> _initFcm() async {
    print("Firebase Token");
    var uid = FirebaseAuth.instance.currentUser.uid;
    _firebaseMessaging.getToken().then((token) {
      FirebaseFirestore.instance.collection('deviceTokens').doc(uid).set(
        {
          'deviceTokens': token,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return showNavigationDialog(context,
              message: "Do you really want to exit?",
              buttonText: "Yes", navigation: () {
            return exit(0);
          }, secondButtonText: "No", showSecondButton: true);
        },
        child: FutureBuilder(
            future: storage.ready,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!initialized) {
                var items =
                    storage.getItem(BackEndConfigs.userDetailsLocalStorage);
                var adv =
                    storage.getItem(BackEndConfigs.advisorDetailsLocalStorage);

                if (items != null) {
                  print(items);
                  userModel = UserModel(
                    isOnline: items['isOnline'],
                    role: items['role'],
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
              return snapshot.data == null
                  ? LoadingWidget()
                  : _getUI(context, userModel);
            }));
  }

  Widget _getUI(BuildContext context, UserModel _model) {
    return Scaffold(

      bottomNavigationBar: BottomNavyBar(
        backgroundColor: AppColors.backgroundScreen,
        selectedIndex: currentPage,
        showElevation: false,
        itemCornerRadius: 24,
        curve: Curves.easeInOutCubic,
        onItemSelected: (index) => setState(() => currentPage = index),
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(Icons.message_outlined),
            title: Text('chats').tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.notifications_active_outlined),
            title: Text('advisor').tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.notification_important),
            title: Text('subject').tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text(
              'my_profile',
            ).tr(),
            activeColor: AppColors.blackColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      body: getPages(context, currentPage, _model),
    );
  }

  Widget getPages(BuildContext context, int currentPage, UserModel _model) {
    if (currentPage == 0) {
      return TeacherChatList(_model);
    } else if (currentPage == 1) {
      return MakeAdvAnnouncmnts();
    } else if (currentPage == 2) {
      return MakeAnnouncement();
    } else if (currentPage == 3) {
      return TeacherProfileView();
    }
  }
}
