import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/horizontal_sized_box.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/updateLocalStorageServices.dart';
import 'package:ioc_chatbot/Backend/services/uploadFileServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/views/editProfile.dart';
import 'package:localstorage/localstorage.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;

  UserModel userModel = UserModel();
  UserModel advModel = UserModel();

  ProgressDialog pr;
  UserServices _userServices = UserServices();
  UploadFileServices _uploadFileServices = UploadFileServices();
  UpdateLocalStorageData _updateLocalStorageData = UpdateLocalStorageData();
  File _image;

  File _file;

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    return Scaffold(
        appBar: AppBar(
          leading: Container(
            height: 1,
            width: 1,
          ),
          title: Text(
            "profile",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22),
          ).tr(),
          centerTitle: true,
        ),
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
                  if (adv != null)
                    advModel = UserModel(
                      regNo: adv['regNo'],
                      semester: adv['semester'],
                      email: adv['email'],
                      firstName: adv['firstName'],
                      lastName: adv['lastName'],
                      docID: adv['docID'],
                      profilePic: adv['profilePic'],
                      gender: adv['gender'],
                    );
                }

                initialized = true;
              }
              return snapshot.data == null ? LoadingWidget() : _getUI(context);
            }));
  }

  getAdv() {
    try {
      return advModel.docID;
    } catch (e) {
      return null;
    }
  }

  Widget _getUI(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _getCover(context),
            DynamicFontSize(
              label: "about_me",
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            VerticalSpace(16),
            customListTile(
                context, Icons.school, "Semester: ${userModel.semester}", ''),
            VerticalSpace(10),
            customRow(context, Icons.mail, userModel.email),
            VerticalSpace(10),
            customRow(context, Icons.format_list_numbered, userModel.regNo),
            VerticalSpace(10),
            if (getAdv() != null)
              customListTile(context, Icons.person, 'assign_adv',
                  advModel.firstName + " " + advModel.lastName),
            VerticalSpace(10),
            AppButton(
              isDark: true,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfile(userModel)));
              },
              text: "Edit",
            ),
            VerticalSpace(10),
          ],
        ),
      ),
    );
  }

  _getCover(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
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
                      child: _file == null
                          ? Image.network(
                              userModel.profilePic ?? "",
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _file,
                              fit: BoxFit.cover,
                            )),
                ),
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    icon: Icon(Icons.upload_outlined),
                    onPressed: () => getFile(false)),
              ),
            ),
          ],
        ),
        VerticalSpace(20),
        DynamicFontSize(
          label: userModel.firstName + " " + userModel.lastName,
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        // if (_file != null)
        //   RaisedButton(
        //     onPressed: () async {
        //       await pr.show();
        //
        //       _uploadFileServices.getUrl(context, file: _file).then((value) {
        //         _userServices.editDP(userModel:userModel,imageUrl: value);
        //       }).then((value) async {
        //         _updateLocalStorageData
        //             .updateLocalStorageData(userModel.docID, userModel)
        //             .then((value) => storage.setItem(
        //                 BackEndConfigs.userDetailsLocalStorage,
        //                 value.toJson(value.docID)));
        //
        //         await pr.hide();
        //         showNavigationDialog(context,
        //             message: "Profile Pic Updated Successfully",
        //             buttonText: "Okay",
        //             navigation: () => Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                     builder: (context) => StudentsHomeView())),
        //             secondButtonText: "secondButtonText",
        //             showSecondButton: false);
        //       });
        //     },
        //     child: Text("Update Pic"),
        //   )
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

  customRow(BuildContext context, IconData iconData, String text) {
    return Container(
      color: FrontEndConfigs.authFieldBackgroundColor,
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
                  Icon(
                    iconData,
                    color: FrontEndConfigs.blueTextColor,
                  ),
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

  customListTile(
      BuildContext context, IconData iconData, String title, String subtitle) {
    return Container(
      color: FrontEndConfigs.authFieldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Icon(
                iconData,
                color: FrontEndConfigs.blueTextColor,
              ),
            ),
            subtitle:
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Flexible(
                child: DynamicFontSize(
                  label: subtitle,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            ]),
            title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Flexible(
                child: DynamicFontSize(
                  label: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            ]),

            /// It's a useless text used to Align the design

            trailing: DynamicFontSize(
              label: 'Student',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
