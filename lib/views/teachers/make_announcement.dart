import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/app_state.dart';
import 'package:ioc_chatbot/common/appBar.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/Backend/models/postModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/postServices.dart';
import 'package:ioc_chatbot/Backend/services/uploadFileServices.dart';
import 'package:ioc_chatbot/views/elements/navigation_dialog.dart';
import 'package:ioc_chatbot/views/teachers/teacher_homeView.dart';
import 'package:localstorage/localstorage.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class MakeAnnouncement extends StatefulWidget {
  const MakeAnnouncement({Key key}) : super(key: key);

  @override
  _MakeAnnouncementState createState() => _MakeAnnouncementState();
}

class _MakeAnnouncementState extends State<MakeAnnouncement> {
  File _file;
  TextEditingController _textController = TextEditingController();
  PostServices _postServices = PostServices();
  UploadFileServices _uploadFileServices = UploadFileServices();
  ProgressDialog pr;
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  List<String> sectionList = ["A", "B"];
  String selectedSection;
  bool initialized = false;

  UserModel userModel = UserModel();

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);

    return Scaffold(
        appBar: customAppBar(context, text: 'sub_announcement', showArrow: false),
        body: FutureBuilder(
            future: storage.ready,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!initialized) {
                var items =
                    storage.getItem(BackEndConfigs.userDetailsLocalStorage);
                var adv =
                    storage.getItem(BackEndConfigs.advisorDetailsLocalStorage);
                print("good");
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
                    subjectIDs: items['subjectIDs'],
                  );
                }

                initialized = true;
              }
              return snapshot.data == null ? LoadingWidget() : _getUI(context);
            }));
  }

  Widget _getUI(BuildContext context) {
    print(userModel.toJson(userModel.docID));
    var status = Provider.of<AppState>(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              VerticalSpace(20),
              Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: AppColors.authFieldBackgroundColor,
                    border: Border.all(color: AppColors.backgroundScreen),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _textController,
                    style: TextStyle(
                        letterSpacing: 1,
                        color: AppColors.authTextFieldLabelColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                        hintText: 'description'.tr(),
                        filled: true,
                        fillColor: AppColors.authFieldBackgroundColor,
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
                            color: AppColors.authTextFieldLabelColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                  )),
              VerticalSpace(10),
              _getSubjectDropDown(context),
              VerticalSpace(10),
              _getImagePicker(context),
              VerticalSpace(30),
              AppButton(
                onTap: () async {
                  await pr.show();
                  _createPost(status);
                },
                text: 'submit',

                isDark: true,
              )
            ],
          ),
        ),
      ),
    );
  }

  _getImagePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.backgroundScreen)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Flexible(
                  child: DynamicFontSize(
                    label: _file == null
                        ? "attach_image"
                        : _file.path.split('/').last,
                    fontSize: 16,
                    isAlignCenter: false,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: () => getFile(),
                child: Icon(
                  Icons.attach_file,
                  color: Colors.black,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getFile() async {
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

  _createPost(AppState status) async {
    var user = Provider.of<User>(context, listen: false);
    await _uploadFileServices
        .getUrl(context, file: _file)
        .then((fileUrl) async {
      await _postServices.createPost(
        context,
        model: PostModel(
            postImageName: _file.path.split('/').last,
            postImage: fileUrl,
            section: selectedSection,
            subject: userModel.subjectIDs,
            advImage: userModel.profilePic,
            advID: userModel.docID,
            sortTime: DateTime.now().microsecondsSinceEpoch,
            time:

            "${DateFormat('hh:mm a').format(DateTime.now())},"
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            postText: _textController.text),
      );
    }).then((value) async {
      if (status.getStateStatus() == StateStatus.IsFree) {
        await pr.hide();
        showNavigationDialog(context,
            message: "Announcement created successfully.",
            buttonText: "Okay", navigation: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TeacherHomeView()));
        }, secondButtonText: "", showSecondButton: false);
      }
    });
  }

  Widget _getSubjectDropDown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.backgroundScreen)),
        child: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.room_preferences_outlined,
                  color: Colors.black,
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
                    hint: Text("select_sec").tr(),
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
