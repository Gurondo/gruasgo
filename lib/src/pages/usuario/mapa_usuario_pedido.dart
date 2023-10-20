import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/widget.dart';

import 'package:gruasgo/src/utils/colors.dart' as utils;

class MapaUsuarioPedido extends StatelessWidget {
  const MapaUsuarioPedido({ Key? key }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    
    final Completer<GoogleMapController> controllerxD = Completer<GoogleMapController>();
    final usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);

    final paramters = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>; // origen o destino
    final type = paramters['type'] as String;
    TextEditingController tec = paramters['controller'] as TextEditingController;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
        ),
        body: Stack(
          children: [
            
            BlocBuilder<UsuarioPedidoBloc, UsuarioPedidoState>(
              builder: (context, state) {

                Set<Marker> markers = {};

                if (type == 'origen'){
                  if (state.origen != null){
                    markers.add(
                      Marker(
                        markerId: const MarkerId('origen'),
                        position: state.origen!,
                      )
                    );
                  }
                }else{
                  if (state.destino != null){
                    markers.add(
                      Marker(
                        markerId: const MarkerId('destino'),
                        position: state.destino!
                      )
                    );
                  }
                }
                
                return GoogleMapWidget(
                  initPosition: state.origen!, 
                  controllerxD: controllerxD, 
                  markers: markers,
                  onTap: (p0) async {
                    final navigator = Navigator.of(context);
                    (type == 'origen') 
                      ? usuarioPedidoBloc.add(OnSetOrigen(p0))
                      : usuarioPedidoBloc.add(OnSetDestino(p0));
                      final place = await usuarioPedidoBloc.searchPlaceByCoors(coors: p0);
                      if (place!=null){
                        tec.text = place;
                      }
                      navigator.pop();
                  },
                );
              },
            ),
            
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)
                ),
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                child: const Text('Seleccione el lugar en el mapa', style: TextStyle(fontSize: 14),)
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ButtonApp(
                    text: 'Cancelar',
                    color: Colors.amber,
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}