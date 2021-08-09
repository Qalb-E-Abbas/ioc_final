import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:ioc_chatbot/Logics/errorStrings.dart';
import 'package:ioc_chatbot/Logics/signUpBusinissLogic.dart';
import 'package:ioc_chatbot/configurations/enums.dart';
import 'package:provider/provider.dart';

class AuthServices with ChangeNotifier {

  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Uninitialized;
  CollectionReference _db = FirebaseFirestore.instance.collection('iocUsers');

  AuthServices.instance() : _auth = FirebaseAuth.instance {
    _auth.idTokenChanges().listen(_onAuthStateChanged);
  }

  ///Using Stream to listen to Authentication State, we use this in main.dart to get status
  Stream<User> get authState => _auth.authStateChanges();

  ///we are using that to set the login State
  void setState(Status status) {
    _status = status;
    notifyListeners();
  }

  ///we are using thi to current user login State
  Status get status => _status;

  ///we are using that to get the current firebase user.
  User get user => _user;
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('iocUsers');


  /// Sign In
  Future<User> signIn(BuildContext context,
      {String email, String password}) async {
    try {
      setState(Status.Authenticating);
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      setState(Status.Authenticated);
      return user.user;
    } on FirebaseAuthException catch (e) {
      setState(Status.Unauthenticated);
      Provider.of<ErrorString>(context, listen: false)
          .saveErrorString(e.message);
      return null;
    }
  }

  /// USERS REGISTRATION
  Future<User> signUp(BuildContext context,
      {String email, String password}) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return user.user;
    } on FirebaseAuthException catch (e) {
      Provider.of<ErrorString>(context, listen: false)
          .saveErrorString(e.message);
      Provider.of<SignUpBusinessLogic>(context, listen: false)
          .setState(SignUpStatus.Failed);
      return null;
    }
  }

  ///This method is used to reset the password.
  Future forgotPassword(BuildContext context, {String email}) async {
    try {
      setState(Status.Authenticating);
      await _auth.sendPasswordResetEmail(email: email);
      setState(Status.Authenticated);
    } on FirebaseAuthException catch (e) {
      Provider.of<ErrorString>(context, listen: false)
          .saveErrorString(e.message);
      Provider.of<SignUpBusinessLogic>(context, listen: false)
          .setState(SignUpStatus.Failed);
      return null;
    }
  }

  ///Use to signOut user from firebase.
  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }


  /// it constantly checks a user whether user loggedIn or loggedOut
  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
  }




}
