import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:gruasgo/src/utils/my_progress_dialog.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:gruasgo/src/utils/snackbar.dart' as utils;
import 'package:http/http.dart' as http;

const String url = "http://3.14.79.171/gruasgo/conductor.php";
final Uri uri = Uri.parse(url);

const String url1 = "http://3.14.79.171/gruasgo/vehiculo.php";
final Uri uri1 = Uri.parse(url1);

class conductorController {

  BuildContext? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController nombreapeController = TextEditingController();
  TextEditingController numLicenciaController = TextEditingController();
  TextEditingController fechaVencimientoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController domicilioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController placaVehiculoController = TextEditingController();
  TextEditingController ruatVehiculoController = TextEditingController();
  TextEditingController categoriaController = TextEditingController();
  TextEditingController subcategoriaController = TextEditingController();
  TextEditingController toneladasController = TextEditingController();
  TextEditingController cubosController = TextEditingController();
  TextEditingController marcaController = TextEditingController();
  TextEditingController modeloController = TextEditingController();
  TextEditingController razonSocialController = TextEditingController();
  TextEditingController nitEmpController = TextEditingController();
  TextEditingController direccionEmpController = TextEditingController();
  TextEditingController celularEmpController = TextEditingController();
  TextEditingController referenciasEmpController = TextEditingController();


  ProgressDialog? _progressDialog;

  Future? init (BuildContext context) {
    this.context = context;
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere....');
    return null;
  }

