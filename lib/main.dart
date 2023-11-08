
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/pages/Conductor/conductorMapa_view.dart';
import 'package:gruasgo/src/pages/Conductor/conductorRegistro_view.dart';
import 'package:gruasgo/src/pages/Conductor/conductor_bienbenido.dart';
import 'package:gruasgo/src/pages/Conductor/finalizacion/conductor_finalizacion_view.dart';
import 'package:gruasgo/src/pages/Conductor/notificacion/conductor_notificacion_view.dart';
import 'package:gruasgo/src/pages/home/home_page.dart';
import 'package:gruasgo/src/pages/login/login_usr.dart';
import 'package:gruasgo/src/pages/usuario/buscando/usuario_buscando.dart';
import 'package:gruasgo/src/pages/usuario/finalizacion/usuario_finalizacion.dart';
import 'package:gruasgo/src/pages/usuario/detallePedidoSolicitar/usuarioMapa_view.dart';
import 'package:gruasgo/src/pages/usuario/select_map_user.dart';
import 'package:gruasgo/src/pages/usuario/usuario_bienbenido.dart';
import 'package:gruasgo/src/pages/usuario/usuario_pedido_view.dart';
import 'package:gruasgo/src/pages/usuario/usuario_view.dart';
import 'package:gruasgo/src/services/socket_services.dart';


void main() async {

  // TODO: Posible solucion para evitar que el mapa haga un crash cuando cambia rapido de ventana
  // TODO: Mantener desabilitado en el desarrollo, ya que puede generar problemas solo en el modo desarrollo
  // TODO: Antes de poner a produccion, hacer muchas pruebas para verificar que esta solucion funciona y no hace cosas extrañas
  // if (Platform.isAndroid){
  //   WidgetsFlutterBinding.ensureInitialized(); 
  //   await GoogleMapsFlutterAndroid().initializeWithRenderer(AndroidMapRenderer.latest);
  // }

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
      ),
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
        'bienbenidoConductor' : (context) => const ConductorBienbenido(),
        'ConductorNotificacion' : (context) => const ConductorNotificacion(),
        'ConductorFinalizacion': (context) => const ConductorFinalizacion(),
        'UsuarioFinalizacion': (context) => const UsuarioFinalizacion(),
        'UsuarioBuscando': (context) => const UsuarioBuscando(),
        'SelectMapUser': (context) => const SelectMapUser(),

        // 'home' : (BuildContext context) => LoginUsr(),
      },
    );
  }
}

// Directions API
// Places API