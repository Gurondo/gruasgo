import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_count_down/timer_count_down.dart';

class UsuarioBuscando extends StatefulWidget {
  const UsuarioBuscando({ Key? key }) : super(key: key);

  @override
  State<UsuarioBuscando> createState() => _UsuarioBuscandoState();
}

class _UsuarioBuscandoState extends State<UsuarioBuscando> {

  late UsuarioPedidoBloc _usuarioPedidoBloc;

  // libera de la memoria esos listener.
  @override
  void dispose(){
    
    if (_usuarioPedidoBloc.state.idConductor == ''){
      _usuarioPedidoBloc.cancelarPedido();
    }
    
    _usuarioPedidoBloc.clearSocketIsSuccessPedido();

    super.dispose();
  }

  // Se pone en alerta para detectar cualquier solicitud del conductor, si este a aceptado el pedido o no, para poder visualizar en la ventana
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    final navigator = Navigator.of(context);
    _usuarioPedidoBloc.listenPedidoAceptado(navigator: navigator);
    // UsuarioPedidoAceptado
  }

  @override
  Widget build(BuildContext context) {
    
    
    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);
    
    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img/logo_gruas.png', // Ruta a la imagen en el directorio assets
                      width: 140,  // Ancho de la imagen
                      height: 140, // Alto de la imagen
                    ),

                    const SizedBox(height: 20,),
                    const Text('BUSCANDO CONDUCTOR',
                        style: TextStyle(
                        color: Colors.black, // Cambia el color del texto
                        fontSize: 25, fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Countdown(
                      seconds: 30,
                      build: (BuildContext context, double time) {
                        return Text(
                          time.toStringAsFixed(time.truncateToDouble() == time ? 0 : 1),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        );
                      },
                      onFinished: (){

                        Navigator.pushNamedAndRemoveUntil(context, 'bienbendioUsuario', (route) => false, arguments: userBloc.user!.nombreusuario);

                        showDialog(
                          context: context, 
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Atencion'),
                              content: const Text('EN ESTE MOMENTO NO SE TIENEN CONDUCTORES DIPONIBLES, INTENTELO MAS TARDE'),
                              actions: [
                                TextButton(
                                  child: const Text('Aceptar'),
                                  onPressed: () => Navigator.pop(context),
                                ), 
                              ],
                            );
                          },
                        );

                      },
                    ),

                    const SizedBox(height: 5),
                    _lottieAni(),

                    const SizedBox(height: 5),

                    const Text('Espere por favor', style: TextStyle(color: Colors.red, fontSize: 20),),
                    
                    const SizedBox(height: 10),

                  ],
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: ButtonApp(
                  color: Colors.amber,
                  text: 'Cancelar viaje',
                 // icons: Icons.cancel_outlined,
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, 'bienbendioUsuario', (route) => false, arguments: userBloc.user!.nombreusuario);
                  },
                ),
              )
            ],
          )
        )
      ),
    );
  }

  Widget _lottieAni(){
    return Lottie.asset(
      'assets/json/ani2.json',
      width: MediaQuery.of(context).size.width * 0.60,
      height: MediaQuery.of(context).size.width * 0.60,
      fit: BoxFit.fill
    );
  }
}
