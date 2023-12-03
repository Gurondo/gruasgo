import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/widgets/button_app.dart';

  // diseño basico que se muestra cuando finaliza un pedido en el lado del cliente, puede valorar al conductor y escribir una nota
class UsuarioFinalizacion extends StatefulWidget {
  const UsuarioFinalizacion({ Key? key }) : super(key: key);

  @override
  State<UsuarioFinalizacion> createState() => _UsuarioFinalizacionState();
}

class _UsuarioFinalizacionState extends State<UsuarioFinalizacion> {

  double calificacion = 3.0;
  final TextEditingController tecComentario = TextEditingController();

  late UsuarioPedidoBloc usuarioBloc;

  @override
  void initState() {

    usuarioBloc = BlocProvider.of<UsuarioPedidoBloc>(context);

    usuarioBloc.add(OnSetIdConductor(-1));
    usuarioBloc.add(OnRemoveMarker(MarkerIdEnum.conductor));

    usuarioBloc.add(OnClearPolylines());
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final userBLoc = BlocProvider.of<UserBloc>(context);

    final minutos = ModalRoute.of(context)!.settings.arguments;

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<bool>(
          future: usuarioBloc.getPedido(idPedido: usuarioBloc.pedidoModel!.bidpedido),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Text('Cargando'),);
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(3000, 600),
                        bottomRight: Radius.elliptical(3000, 600)
                      )
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.check_circle, size: 100,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text('Tu viaje ha finalizado'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold),),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Text('Valor del viaje'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text('${usuarioBloc.pedidoModel?.bmonto} Bs.', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
                        ),
            
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pin_drop),
                    title: const Text('Origen', style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text(usuarioBloc.pedidoModel!.bubinicial),
                  ),
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: const Text('Destino', style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text(usuarioBloc.pedidoModel!.bubfinal),
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Metodo de pago', style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text(usuarioBloc.pedidoModel!.bmetodopago),
                  ),
                  
                  (minutos != null && minutos.toString().isNotEmpty) ?
                  ListTile(
                    leading: const Icon(Icons.access_time_sharp),
                    title: const Text('Minutos consumidos', style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text('${minutos.toString()} minutos'),
                  ) : Container(),

                  Text('Califica a tu conductor'.toUpperCase(), style: TextStyle(color: Colors.blue[600]),),
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      calificacion = rating;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const Text('Comentario'),
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          controller: tecComentario,
                        ),
                      ],
                    ),
                  ),
                  // Expanded(child: Container()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: ButtonApp(
                        text: 'Enviar',
                        color: Colors.amber,
                        icons: Icons.navigate_next_rounded,
                        onPressed: () async {
                          if (calificacion > 0){
                            final navigator = Navigator.of(context);
                            final status = await userBLoc.enviarCalificacion(
                              idPedido: usuarioBloc.pedidoModel!.bidpedido,
                              observaciones: tecComentario.value.text,
                              puntaje: (calificacion.round() * 10).toString(),
                              tipoUsuario: 'usu'
                            );
                            if (status){
                              navigator.pushNamedAndRemoveUntil('bienbendioUsuario', (route) => false);
                              // TODO: Aqui liumpiar todo
                            }else{
                              print('No se pudo enviar la calificacion');
                            }
                            // TODO: Aqui se almacena la informacion
                          }
                          
                          // usuarioBloc.add(OnSetIdConductor(''));
                          // Navigator.pushNamedAndRemoveUntil(context, 'bienbendioUsuario', (route) => false);
                        },  
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        ),
      )
    );
  }
}