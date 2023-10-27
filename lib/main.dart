import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/pages/Conductor/conductorMapa_view.dart';
import 'package:gruasgo/src/pages/Conductor/conductorRegistro_view.dart';
import 'package:gruasgo/src/pages/Conductor/conductor_bienvenida_view.dart';
import 'package:gruasgo/src/pages/Conductor/finalizacion/conductor_finalizacion_view.dart';
import 'package:gruasgo/src/pages/Conductor/notificacion/conductor_notificacion_view.dart';
import 'package:gruasgo/src/pages/Conductor/pedido_aceptado/conductor_pedido_aceptado_view.dart';
import 'package:gruasgo/src/pages/home/home_page.dart';
import 'package:gruasgo/src/pages/login/login_usr.dart';
import 'package:gruasgo/src/pages/usuario/finalizacion/usuario_finalizacion.dart';
import 'package:gruasgo/src/pages/usuario/mapa_usuario_pedido.dart';
import 'package:gruasgo/src/pages/usuario/usuarioMapa_view.dart';
import 'package:gruasgo/src/pages/usuario/usuario_bienbenido.dart';
import 'package:gruasgo/src/pages/usuario/usuario_pedido_view.dart';
import 'package:gruasgo/src/pages/usuario/usuario_view.dart';
import 'package:gruasgo/src/services/socket_services.dart';


void main() {

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => UserBloc(),
      ),
      BlocProvider(
        create: (context) => UsuarioPedidoBloc(
          userBloc: BlocProvider.of<UserBloc>(context)
        ),
      ),
      BlocProvider(
        create: (context) => ConductorBloc(
          userBloc: BlocProvider.of<UserBloc>(context)
        ),
      )
    ], 
    child: const MyApp()
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  String initialRoute = "login";

  @override
  Widget build(BuildContext context) {

    SocketService.connection();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gruas Go',
      // initialRoute: 'login',
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
        'VistaMapaUsuarioPedido' : (BuildContext context) => const MapaUsuarioPedido(),

        
        'ConductorBienvenido' : (context) => const ConductorBienvenida(),
        'ConductorNotificacion' : (context) => const ConductorNotificacion(),
        'ConductorPedidoAceptado': (context) => const ConductorPedidoAceptado(),
        'ConductorFinalizacion': (context) => const ConductorFinalizacion(),
        
        'UsuarioFinalizacion': (context) => const UsuarioFinalizacion(),

        
        

       // 'home' : (BuildContext context) => LoginUsr(),
      },
    );
  }
}

// Directions API
// Places API