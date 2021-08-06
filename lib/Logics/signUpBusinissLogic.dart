import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/authServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';


enum SignUpStatus { Initial, Registered, Registering, Failed }
enum ValidatedStatus { Validated, NotValidated }

class SignUpBusinessLogic with ChangeNotifier {
  SignUpStatus _status = SignUpStatus.Initial;
  ValidatedStatus _vStatus = ValidatedStatus.NotValidated;

  SignUpStatus get status => _status;

  void setState(SignUpStatus status) {
    _status = status;
    notifyListeners();
  }

  AuthServices _authServices = AuthServices.instance();

  UserServices _userServices = UserServices();



  ///Register new user and Add its details in Firestore

  Future registerNewUser(
      {@required String email,
      @required String password,
      @required UserModel userModel,
      @required BuildContext context,
      @required User user}) async {
    _status = SignUpStatus.Registering;
    notifyListeners();

    return _authServices
        .signUp(
      context,
      email: email,
      password: password,
    )
        .then((User user) {
      if (user != null) {
        setState(SignUpStatus.Registered);
        _authServices.signOut();
        _userServices.addIocData(user, userModel, context);
      } else {
        setState(SignUpStatus.Failed);
      }
    });
  }
}