  void registerConductor() async {

    String nombreape = nombreapeController.text.trim();
    String numlicencia = numLicenciaController.text.trim();
    String fechavenc = fechaVencimientoController.text.trim();
    String email = emailController.text.trim();
    String celular = celularController.text.trim();
    String domicilio = domicilioController.text.trim();
    String password = passwordController.text.trim();
    String placaVehiculo = placaVehiculoController.text.trim();
    String ruat = ruatVehiculoController.text.trim();
    String categoria = categoriaController.text.trim();
    String subcategoria = subcategoriaController.text.trim();
    String toneladas = toneladasController.text.trim();
    String cubos = cubosController.text.trim();
    String marca = marcaController.text.trim();
    String modelo = modeloController.text.trim();

    if (nombreape.isEmpty) {
      utils.Snackbar.showSnackbar(context!, key, 'Ingrese su nombre y apellido');
      return;
    }else{
      if (numlicencia.isEmpty) {
        utils.Snackbar.showSnackbar(context!, key, 'Ingerese su Nro de licencia');
        return;
      }else{
        if (fechavenc.isEmpty){
          utils.Snackbar.showSnackbar(context!, key, 'Ingrese la fecha de vencimiento de su licencia');
          return;
        }else{
          if (email.isEmpty){
            utils.Snackbar.showSnackbar(context!, key, 'Ingrese su correo electronico');
            return;
          }else{
            if (celular.isEmpty) {
              utils.Snackbar.showSnackbar(context!, key, 'Ingrese su Nro de Celular');
              return;
            }else{
              if (domicilio.isEmpty){
                utils.Snackbar.showSnackbar(context!, key, 'Ingrese su domicilio');
                return;
              }else{
                if (password.length < 4){
                  utils.Snackbar.showSnackbar(context!, key, 'Ingrese una contraseña');
                  return;
                }else{
                 if (placaVehiculo.isEmpty){
                   utils.Snackbar.showSnackbar(context!, key, 'Ingrese la placa del vehiculo');
                   return;
                 } else{
                   if (ruat.isEmpty){
                     utils.Snackbar.showSnackbar(context!, key, 'Ingrese el Nro de RUAT');
                     return;
                   }else{
                     if (categoria.isEmpty && categoria != 'Selecciona una categoria'){
                       utils.Snackbar.showSnackbar(context!, key, 'Selecciona una categoria');
                       return;
                     }else{
                       if (subcategoria.isEmpty && subcategoria != 'Selecciona una subcategoria'){
                         utils.Snackbar.showSnackbar(context!, key, 'Selecciona una subcategoria');
                         return;
                       }else{
                         if (toneladas.isEmpty){
                           utils.Snackbar.showSnackbar(context!, key, 'Ingrese la capacidad en toneladas');
                           return;
                         }else{
                           if (cubos.isEmpty){
                             utils.Snackbar.showSnackbar(context!, key, 'Ingrese la capacidad en cubos');
                             return;
                           }else{
                             if (marca.isEmpty){
                               utils.Snackbar.showSnackbar(context!, key, 'Ingrese la marca del vehiculo');
                               return;
                             }else{
                               if (modelo.isEmpty){
                                 utils.Snackbar.showSnackbar(context!, key, 'Ingrese el modelo');
                                 return;
                               }else{
                                 try {
                                   //_progressDialog?.show();
                                   final response = await http.post(uri, body: {
                                     "btip": 'ADD',
                                     "bnombreape": nombreapeController.text,
                                     "bnumlicencia": numLicenciaController.text,
                                     "bfechavenc": fechaVencimientoController.text,
                                     "bemail": emailController.text,
                                     "bcelular": celularController.text,
                                     "bdomicilio": domicilioController.text,
                                     "bpass": passwordController.text,
                                     "brazonsocial": razonSocialController.text,
                                     "bnitemp": nitEmpController.text,
                                     "bdiremp": direccionEmpController.text,
                                     "bcelemp": celularEmpController.text,
                                     "brefemp": referenciasEmpController.text,
                                   });
                                   var datauser = json.decode(response.body);
                                   String respuesta = datauser['success'];
                                   if (respuesta == "si") {   //DEVUELVE RESPUESTA SI LA ADICION FUE EXITOSA
                                   /*  for (int i = 0; i <= 100; i += 10) {
                                       _progressDialog?.update(
                                         progress: i.toDouble(), // Actualiza el progreso
                                         message: "Cargando: $i%", // Actualiza el mensaje
                                       );
                                       await Future.delayed(const Duration(milliseconds: 100));
                                     }
                                     _progressDialog?.hide();
                                     Navigator.pushNamedAndRemoveUntil(context!, 'bienbendioUsuario', (route) => false,arguments: nombreapeController.text);*/
                                     utils.Snackbar.showSnackbar(context!, key, 'El conductor se registro correctamente');
                                     registerVehiculo(placaVehiculo,ruat,nombreape,numlicencia,categoria,subcategoria,toneladas,cubos,marca,modelo);
                                   }
                                   else {
                                     _progressDialog?.hide();
                                     utils.Snackbar.showSnackbar(context!, key, 'No se logro registrar al conductor, contactese con soporte');
                                   }

                                 } catch(error) {
                                   _progressDialog?.hide();
                                   utils.Snackbar.showSnackbar(context!, key, 'Error: $error');
                                   //print('Error: $error');
                                 }
                               }
                             }
                           }
                         }
                       }
                     }
                   }
                 }
                }
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

  void registerVehiculo(String placa,String ruat, String nombre, String numlic
      , String categoria, String subcategoria, String toneladas, String cubos, String marca, String modelo) async{
    try {
      _progressDialog?.show();
      final response = await http.post(uri1, body: {
        "btip": 'ADD',
        "bplaca": placa,
        "bruat": ruat,
        "bnombre": nombre,
        "bnumlic": numlic,
        "bcategoria": categoria,
        "bsubcategoria": subcategoria,
        "btoneladas": toneladas,
        "bcubos": cubos,
        "bmarca": marca,
        "bmodelo": modelo,
      });
      var datavehi = json.decode(response.body);
      String respuesta = datavehi['success'];
      if (respuesta == "si") {   //DEVUELVE RESPUESTA SI LA ADICION FUE EXITOSA
        for (int i = 0; i <= 100; i += 10) {
          _progressDialog?.update(
            progress: i.toDouble(), // Actualiza el progreso
            message: "Cargando: $i%", // Actualiza el mensaje
          );
          await Future.delayed(const Duration(milliseconds: 100));
        }
        _progressDialog?.hide();
        //Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
        Navigator.pushNamedAndRemoveUntil(context!, 'bienbendioUsuario', (route) => false,arguments: nombreapeController.text);
        utils.Snackbar.showSnackbar(context!, key, 'Vehiculo Registrado');
      }
      else {
        _progressDialog?.hide();
        utils.Snackbar.showSnackbar(context!, key, 'No se logro registrar el Vehiculo, contactese con soporte');
      }

    } catch(error) {
      _progressDialog?.hide();
      utils.Snackbar.showSnackbar(context!, key, 'Error: $error');
      //print('Error: $error');
    }
  }
}