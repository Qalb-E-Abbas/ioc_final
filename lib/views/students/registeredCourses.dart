import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/app_state.dart';
import 'package:ioc_chatbot/common/appBar.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/Backend/models/subjectModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/views/elements/navigation_dialog.dart';
import 'package:ioc_chatbot/views/students/student_homeView.dart';
import 'package:localstorage/localstorage.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class RegisteredCourse extends StatefulWidget {
  @override
  _RegisteredCourseState createState() => _RegisteredCourseState();
}

class _RegisteredCourseState extends State<RegisteredCourse> {
  List<SubjectModel> subModel = [
    SubjectModel(subjectID: "1", subjectName: "DBMS"),
    SubjectModel(subjectID: "2", subjectName: "ITC"),
    SubjectModel(subjectID: "3", subjectName: "CPP"),
  ];
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;

  UserModel userModel = UserModel();

  List<String> selectedSubject = [];

  UserServices _userServices = UserServices();
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    return Scaffold(
        appBar: customAppBar(context, text: "Registered Courses"),
        body: FutureBuilder(
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
                    regNo: items['regNo'],
                    semester: items['semester'],
                    email: items['email'],
                    firstName: items['firstName'],
                    lastName: items['lastName'],
                    docID: items['docID'],
                    profilePic: items['profilePic'],
                    gender: items['gender'],
                  );
                }

                initialized = true;
              }
              return snapshot.data == null ? LoadingWidget() : _getUI(context);
            }));
  }

  Widget _getUI(BuildContext context) {
    var status = Provider.of<AppState>(context);
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            itemCount: subModel.length,
            itemBuilder: (context, i) {
              return ListTile(
                onTap: () {
                  if (selectedSubject.contains(subModel[i].subjectID)) {
                    selectedSubject.remove(subModel[i].subjectID);
                  } else {
                    selectedSubject.add(subModel[i].subjectID);
                  }
                  setState(() {});
                },
                title: Text(subModel[i].subjectName),
                trailing: Icon(!selectedSubject.contains(subModel[i].subjectID)
                    ? Icons.check_box_outline_blank
                    : Icons.check_box),
              );
            }),
        VerticalSpace(30),
        AppButton(
          isDark: true,
          text: "Register Courses",
          onTap: () async {
            await pr.show();
            _userServices
                .addSubjects(context,
                    userModel: userModel, subjects: selectedSubject)
                .then((value) async {
              if (status.getStateStatus() == StateStatus.IsFree) {
                await pr.hide();
                showNavigationDialog(context,
                    message: "Subject Registered Successfully",
                    buttonText: "Okay", navigation: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentsHomeView()));
                }, secondButtonText: "", showSecondButton: false);
              }
            });
          },
        )
      ],
    );
  }
}
