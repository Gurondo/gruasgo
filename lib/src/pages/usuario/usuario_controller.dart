import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:gruasgo/src/utils/my_progress_dialog.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:gruasgo/src/utils/snackbar.dart' as utils;
import 'package:http/http.dart' as http;

const String url = "http://3.14.79.171/gruasgo/usuarios.php";
final Uri uri = Uri.parse(url);

class usuarioRegisterController {

  BuildContext? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController monbreapellidoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  ProgressDialog? _progressDialog;

  Future? init (BuildContext context) {
    this.context = context;
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere....');
    return null;
  }

  void registerUsuario() async {

    String email = emailController.text.trim();
    String username = monbreapellidoController.text.trim();
    String celular = celularController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty) {
      utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar tu nombre');
      return;
    }else{
      if (email.isEmpty) {
        utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar tu correo electronico');
        return;
      }else{
        if (celular.isEmpty){
          utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar tu numero de celular');
          return;
        }else{
          if (password.isEmpty){
            utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar una contraseña');
            return;
          }else{
              if (password.length < 4) {
                utils.Snackbar.showSnackbar(context!, key, 'el password debe tener al menos 4 caracteres');
                return;
              }else{
                try {
                  //bool isRegister = await _authProvider.register(email, password);
                  _progressDialog?.show();
                  final response = await http.post(uri, body: {
                    "btip": 'ADD',
                    "busuario": emailController.text,
                    "bnombreap": monbreapellidoController.text,
                    "bcelular": celularController.text,
                    "bpassword": passwordController.text,
                  });
                  var datauser = json.decode(response.body);
                  String respuesta = datauser['success'];
                  if (respuesta == "si") {
                    for (int i = 0; i <= 100; i += 10) {
                      _progressDialog?.update(
                        progress: i.toDouble(), // Actualiza el progreso
                        message: "Cargando: $i%", // Actualiza el mensaje
                      );
                      await Future.delayed(const Duration(milliseconds: 100));
                    }
                    _progressDialog?.hide();
                    //Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
                    Navigator.pushNamedAndRemoveUntil(context!, 'bienbendioUsuario', (route) => false,arguments: monbreapellidoController.text);
                    utils.Snackbar.showSnackbar(context!, key, 'El usuario se registro correctamente');
                  }
                  else {
                    _progressDialog?.hide();
                    utils.Snackbar.showSnackbar(context!, key, 'El celular o correo ya se encuentra registrado');
                  }

                } catch(error) {
                  _progressDialog?.hide();
                  utils.Snackbar.showSnackbar(context!, key, 'Error: $error');
                  print('Error: $error');
                }
              }
          }
        }
      }
    }
/*    if (confirmPassword != password) {
      print('Las contraseñas no coinciden');
      utils.Snackbar.showSnackbar(context!, key, 'Las contraseñas no coinciden');
      return;
    }*/
  }
}