import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/updateLocalStorageServices.dart';
import 'package:ioc_chatbot/Logics/app_state.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class UserServices {

  ///Initializing LocalDB
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  /// Creating model object
  UserModel _userModel = UserModel();

  /// Creating getter
  UserModel get userModel => _userModel;


  /// Collection Reference of IOC Users
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection('iocUsers');

  ///Add IOC Users data to Cloud Firestore
  Future<void> addIocData(
      User user, UserModel stdModel, BuildContext context) {
    return _ref.doc(user.uid).set(stdModel.toJson(user.uid));
  }


  ///Login User via Reg No
  Stream<List<UserModel>> loginViaRegNO({String regNo, String password}) {
    return _ref
        .where('regNo', isEqualTo: regNo)
        .where('password', isEqualTo: password)
        .snapshots()
        .map((snap) =>
            snap.docs.map((e) => UserModel.fromJson(e.data())).toList());
  }


  ///Fetch IOC Users data
  Stream<UserModel> fetchStudentsData(String docID) {
    print("I am $docID");
    return _ref
        .doc(docID)
        .snapshots()
        .map((snap) => UserModel.fromJson(snap.data()));
  }

  ///Edit LoggedIn IOC Users Data
  Future<void> editDP(
      {UserModel userModel,
      String imageUrl,
      String firstName,
      String lastName}) async {
    print(userModel.docID);
    return _ref.doc(userModel.docID).update(
        {'profilePic': imageUrl, 'firstName': firstName, 'lastName': lastName});
  }

  ///Add Subjects
  Future<void> addSubjects(BuildContext context,
      {UserModel userModel, List subjects}) async {
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsBusy);
    print(userModel.docID);
    await _ref.doc(userModel.docID).update({
      'subjects': FieldValue.arrayUnion(subjects),
    });
    Provider.of<AppState>(context, listen: false)
        .stateStatus(StateStatus.IsFree);
  }

  ///Get My Advisor
  Stream<List<UserModel>> getMyAdvisor(BuildContext context, {String regNo}) {
    return _ref.where('students', arrayContains: regNo).snapshots().map(
        (snap) => snap.docs.map((e) => UserModel.fromJson(e.data())).toList());
  }

  ///Go Offline/Online
  Future<void> changeOnlineStatus({UserModel userModel, bool isOnline}) async {
    await _ref.doc(userModel.docID).update({
      'isOnline': isOnline,
    });
  }

  Future<void> updateLastSeen({UserModel userModel, String time}) async {
    await _ref.doc(userModel.docID).update({
      'lastSeen': time,
    });
  }


  /// Fetch all teachers

  Stream<List<UserModel>> fetchAllTeachers(UserModel userModel) {
    return _ref

    /// Don't get students, but teachers
        .where('docID', isNotEqualTo: userModel.docID)
        .where('role', isEqualTo: "T")
        .snapshots()
        .map((event) =>
            event.docs.map((e) => UserModel.fromJson(e.data())).toList());
  }


  /// Fetch Students via reg no ????? WHAT?
  Stream<List<UserModel>> fetchStudentsViaRegNo(UserModel userModel) {
    return _ref
        .where('docID', isNotEqualTo: userModel.regNo)
        .where('role', isEqualTo: "S")
        .snapshots()
        .map((event) =>
            event.docs.map((e) => UserModel.fromJson(e.data())).toList());
  }
}
