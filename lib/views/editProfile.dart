import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/common/appBar.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/authTextField.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/updateLocalStorageServices.dart';
import 'package:ioc_chatbot/Backend/services/uploadFileServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/views/students/student_homeView.dart';
import 'package:ioc_chatbot/views/teachers/teacher_homeView.dart';
import 'package:localstorage/localstorage.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'elements/navigation_dialog.dart';

class EditProfile extends StatefulWidget {
  final UserModel model;

  const EditProfile(this.model);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _firstNameController;

  TextEditingController _lastNameController;
  File _image;

  File _file;
  ProgressDialog pr;
  UserServices _userServices = UserServices();
  UploadFileServices _uploadFileServices = UploadFileServices();
  UpdateLocalStorageData _updateLocalStorageData = UpdateLocalStorageData();
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  @override
  void initState() {
    // TODO: implement initState
    _firstNameController = TextEditingController(text: widget.model.firstName);
    _lastNameController = TextEditingController(text: widget.model.lastName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: true);
    return Scaffold(
      appBar: customAppBar(context, text: "edit_profile", showArrow: false),
      body: _getUI(context),
    );
  }

  Widget _getUI(BuildContext context) {
    print(widget.model.lastName);
    return Column(
      children: [

        VerticalSpace(20),

        _getCover(context),

        VerticalSpace(20),
        AuthTextField(
          image: "assets/images/person.png",
          controller: _firstNameController,
          label: "First Name",
        ),
        AuthTextField(
          image: "assets/images/person.png",
          controller: _lastNameController,
          label: "Last Name",
        ),

        VerticalSpace(10),

        AppButton(
          width: MediaQuery.of(context).size.width * 0.4,
          isDark: true,
          text: "save",
          onTap: () async {
            await pr.show();
            _getEditData();
          },
        ),
      ],
    );
  }

  _getEditData() async {
    if (_file != null) {
      return await _uploadFileServices
          .getUrl(context, file: _file)
          .then((value) {
        _userServices.editDP(
            userModel: widget.model,
            imageUrl: value,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text);
      }).then((value) async {
        _updateLocalStorageData
            .updateLocalStorageData(widget.model.docID, widget.model)
            .then((value) => storage.setItem(
                BackEndConfigs.userDetailsLocalStorage,
                value.toJson(value.docID)));

        await pr.hide();
        showNavigationDialog(context,
            message: "Profile Updated Successfully",
            buttonText: "Okay",
            navigation: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => StudentsHomeView())),
            secondButtonText: "secondButtonText",
            showSecondButton: false);
      });
    } else {
      _userServices
          .editDP(
              userModel: widget.model,
              imageUrl: widget.model.profilePic,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text)
          .then((value) async {
        _updateLocalStorageData
            .updateLocalStorageData(widget.model.docID, widget.model)
            .then((value) => storage.setItem(
                BackEndConfigs.userDetailsLocalStorage,
                value.toJson(value.docID)));

        await pr.hide();
        if (widget.model.role == "S") {
          showNavigationDialog(context,
              message: "Profile Updated Successfully",
              buttonText: "Okay",
              navigation: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StudentsHomeView())),
              secondButtonText: "secondButtonText",
              showSecondButton: false);
        } else {
          showNavigationDialog(context,
              message: "Profile Updated Successfully",
              buttonText: "Okay",
              navigation: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TeacherHomeView())),
              secondButtonText: "secondButtonText",
              showSecondButton: false);
        }
      });
    }
    //
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
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _file == null
                          ? Image.network(
                              widget.model.profilePic ?? "",
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
                    icon: Icon(Icons.upload_outlined, size: 30, color: AppColors.backgroundScreen,),
                    onPressed: () => getFile(false)),
              ),
            ),
          ],
        ),
        // if (_file != null)
        // RaisedButton(
        //   onPressed: () async {
        //     await pr.show();
        //
        //     _uploadFileServices.getUrl(context, file: _file).then((value) {
        //       _userServices.editDP(userModel, value);
        //     }).then((value) async {
        //       _updateLocalStorageData
        //           .updateLocalStorageData(userModel.docID, userModel)
        //           .then((value) => storage.setItem(
        //               BackEndConfigs.userDetailsLocalStorage,
        //               value.toJson(value.docID)));
        //
        //       await pr.hide();
        //       showNavigationDialog(context,
        //           message: "Profile Pic Updated Successfully",
        //           buttonText: "Okay",
        //           navigation: () => Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => StudentsHomeView())),
        //           secondButtonText: "secondButtonText",
        //           showSecondButton: false);
        //     });
        //   },
        //   child: Text("Update Pic"),
        // )
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
}
