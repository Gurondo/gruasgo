
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/pages/Conductor/conductorMapa_view.dart';
import 'package:gruasgo/src/pages/Conductor/conductorRegistro_view.dart';
import 'package:gruasgo/src/pages/Conductor/conductor_bienvenida_view.dart';
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

  // Para contruir los Bloc establecidos, ya que como dije, Bloc es un manejo de estados, entonces debe
  // construirse al principio, ya que si lo construimos en una pagina, entonces cada vez que la pagina haga un pop
  // se destruya por asi decirlo, todo lo relaccionado con este bloc va a desaparecer y eso quiere decir, que los estados
  // ya no existen, pues cuando la pagina vuelve a construirse, entonces el estado se restablece con su valor inicial 
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        // Bloc para manejar al usuario, y tambien una ayuda a la hora de seleccionar un pin en el mapa cuando
        // el usuario este rellenando el formuario para solicitar un pedido
        create: (context) => UserBloc(),
      ),

      // BLoc para el UsuarioPedido, aqui esta todo relaccionado con Socket, para escuchar o emitir eventos por
      // cada accion que haga el cliente, y se le debe notificar al chofer, tambien guardo informacion como
      // el Pedido, para no perderlo cuando el usuario cree un nuevo pedido, y pueda rescatarlo
      BlocProvider(
        create: (context) => UsuarioPedidoBloc(
          userBloc: BlocProvider.of<UserBloc>(context)
        ),
      ),

      // El Bloc del conductor, lo mismo con el Usuario, manejo de Eventos en Socket, mostrar informacion y manejo de estados
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
    
    // Para conectar con Socket "tiempo", ojo, esto lo conecta con el servidor, pero no lo conecta por el usuario
    // ya que son dos cosas diferentes, 
    
    // conectar con el servidor: apuntar al servidor para cualquier consulta. Y tenerlo todo preparado

    // Y conectarse con el usuario: que el usuario mande un evento diciendo que se a conectado al servidor, 
    // que le de una Id para los eventos en Socket, y este en en linea para cualquier cosa que requira ser notificado
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

        // Esto no estaba anteriormente, asi que lo agregue, es la ventana del formulario, donde el usuario
        // debe rellenar un formulario para solicitar un pedido
        'UsuarioPedido' : (BuildContext context) => const UsuarioPedido(),

        // Bienvenida del conductor
        'ConductorBienvenido' : (context) => const ConductorBienvenida(),
        
        // Notificaciones para el conductor
        'ConductorNotificacion' : (context) => const ConductorNotificacion(),
        
        // Cuando se finaliza el pedido
        'ConductorFinalizacion': (context) => const ConductorFinalizacion(),
        
        // Cuando se finaliza el pedido
        'UsuarioFinalizacion': (context) => const UsuarioFinalizacion(),
        
        // Entra en modo, buscando conductores
        'UsuarioBuscando': (context) => const UsuarioBuscando(),
        
        // Para poder seleccionar en el mapa los puntos donde quieren que lo recojan y lo lleven
        'SelectMapUser': (context) => const SelectMapUser(),

        // 'home' : (BuildContext context) => LoginUsr(),
      },
    );
  }
}

// Directions API
// Places API