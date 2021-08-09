
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String image;
  final bool isPasswordField;
  final bool visible;
  final int maxLines;
  final Function(String) validator;
  final TextEditingController controller;
  final VoidCallback onEditingComplete;
  final VoidCallback onPwdTap;
  AuthTextField(
      {this.label,
      this.image,
      this.onEditingComplete,
      this.maxLines = 1,
      this.validator,
      this.controller,
      this.onPwdTap,
      this.isPasswordField = false,
      this.visible = false});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            height: 61,
            child: TextFormField(
              validator: (val) => validator(val),
              maxLines: maxLines,
              controller: controller,
              obscureText: visible,
              onEditingComplete: () => onEditingComplete(),
              style: TextStyle(
                  letterSpacing: 1,
                  color: AppColors.authTextFieldLabelColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.authFieldBackgroundColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        left: 19.0, top: 19, bottom: 19, right: 10),
                    child: Image.asset(
                      image,
                      height: 19,
                      width: 13,
                    ),
                  ),
                  suffixIcon: isPasswordField
                      ? InkWell(
                          onTap: () => onPwdTap(),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 19.0, top: 19, bottom: 19, right: 10),
                            child: visible
                                ? Icon(CupertinoIcons.eye_slash)
                                : Image.asset(
                                    "assets/images/Show.png",
                                  ),
                          ),
                        )
                      : null,
                  hintText: label.tr(),
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
            ),
          ),
        ),
      ],
    );
  }
}
