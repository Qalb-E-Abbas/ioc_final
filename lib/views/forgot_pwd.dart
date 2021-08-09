import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Backend/services/authServices.dart';
import 'package:ioc_chatbot/Logics/errorStrings.dart';
import 'package:ioc_chatbot/common/heigh_sized_box.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import '../both_apps.dart';
import '../common/appBar.dart';
import '../common/appButton.dart';
import '../configurations/enums.dart';
import 'elements/dialog.dart';
import 'elements/navigation_dialog.dart';

class ForgotPasswordView extends StatelessWidget {
  TextEditingController _emailController = TextEditingController();
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    return Scaffold(
      appBar: customAppBar(context, text: "Forgot Password"),
      body: _getUI(context),
    );
  }

  Widget _getUI(BuildContext context) {
    return Column(
      children: [


        VerticalSpace(20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your email'
            ),
            controller: _emailController,
          ),
        ),

        VerticalSpace(20),

        AppButton(
          isDark: true,
          text: "submit",
          onTap: () async {
            await pr.show();
            _forgotPassword(context);
          },
        )
      ],
    );
  }

  _forgotPassword(BuildContext context) {
    AuthServices _services = Provider.of<AuthServices>(context, listen: false);
    _services
        .forgotPassword(context, email: _emailController.text)
        .then((val) async {
      await pr.hide();
      if (_services.status == Status.Authenticated) {
        showNavigationDialog(context,
            message:
                "An email with password reset link has been sent to your email inbox",
            buttonText: "Okay", navigation: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BothApps()));
        }, secondButtonText: "", showSecondButton: false);
      } else {
        showErrorDialog(context,
            message: Provider.of<ErrorString>(context, listen: false)
                .getErrorString());
      }
    });
  }
}
