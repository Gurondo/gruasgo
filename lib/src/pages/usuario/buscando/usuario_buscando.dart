import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/widgets/button_app.dart';

class UsuarioBuscando extends StatefulWidget {
  const UsuarioBuscando({ Key? key }) : super(key: key);

  @override
  State<UsuarioBuscando> createState() => _UsuarioBuscandoState();
}

class _UsuarioBuscandoState extends State<UsuarioBuscando> {

  late UsuarioPedidoBloc _usuarioPedidoBloc;

  // libera de la memoria esos listener.
  @override
  void dispose() {
    
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
    
    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            color: Colors.white
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Tu conductor', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Imagen'),
                    const SizedBox(height: 40,),
                    const Text('Buscando conductor'),
                    const SizedBox(height: 40),
                    BlocBuilder<UsuarioPedidoBloc, UsuarioPedidoState>(
                      builder: (context, state) {
                        return Text(state.contador.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),);
                      },
                    )
                  ],
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: ButtonApp(
                  color: Colors.amber,
                  text: 'Cancelar viaje',
                  icons: Icons.cancel_outlined,
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, 'bienbendioUsuario', (route) => false);
                  },
                ),
              )
            ],
          )
        )
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0,0);
    path.lineTo(0, size.height);
    path.quadraticBezierTo((size.width/4), size.height-40, size.width/2, size.height-40);
    path.quadraticBezierTo(size.width-(size.width/4), size.height-40, size.width, size.height-80);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
  
}