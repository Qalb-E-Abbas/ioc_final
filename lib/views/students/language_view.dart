import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/common/appBar.dart';
import 'package:ioc_chatbot/common/appButton.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/views/students/signUp.dart';
import 'package:ioc_chatbot/views/students/student_homeView.dart';

import 'loginView.dart';


class LanguageView extends StatefulWidget {
  @override
  _LanguageViewState createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {

  List<String> lang = ["English", "Urdu"];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    context.locale == Locale('en', 'US') ? setIndex(0) : setIndex(1);
    return Scaffold(
      appBar: AppBar(
        title: Text('language').tr(),
        leading: InkWell(
          onTap: (){
            Navigator.of(context).pop();

          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Column(
        children: [



          Container(
            height: 300,
            width: double.infinity,
            child: ListView.builder(
                itemCount: lang.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () {
                      setIndex(i);
                      setState(() {});
                      context.locale =
                      i == 0 ? Locale('en', 'US') : Locale('ur', 'UR');
                    },
                    title: Align(
                      alignment: Alignment(-1, 0),
                      child: DynamicFontSize(
                        label: lang[i],
                        fontSize: 15,
                      ),
                    ),
                    trailing: Icon(getIndex == i
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off),
                  );
                }),
          ),
        ],
      ),
    );
  }

  setIndex(int i) {
    index = i;
    setState(() {});
  }

  int get getIndex => index;
}
