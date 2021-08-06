import 'package:flutter/cupertino.dart';
import 'package:ioc_chatbot/Backend/services/authServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/enums.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'errorStrings.dart';

class LoginBusinessLogic {
  UserServices _userServices = UserServices();
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  Future loginUserLogic(
    BuildContext context, {
    @required String regNo,
    @required String password,
  }) async {
    var _authServices = Provider.of<AuthServices>(context, listen: false);
    var _error = Provider.of<ErrorString>(context, listen: false);
    var login = Provider.of<AuthServices>(context, listen: false);
    _authServices.setState(Status.Authenticating);
    await _userServices
        .loginViaRegNO(regNo: regNo, password: password)
        .first
        .then((value) async {
      print(value);
      if (value.isNotEmpty) {
        await storage.setItem(BackEndConfigs.userDetailsLocalStorage,
            value[0].toJson(value[0].docID));
        _authServices.setState(Status.Authenticated);

        return _userServices
            .getMyAdvisor(context, regNo: regNo)
            .first
            .then((value) async {
          if (value.isNotEmpty)
            await storage.setItem(BackEndConfigs.advisorDetailsLocalStorage,
                value[0].toJson(value[0].docID));
        });
      } else {
        Provider.of<ErrorString>(context, listen: false)
            .saveErrorString("Please provide valid credentials.");
        _authServices.setState(Status.Unauthenticated);
      }
    });
  }

  Future teacherLoginUserLogic(
    BuildContext context, {
    @required String regNo,
    @required String password,
  }) async {
    var _authServices = Provider.of<AuthServices>(context, listen: false);
    var _error = Provider.of<ErrorString>(context, listen: false);
    var login = Provider.of<AuthServices>(context, listen: false);
    await _userServices
        .loginViaRegNO(regNo: regNo, password: password)
        .first
        .then((value) async {
      print(value);
      if (value.isNotEmpty) {
        await storage.setItem(BackEndConfigs.userDetailsLocalStorage,
            value[0].toJson(value[0].docID));
        _authServices.setState(Status.Authenticated);
      } else {
        Provider.of<ErrorString>(context, listen: false)
            .saveErrorString("Please provide valid credentials.");
        _authServices.setState(Status.Unauthenticated);
      }
    });
  }
}
