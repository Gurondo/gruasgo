import 'package:flutter/material.dart';
import 'package:gruasgo/src/pages/login/login_usr_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gruasgo/src/utils/snackbar.dart' as utils;

String username = "";
final String url = "https://nesasbolivia.com/gruasgo/login.php";
final Uri uri = Uri.parse(url);


class loginController{

  BuildContext? context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();


  Future? init(BuildContext context){
    this.context = context;
  }

  Future<UserModel?> login() async {
    final response = await http.post(uri, body: {
      "btip": 'LOGIN',
      "busuario": emailController.text,
      "bpassword": passwordController.text,
    });

    if (response.statusCode == 200) {
      var datauser = json.decode(response.body);
      if (datauser.length == 0) {
        utils.Snackbar.showSnackbar(context!, key, 'Usuario o contraseña incorrectos.');
/*        scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("El Usuario o contraseña incorrectos."),
          ),
        );*/
        return null;
      } else {

        String nombreusuario = datauser[0]['NombreApe'];
        String tipusuario = datauser[0]['TipoUsuario'];
        UserModel user = UserModel(email: emailController.text, nombreusuario: nombreusuario, TipoUsuario: tipusuario);
        //print("esto si funciona gustavo");
        return user;
      }
    } else {
      utils.Snackbar.showSnackbar(context!, key, 'ERROR en la solicitud de incio de sesion.');
      return null;
    }
  }

  void loginOld(){

    String email = emailController.text;
    String password = passwordController.text;
    
    print('Email: $email');
    print('Pass: $password');
  }

  void goToRegistroUsuario(){
    if (context != null) {
      //Navigator.pushNamed(context!, 'RegistroUsuario');
      Navigator.pushNamed(context!, 'RegistroConductor');
    }
  }

}