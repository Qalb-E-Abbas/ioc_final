
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';

import 'dynamicFontSize.dart';

class AppButton extends StatelessWidget {
  final String text;
  final bool isDark;
  final VoidCallback onTap;

  AppButton({this.text, this.isDark, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => onTap(),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
                color: FrontEndConfigs.buttonColor,
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Center(
                  child: DynamicFontSize(
                label: text,
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: isDark
                    ? Colors.white
                    : Theme.of(context).textTheme.headline6.color,
              )),
            ),
          ),
        ),
      ],
    );
  }
}
