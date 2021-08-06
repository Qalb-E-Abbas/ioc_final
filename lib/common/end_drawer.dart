import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/authServices.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/Logics/userProvider.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';
import 'package:ioc_chatbot/views/students/language_view.dart';
import 'package:ioc_chatbot/views/students/loginView.dart';
import 'package:ioc_chatbot/views/students/registeredCourses.dart';
import 'package:ioc_chatbot/views/teachers/teacher_loginView.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'dynamicFontSize.dart';
import 'heigh_sized_box.dart';

class EndDrawer extends StatelessWidget {
  AuthServices _services = AuthServices.instance();
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  bool initialized = false;
  UserModel userModel = UserModel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!initialized) {
            var items = storage.getItem(BackEndConfigs.userDetailsLocalStorage);
            var adv =
                storage.getItem(BackEndConfigs.advisorDetailsLocalStorage);

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
                role: items['role'],
              );
            }

            initialized = true;
          }
          return snapshot.data == null ? LoadingWidget() : _getUI(context);
        });
  }

  Widget _getUI(BuildContext context) {
    print(userModel.role);
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: FrontEndConfigs.blueTextColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userModel.profilePic),
                  radius: 50,
                ),
                VerticalSpace(10),
                DynamicFontSize(
                  label: userModel.regNo,
                  fontSize: 14,
                  color: Colors.white,
                )
              ],
            ),
          ),
          if (userModel.role == "S")
            ListTile(
              title: Text('Register Courses').tr(),
              trailing: Icon(
                Icons.app_registration,
                color: Colors.red,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisteredCourse()));
              },
            ),
          ListTile(
            title: Text('Log Out').tr(),
            trailing: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onTap: () {
              var list = Provider.of<UserProvider>(context, listen: false);
              UserLoginStateHandler.saveUserLoggedInSharedPreference(false);
              storage.clear();
              list.setUsersList([]);
              if (userModel.role == "S") {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                    (route) => false);
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherLoginView()),
                    (route) => false);
              }
            },
          ),
          ListTile(
            title: Text('language').tr(),
            trailing: Icon(
              Icons.language,
              color: FrontEndConfigs.blueTextColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) => LanguageView()));
            },
          ),
        ],
      ),
    );
  }
}
