import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';


class UpdateLocalStorageData {

  ///Update Local Storage Data
  Future<UserModel> updateLocalStorageData(String docID, UserModel userModel) {
    print("HI I AM CALLED");
    return FirebaseFirestore.instance
        .collection("iocUsers")
        .doc(docID)
        .get()
        .then((value) {
      return UserModel.fromJson(value.data());
    });
  }

}
