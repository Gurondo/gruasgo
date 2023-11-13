import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/enum/estado_pedido_aceptado_enum.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/helpers/get_marker.dart';
import 'package:gruasgo/src/helpers/get_position.dart';
import 'package:gruasgo/src/pages/Conductor/conductorMapa_controller.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ConductorMap extends StatefulWidget {
  const ConductorMap({super.key});

  @override
  State<ConductorMap> createState() => _ConductorMapState();
}

class _ConductorMapState extends State<ConductorMap> {
  final DriverMapController _con = DriverMapController();

  Timer? _timer;
  late ConductorBloc _conductorBloc;
  late UserBloc _userBloc;

  final _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  @override 
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh); //// REFRESH  PARA M3
    });

    _conductorBloc = BlocProvider.of<ConductorBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      final position = await getPositionHelpers();
      _conductorBloc.updatePosition(
          lat: position.latitude, lng: position.longitude);

      _conductorBloc.actualizarCoorEstado();
    });

    final navigator = Navigator.of(context);
    _conductorBloc.notificacionNuevaSolicitudConductor(
      navigator: navigator,
      idConductor: _userBloc.user!.idUsuario
    );

  }

  @override
  void dispose() {
    _timer?.cancel();
    _conductorBloc.clearSocketNotificacionNuevaSolicitudConductor();
    // if (_conductorBloc.state.detallePedido == null){
    //   _conductorBloc.eliminarEstado();
    // }
    _stopWatchTimer.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _conductorBloc = BlocProvider.of<ConductorBloc>(context);

    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: BlocBuilder<ConductorBloc, ConductorState>(
        builder: (context, state) {
          return Stack(
            children: [
              _googleMapsWidget(),
              SafeArea(
                child: WidgetDetailMap(
                  builder: (){
                    if (!hayPedido(state)){
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buttonDrawer(), 
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7)
                                  ),
                                  child: const Text('Esperando solicitud', style: TextStyle(fontSize: 19,color: Colors.red),)
                                )
                              ),
                              _buttonCenterPosition()
                              ],
                          ),
                          Expanded(child: Container()),
                          _buttonConectar(_conductorBloc),
                        ],
                      );
                    }else{
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
                                    onPressed: ()async{
                                      
                                      // TODO: Cancelar Pedido


                                      showCustomDialog(
                                        context: context,
                                        title: 'Estas seguro??',
                                        content: '¿Estas seguro que quieres cancelar el viaje?',
                                        onPressed: () async {
                                          
                                          final navigator = Navigator.of(context);
                                          _conductorBloc.respuestaPedidoProcesoCancelado();
                                          _conductorBloc.add(OnSetLimpiarPedidos());
                                          final status = await _conductorBloc.actualizarPedido(
                                            estado: 'CACO',
                                            idConductor: _userBloc.user!.idUsuario,
                                            idPedido: state.detallePedido!.pedidoId,
                                            idVehiculo: '='
                                          );
                                          if (status){
                                            final statusEstadoConductor = await _conductorBloc.eliminarEstado();

                                            if (statusEstadoConductor){
                                              navigator.pushNamedAndRemoveUntil('bienbenidoConductor', (route) => false, arguments: _userBloc.user!.nombreusuario);
                                            }
                                          }

                                        }
                                      );

                                  

                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),

                          // TODO: Para mostrar la hora

                          (
                            Enviroment().listaServicioHoraAvanzada.contains(state.detallePedido?.servicio ?? '-') ||
                            (Enviroment().listaServicioPorHoraBasico.contains(state.detallePedido?.servicio ?? '-') && state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.finalizarCarrera)
                          ) ?
                          FutureBuilder<String?>(
                            future: _conductorBloc.getMinutosConsumidos(idPedido: state.detallePedido!.pedidoId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting){
                                return Container();
                              }

                              if (!_stopWatchTimer.isRunning){
                                _stopWatchTimer.setPresetMinuteTime(int.parse(snapshot.data ?? '0'));
                                _stopWatchTimer.onStartTimer();
                              }


                              return StreamBuilder<int>(
                                stream: _stopWatchTimer.rawTime,
                                initialData: 0,
                                builder: (context, snapshot) {
                                  final value = snapshot.data;
                                  final displayTime = StopWatchTimer.getDisplayTime(value!);
                                  // StopWatchTimer.getMilliSecFromHour
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Text('Tiempo transcurrido: ${displayTime.substring(0, displayTime.length - 3)}', style: const TextStyle(fontSize: 16),)
                                      ),
                                    ),
                                  );
                                },
                              );

                            },
                          ) : Container(),
                          
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15),
                            child: 
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.estoyAqui) ? 
                                ButtonApp(
                                  text: 'Estoy aqui',
                                  color: Colors.amber,
                                  textColor: Colors.black,
                                  onPressed: (){
                              
                                    // TODO: Comenzar Ruta
                                    showCustomDialog(
                                      context: context,
                                      title: 'Estas seguro??',
                                      content: '¿Confirmar que llego al lugar de recogida?',
                                      onPressed: (){
                                        
                                        _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.comenzarCarrera));
                                        _conductorBloc.emitYaEstoyAqui();
                                        
                                      }
                                    );
                                    
                              
                                  },
                                ) : (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.comenzarCarrera) ? 
                                ButtonApp(
                                  text: 'Comenzar carrera',
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  onPressed: (){

                                    showCustomDialog(
                                      context: context,
                                      title: 'Estas seguro??',
                                      content: '¿Estas seguro que quieres comenzar el viaje?',
                                      onPressed: () async {

                                        _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.finalizarCarrera));
                                        _conductorBloc.add(OnSetClearPolylines());
                                        _getPolylines(state);
                                        final statusPedido = await _conductorBloc.actualizarPedido(
                                          estado: 'VICO',
                                          idConductor: _userBloc.user!.idUsuario,
                                          idPedido: state.detallePedido!.pedidoId,
                                          idVehiculo: '='
                                        );

                                        if (statusPedido){
                                          if (Enviroment().listaServicioPorHoraBasico.contains(state.detallePedido!.servicio)){
                                            await _conductorBloc.adiccionarHora(
                                              idPedido: state.detallePedido!.pedidoId
                                            );

                                          }
                                        }
                                
                                      
                                      }
                                    );

                                  },
                                ): ButtonApp(
                                  text: 'Finalizar Viaje',
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  onPressed: (){
                                    // TODO: Finalizar viaje

                                    showCustomDialog(
                                      context: context,
                                      title: 'Estas seguro??',
                                      content: '¿Estas seguro de finalizar el viaje?',
                                      onPressed: () async {
                                        
                                        final navigator = Navigator.of(context);
                                        final status = await _conductorBloc.actualizarPedido(
                                          estado: 'VITE',
                                          idConductor: _userBloc.user!.idUsuario,
                                          idPedido: state.detallePedido!.pedidoId,
                                          idVehiculo: '='
                                        );
                                        if (status){
                                          _conductorBloc.emitFinalizarPedido();
                                          _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));
                                          // TODO: Aqui cuando finaliza el pedido
                                          _conductorBloc.add(OnSetClearPolylines());
                                          _getPolylines(state);
                                          _conductorBloc.eliminarCrearEstado();
                                          navigator.pushNamedAndRemoveUntil('ConductorFinalizacion', (route) => false);
                                        }

                                      }
                                    );
                                  },
                                ),
                              ) 
                            // Row(
                            //   mainAxisAlignment:
                            //       MainAxisAlignment.spaceAround,
                            //   children: [
                            //     const SizedBox(
                            //       width: 10,
                            //     ),
                            //     Expanded(
                            //       child: ButtonApp(
                            //         text: 'Estoy aqui',
                            //         color: Colors.amber,
                            //         textColor: Colors.black,
                            //         onPressed: (){

                            //           // TODO: Comenzar Ruta
                            //           showCustomDialog(
                            //             context: context,
                            //             title: 'Estas seguro??',
                            //             content: '¿ Confirmar que llego al lugar de recogida?',
                            //             onPressed: (){
                                          
                            //               _conductorBloc.add(OnSetClearPolylines());
                            //               _getPolylines(state);
                                        
                            //             }
                            //           );
                                      

                            //         },
                            //       ),
                            //     ),
                            //     const SizedBox(
                            //       width: 10,
                            //     ),
                            //     Expanded(
                            //       child: ButtonApp(
                            //         text: 'Finalizar Viaje',
                            //         color: Colors.amber,
                            //         textColor: Colors.black,
                            //         onPressed: (){
                            //           // TODO: Finalizar viaje

                            //           showCustomDialog(
                            //             context: context,
                            //             title: 'Estas seguro??',
                            //             content: '¿Estas seguro de finalizar el viaje?',
                            //             onPressed: (){
                                          
                            //               // TODO: Aqui cuando finaliza el pedido
                            //               _conductorBloc.add(OnSetClearPolylines());
                            //               _getPolylines(state);
                                        
                            //             }
                            //           );
                            //         },
                            //       ),
                            //     ),
                            //     const SizedBox(
                            //       width: 10,
                            //     ),
                            //   ],
                            // ),
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
      ),
    );


  }

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Function onPressed
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              onPressed();
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
        ],
      );
    },
  );
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

  Widget _buttonConectar(ConductorBloc conductorBloc) {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        text: 'DESCONECTARSE',
        color: Colors.amber,
        onPressed: () {
          conductorBloc.closeSocket();
          Navigator.pushNamedAndRemoveUntil(context, 'bienbenidoConductor', (route) => false, arguments: UserBloc().user?.nombreusuario ?? 'none');
        },
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled:
          false, // BOTON DE UBICACION POR DEFECTO ESQUINA SUPERIOR DERECHA
      markers: Set<Marker>.of({
        ..._con.markers.values,
        ..._conductorBloc.state.markers
      }),
      polylines: _conductorBloc.state.polylines,
    );
  }

  //// UTLIZADO PARA M3
  void refresh() {
    setState(() {});
  }

  bool hayPedido(ConductorState state){

    Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);
    Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

    return (origen != null && destino != null);
  }

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
}

class WidgetDetailMap extends StatelessWidget {
  final Function builder;

  const WidgetDetailMap({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

