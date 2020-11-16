import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Status {Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Unauthenticated;

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User get user => _user;

  Future<bool> add_user(String email, String password) async{
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e){
      _status = Status.Unauthenticated;
      notifyListeners();
      throw e;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      print('got here');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('sign in succeded');
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}