
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:easy_localization/easy_localization.dart';


customAppBar(
    BuildContext context,
    {@required String text,
    VoidCallback onTap,
    bool showArrow = true}) {
  return AppBar(
    backgroundColor: AppColors.backgroundScreen,
    title: Text(
      text,
      style: TextStyle(
          color: AppColors.darkTextColor,
          fontWeight: FontWeight.w500,
          fontSize: 22),
    ).tr(),
    centerTitle: true,
    leading: showArrow
        ? Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset('assets/images/back.png'),
            ),
          )
        : Container(),
  );
}
