import 'package:flutter/cupertino.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';


class UserProvider extends ChangeNotifier {
  List<UserModel> _usersList = [];

  void setUsersList(List<UserModel> usersList) {
    _usersList = usersList;
    notifyListeners();
  }

  void setUsers(UserModel userModel) {
    _usersList.add(userModel);

    notifyListeners();
  }

  void clearList() {
    _usersList.clear();
    notifyListeners();
  }

  List<UserModel> get getUsers => _usersList;
}
