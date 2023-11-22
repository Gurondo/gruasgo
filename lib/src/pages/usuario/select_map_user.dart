import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';

class SelectMapUser extends StatefulWidget {
  const SelectMapUser({Key? key}) : super(key: key);

  @override
  State<SelectMapUser> createState() => _SelectMapUserState();
}

class _SelectMapUserState extends State<SelectMapUser> {
  Completer<GoogleMapController> mapController = Completer();

  @override
  void dispose() {
    // TODO: implement dispose

    mapController.future.then((controllerValue) => {
      controllerValue.dispose()
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final userBloc = BlocProvider.of<UserBloc>(context);
    final usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);

    final tec = ModalRoute.of(context)!.settings.arguments as  TextEditingController;

    return SafeArea(child: Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMapWidget(
                initPosition: state.markerSeleccionado!.position,
                googleMapController: mapController,
                onTap: (p0) {
                  userBloc.add(OnSetIsClicPin(true));
                  userBloc.add(OnSetMarker(
                    Marker(
                      markerId: state.markerSeleccionado!.markerId,
                      position: p0,
                      icon: state.markerSeleccionado?.icon ?? BitmapDescriptor.defaultMarker
                    )
                  ));
                },
                markers: {
                  (state.isClickPin == true) ? 
                  state.markerSeleccionado! :
                  const Marker(markerId: MarkerId('-'))
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: const Text('Seleccione un punto en el mapa')
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 15),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: ButtonApp(
                          text: 'Aceptar',
                          color: Colors.amber,
                          textColor: Colors.black,
                          //onPressed: _con.registerUsuario,
                          onPressed: () async {
                            
                            final navigator = Navigator.of(context);
                            usuarioPedidoBloc.add(OnSetAddNewMarkets(

                              state.markerSeleccionado!
                            ));

                            final place = await usuarioPedidoBloc.searchPlaceByCoors(coors: state.markerSeleccionado!.position);
                            if (place!=null){
                              tec.text = place;
                            }
                            navigator.pop();
                      
                          },
                      
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: ButtonApp(
                          text: 'Cancelar',
                          color: Colors.amber,
                          textColor: Colors.black,
                          //onPressed: _con.registerUsuario,
                          onPressed: () async {
                            
                            Navigator.pop(context);
                      
                          },
                      
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ));
  }
}
