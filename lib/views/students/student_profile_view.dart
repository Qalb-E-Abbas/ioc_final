import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:ioc_chatbot/common/horizontal_sized_box.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';

class StudentProfileView extends StatefulWidget {
  final String imageUrl;

  StudentProfileView(this.imageUrl);

  @override
  _StudentProfileViewState createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  bool initialized = false;

  File _image;

  File _file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
              color: FrontEndConfigs.darkTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          _file != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {},
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: FrontEndConfigs.blueTextColor),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3),
                        child: Center(
                          child: DynamicFontSize(
                            label: "Update Profile",
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset('assets/images/back.png'),
          ),
        ),
      ),
      body: _getUI(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget _getUI(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpace(20),
            _getCover(context),
            VerticalSpace(120),
            DynamicFontSize(
              label: "About Me",
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            VerticalSpace(16),
            customListTile(
                context, Icons.school, 'Student of 8th semester', 'Section A'),
            VerticalSpace(10),
            customRow(context, Icons.mail, 'qalbeabbas964@gmail.com'),
            VerticalSpace(10),
            customRow(context, Icons.format_list_numbered, 'CS120172041'),
            VerticalSpace(10),
            customListTile(
                context, Icons.person, 'Assigned Advisor:', 'Mr Sana Ullah'),
            VerticalSpace(24),
          ],
        ),
      ),
    );
  }

  _getCover(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Stack(
          children: [
            Container(
              height: 180,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: AssetImage('assets/images/cover.png'),
                      fit: BoxFit.cover)),
            ),
          ],
        ),
        Positioned.fill(
          right: 10,
          bottom: -60,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(widget.imageUrl)),
            ),
          ),
        ),
        Positioned.fill(
            bottom: -90,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: DynamicFontSize(
                  label: 'Qalb E Abbas',
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )))
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
