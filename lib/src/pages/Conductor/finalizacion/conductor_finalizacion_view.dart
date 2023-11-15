
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/enum/estado_pedido_aceptado_enum.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


// Un diseño facil para cuando finaliza el pedido y el conductor puede ver el detalle, valorar al usuario.

class ConductorFinalizacion extends StatefulWidget {
  const ConductorFinalizacion({ Key? key }) : super(key: key);

  @override
  State<ConductorFinalizacion> createState() => _ConductorFinalizacionState();
}

class _ConductorFinalizacionState extends State<ConductorFinalizacion> {

  final TextEditingController tecComentario = TextEditingController();

  double calificacion = 3.0;

  late ConductorBloc conductorBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    conductorBloc = BlocProvider.of<ConductorBloc>(context);

    conductorBloc.add(OnSetClearPolylines());
  }

  @override
  void dispose() {

    conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));
    conductorBloc.add(OnSetClearPolylines());
    conductorBloc.add(OnSetLimpiarPedidos());
    conductorBloc.add(OnSetNewMarkets({}));
    conductorBloc.yaHayPedido = false;

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final userBLoc = BlocProvider.of<UserBloc>(context);
    
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
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
                      child: Text('${conductorBloc.state.detallePedido?.monto ?? '0'} Bs.', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
                    ),
          
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.pin_drop),
                title: const Text('Desde', style: TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Text(conductorBloc.state.detallePedido?.nombreOrigen ?? 'none'),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Hasta', style: TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Text(conductorBloc.state.detallePedido?.nombreDestino ?? 'none'),
              ),
              
              (
                Enviroment().listaServicioHoraAvanzada.contains(conductorBloc.state.detallePedido!.servicio) ||
                Enviroment().listaServicioPorHoraBasico.contains(conductorBloc.state.detallePedido!.servicio)
              ) ?
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text('Tiempo transcurrido', style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text('${conductorBloc.state.detallePedido?.tiempoTranscurrido} minutos'),
                  ),
                ],
              ) : 
              Container(),

              Text('Califica a tu cliente'.toUpperCase(), style: TextStyle(color: Colors.blue[600]),),
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
        
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: ButtonApp(
                    text: 'Enviar',
                    color: Colors.amber,
                    icons: Icons.navigate_next_rounded,
                    onPressed: ()async{
                      if (calificacion > 0){
                        final navigator = Navigator.of(context);
                        final status = await userBLoc.enviarCalificacion(
                          idPedido: conductorBloc.state.detallePedido!.pedidoId,
                          observaciones: tecComentario.value.text,
                          puntaje: (calificacion.round() * 10).toString(),
                          tipoUsuario: 'conduc'
                        );

                        if (status){
                          navigator.pushNamedAndRemoveUntil('bienbenidoConductor', (route) => false);
                          // TODO: Aqui liumpiar todo
                        }else{
                          print('No se pudo enviar la calificacion');
                        }

                        // TODO: Aqui se almacena la informacion
                      }
                    },
                  ),
                ),
              ),
        
              
            ],
          ),
        ),
      )
    );
  }
}