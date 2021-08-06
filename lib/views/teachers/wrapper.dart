import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/views/students/loginView.dart';
import 'package:ioc_chatbot/views/students/student_homeView.dart';

import 'teacher_homeView.dart';
import 'teacher_loginView.dart';

class TeacherWrapper extends StatefulWidget {
  @override
  _TeacherWrapperState createState() => _TeacherWrapperState();
}

class _TeacherWrapperState extends State<TeacherWrapper> {
  bool isLoggedIn = false;

  Future<bool> getUserLoginState() async {
    return await UserLoginStateHandler.getTeacherLoggedInSharedPreference();
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserLoginState().then((value) {
      if (value == null) {
        isLoggedIn = false;
      } else {
        isLoggedIn = value;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? TeacherHomeView() : TeacherLoginView();
  }
}
