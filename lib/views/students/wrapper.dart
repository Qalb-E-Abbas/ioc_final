import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/views/students/loginView.dart';
import 'package:ioc_chatbot/views/students/student_homeView.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  bool isLoggedIn = false;

  Future<bool> getUserLoginState() async {
    return await UserLoginStateHandler.getUserLoggedInSharedPreference();
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
    return isLoggedIn ? StudentsHomeView() : LoginView();
  }
}
