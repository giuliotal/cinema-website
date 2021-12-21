import 'package:cinema_frontend/model/objects/User.dart';
import 'package:flutter/material.dart';

class LoginState with ChangeNotifier {
  bool isLoggedIn = false;
  User currentUser;

  User get user => currentUser;

  void setCurrentUser(user){
    currentUser = user;
    notifyListeners();
  }

  void setLoginState(state){
    isLoggedIn = state;
    notifyListeners();
  }
}