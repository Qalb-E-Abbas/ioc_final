import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (builder) => LoginView()));
                  },
                  child: Text('Students App')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => TeacherLoginView()));
                  },
                  child: Text('Teachers App')),
            ],
          ),
        ),
      ),
    );
  }
}
