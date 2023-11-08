import 'package:flutter/material.dart';
import 'package:gruasgo/src/pages/login/login_usr_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gruasgo/src/utils/snackbar.dart' as utils;


String username = "";
const String url = "https://nesasbolivia.com/gruasgo/login.php";
final Uri uri = Uri.parse(url);

class loginController{

  BuildContext? context;

  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  Future? init(BuildContext context) async{
    this.context = context;
  }

  void saveTypeUsuario(String key, String typeUser) async{
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
        return null;
      } else {
        String tipusuario = datauser['TipoUsuario'];
        String nombreusuario = datauser['NombreApe'];
        String licencia = datauser['CI'];
        String estado = datauser['Estado'];

        UserModel user = UserModel(email: emailController.text, nombreusuario: nombreusuario, TipoUsuario: tipusuario, idUsuario: licencia);

        saveTypeUsuario('typeUser',user.TipoUsuario);
        saveTypeUsuario('sPe_NombreApe',user.nombreusuario);
        saveTypeUsuario('sPe_Licencia',licencia);
        saveTypeUsuario('sPe_Estado',estado);

        if (user.TipoUsuario == 'usu') {
          String userme = user.nombreusuario;
          Navigator.pushNamedAndRemoveUntil(
              context!, 'bienbendioUsuario', (route) => false,
              arguments: userme);
        }
        if (user.TipoUsuario == 'conduc') {
          String placa = datauser['placa'];
          saveTypeUsuario('sPe_Placa',placa);
          Navigator.pushNamedAndRemoveUntil(
              context!, 'bienbenidoConductor', (route) => false);
        }
        if (user.TipoUsuario == 'adm') {
          Navigator.pushNamedAndRemoveUntil(
              context!, 'MenuAdmin', (route) => false);
        }

        return user;
      }
    } else {
      utils.Snackbar.showSnackbar(context!, key, 'ERROR en la solicitud de incio de sesion.');
      return null;
    }
  }

  void loginOld(){

    //String email = emailController.text;
    //String password = passwordController.text;
    
    //print('Email: $email');
    //print('Pass: $password');
  }

  void goToRegistroUsuario(){
    if (context != null) {
      Navigator.pushNamed(context!, 'RegistroUsuario');
    }
  }

}