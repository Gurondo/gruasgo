import 'package:flutter/material.dart';

class HomeController{
  BuildContext? context;
  Future? init(BuildContext context){
    this.context = context;
  }

  void goToLoginPage(){
    if (context != null) {
      Navigator.pushNamed(context!, 'login');
    }
  }
}