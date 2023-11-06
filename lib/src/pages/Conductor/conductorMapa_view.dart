import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/conductor/conductor_bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/pages/Conductor/conductorMapa_controller.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/widget.dart';

class ConductorMap extends StatefulWidget {
  const ConductorMap({super.key});

  @override
  State<ConductorMap> createState() => _ConductorMapState();
}

class _ConductorMapState extends State<ConductorMap> {
  final DriverMapController _con = DriverMapController();

  Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  Timer? _timer;
  late ConductorBloc _conductorBloc;

  // inicializacion para estar pendiendo los eventos en Socket, escuchar a los nuevos pedidos
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _conductorBloc = BlocProvider.of<ConductorBloc>(context);
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      final position = await getPositionHelpers();
      _conductorBloc.updatePosition(
          lat: position.latitude, lng: position.longitude);

      _conductorBloc.actualizarCoorEstado();
    });

    final navigator = Navigator.of(context);
    _conductorBloc.respuestaSolicitudConductor(navigator: navigator);
  }

  // limpiar en la memoria estos eventos, ya que son listener, estara guardado en memoria, cuando esta ventana de destruye, ya no es necesario escuchar ya que
  // el conductor se ha desconectado, por eso, ya no necesita estar escuchando cualquier evento de un nuevo pedido
  @override
  void dispose() {
    _timer?.cancel();
    _conductorBloc.clearSocketSolicitudConductor();
    _conductorBloc.eliminarEstado();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // inicializacion del bloc para poder emitir, o cambiar un estado
    _conductorBloc = BlocProvider.of<ConductorBloc>(context);

    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: FutureBuilder<Position>(
          future: getPositionHelpers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return BlocBuilder<ConductorBloc, ConductorState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      GoogleMapWidget(
                        initPosition: LatLng(
                            snapshot.data!.latitude, snapshot.data!.longitude),
                        googleMapController: googleMapController,
                        markers: state.markers,
                        polylines: state.polylines,
                      ),
                      // _googleMapsWidget(),
                      SafeArea(

                        child: WidgetDetailMap(
                          builder: (){
                            if (state.markers.isEmpty) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buttonDrawer(),
                                      _buttonCenterPosition()
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  _buttonDesconectar(_conductorBloc),
                                ],
                              );
                            } else {
                              // Con pedido pendiente
                              return Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 100),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ButtonApp(
                                            text: 'Cancelar',
                                            color: Colors.amber,
                                            textColor: Colors.black,
                                            onPressed: (){
                                              
                                              // TODO: Cancelar Pedido
                                              _conductorBloc.respuestaPedidoProcesoCancelado();
                                              _conductorBloc.add(OnSetLimpiarPedidos());

                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ButtonApp(
                                            text: 'Estoy aqui',
                                            color: Colors.amber,
                                            textColor: Colors.black,
                                            onPressed: (){

                                              // TODO: Comenzar Ruta
                                              _conductorBloc.add(OnSetClearPolylines());
                                              _getPolylines(state);

                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ButtonApp(
                                            text: 'Finalizar Viaje',
                                            color: Colors.amber,
                                            textColor: Colors.black,
                                            onPressed: (){
                                              // TODO: Finalizar viaje
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }

                          },
                        ),
                        
                      )
                    ],
                  );
                },
              );
            } else {
              return Container();
            }
          }),
    );
  }

  // para obtener las rutas de dos puntos, y poder dibujarlo en el mapa, para que el conductor vea las rutas
  Future _getPolylines(ConductorState state) async {


    Position position = await getPositionHelpers();
    Marker? marker = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

    if (marker == null) return;

    List<PointLatLng>? polyline = await _conductorBloc.getPolylines(
      origen: LatLng(position.latitude, position.longitude), 
      destino: marker.position
    );

    if (polyline != null){
      _conductorBloc.add(OnSetAddPolyline(
        Polyline(
          polylineId: PolylineId(PolylineIdEnum.posicionToOrigen.toString()),
          color: Colors.black,
          width: 4,
          points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
        )
      ));
    }
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.amber),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nombre de conductor',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                Text(
                  'Email',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                const SizedBox(height: 10),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/img/profile.jpg'),
                  radius: 40,
                )
              ],
            ),
          ),
          ListTile(
            title: const Text('Editar perfil'),
            trailing: const Icon(Icons.edit),
            // leading: Icon(Icons.cancel),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Cerrar sesion'),
            trailing: const Icon(Icons.power_settings_new),
            // leading: Icon(Icons.cancel),
            onTap: _con.cerrarSession,
          ),
        ],
      ),
    );
  }

  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: const CircleBorder(),
          color: Colors.amber[300],
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.location_searching,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonDrawer() {
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buttonDesconectar(ConductorBloc conductorBloc) {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        text: 'Desconectarse'.toUpperCase(),
        color: Colors.amber,
        onPressed: () {
          conductorBloc.closeSocket();
          Navigator.pop(context);
        },
      ),
    );
  }
}


class WidgetDetailMap extends StatelessWidget {
  final Function builder;

  const WidgetDetailMap({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}