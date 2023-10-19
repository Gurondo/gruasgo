import 'package:flutter/material.dart';
import 'package:gruasgo/src/pages/Conductor/conductorMapa_view.dart';
import 'package:gruasgo/src/pages/Conductor/conductorRegistro_view.dart';
import 'package:gruasgo/src/pages/home/home_page.dart';
import 'package:gruasgo/src/pages/login/loginUs.dart';
import 'package:gruasgo/src/pages/login/login_usr.dart';
import 'package:gruasgo/src/pages/usuario/usuarioMapa_view.dart';
import 'package:gruasgo/src/pages/usuario/usuario_bienbenido.dart';
import 'package:gruasgo/src/pages/usuario/usuario_pedido_view.dart';
import 'package:gruasgo/src/pages/usuario/usuario_view.dart';


void main() {

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  String initialRoute = "UsuarioPedido";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gruas Go',
      //initialRoute: 'login',
      initialRoute: initialRoute,
      theme: ThemeData(
        fontFamily: 'NimbusSans',
        appBarTheme: const AppBarTheme(
            elevation: 0
        ),
      ),
      routes: {
        'home' : (BuildContext context) => HomePage(),
        'login' : (BuildContext context) => const LoginUsr(),
        // 'loginus' : (BuildContext context) => const login_Usr(),
        'bienbendioUsuario' : (BuildContext context) => const UsarioBienbenido(),
        'RegistroUsuario' : (BuildContext context) => const usuarioReg(),
        'RegistroConductor' : (BuildContext context) => const conductorReg(),
        'MapaConductor' : (BuildContext context) => const ConductorMap(),
        'MapaUsuario' : (BuildContext context) => const UsuarioMap(),
        'UsuarioPedido' : (BuildContext context) => const UsuarioPedido(),
        

       // 'home' : (BuildContext context) => LoginUsr(),
      },
    );
  }
}

