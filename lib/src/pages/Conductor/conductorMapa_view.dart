import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/arguments/detalle_notificacion_conductor.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/enum/estado_pedido_aceptado_enum.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/global/enviroment.dart';
import 'package:gruasgo/src/helpers/get_hora.dart';
import 'package:gruasgo/src/helpers/get_marker.dart';
import 'package:gruasgo/src/helpers/get_position.dart';
import 'package:gruasgo/src/lib/map_icon.dart';
import 'package:gruasgo/src/pages/Conductor/conductorMapa_controller.dart';
import 'package:gruasgo/src/services/http/conductor_service.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';
import 'package:gruasgo/src/widgets/informacion_widget.dart';
import 'package:gruasgo/src/widgets/show_custom_dialog_widget.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';

class ConductorMap extends StatefulWidget {
  const ConductorMap({super.key});

  @override
  State<ConductorMap> createState() => _ConductorMapState();
}

class _ConductorMapState extends State<ConductorMap> {
  final DriverMapController _con = DriverMapController();



  bool tiempoIniciado = false;

  Timer? _timer;
  late ConductorBloc _conductorBloc;
  late UserBloc _userBloc;

  Completer<GoogleMapController> googleMapController = Completer<GoogleMapController>();
  late Location location;

  late Position _position;

  late StreamSubscription<LocationData> locationSubscription;

  @override 
  void initState() {
    // TODO: implement initState
    super.initState();

    location = Location();
    final navigator = Navigator.of(context);
    _conductorBloc = BlocProvider.of<ConductorBloc>(context);


    _conductorBloc.listenNotificacionPedidoCancelado(navigator: navigator);

    _userBloc = BlocProvider.of<UserBloc>(context);
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {


      final position = await getPositionHelpers();

      if (hayPedido(_conductorBloc.state)){
        _conductorBloc.updatePosition(
          lat: position.latitude, lng: position.longitude
        );
      }



      _conductorBloc.actualizarCoorEstado(
        idUsuario: _userBloc.user!.idUsuario
      );
    });

    _conductorBloc.notificacionNuevaSolicitudConductor(
      navigator: navigator,
      idConductor: _userBloc.user!.idUsuario
    );

  }

  @override
  void dispose() {

    googleMapController.future.then((controllerValue) => {
      controllerValue.dispose()
    });

    locationSubscription.cancel();
    
    _timer?.cancel();
    _conductorBloc.clearSocketNotificacionNuevaSolicitudConductor();
    _conductorBloc.clearSocketNotificacionPedidoCancelado();
    _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));
    _conductorBloc.add(OnSetClearPolylines());
    _conductorBloc.add(OnSetLimpiarPedidos());
    _conductorBloc.add(OnSetNewMarkets({}));

    _conductorBloc.yaHayPedido = false;
    // if (_conductorBloc.state.detallePedido == null){
    //   _conductorBloc.eliminarEstado();
    // }


    // TODO: implement dispose
    super.dispose();
  }


  Future getPosition({required ConductorBloc conductorBloc}) async {
    _position = await getPositionHelpers();
    
    conductorBloc.add(OnSetAddMarker(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(_position.latitude, _position.longitude),
        icon: MapIcons.iconConductor ?? BitmapDescriptor.defaultMarker
      ),
      
    ));

    locationSubscription = location.onLocationChanged.listen((LocationData cLoc) async{
      if (cLoc.latitude != null && cLoc.longitude != null){

        // Aqui es el evento cuando se mueve el usuario

        if (hayPedido(_conductorBloc.state)){

          Marker? marker = (_conductorBloc.state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.finalizarCarrera) ?
            getMarkerHelper(markers: _conductorBloc.state.markers, id: MarkerIdEnum.destino) :
            getMarkerHelper(markers: _conductorBloc.state.markers, id: MarkerIdEnum.origen);

          if (marker != null){
            List<PointLatLng>? polyline = await _conductorBloc.getPolylines(
              origen: LatLng(cLoc.latitude!, cLoc.longitude!), 
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
        
        conductorBloc.add(OnSetAddMarker(
          Marker(
            markerId: const MarkerId('driver'),
            position: LatLng(cLoc.latitude!, cLoc.longitude!),
            icon: MapIcons.iconConductor ?? BitmapDescriptor.defaultMarker
          ),
          
        ));

        if (_userBloc.camaraEnfocada){
          final GoogleMapController controller = await googleMapController.future;
          controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(cLoc.latitude!, cLoc.longitude!))
          );
        }
              
      }
   
    });

  }

  @override
  Widget build(BuildContext context) {
    _conductorBloc = BlocProvider.of<ConductorBloc>(context);

    return SafeArea(
      child: Scaffold(
        key: _con.key,
        drawer: _drawer(),
        body: FutureBuilder(
          future: getPosition(conductorBloc: _conductorBloc),
          builder: (context, snapshot) {
    
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Text('Cargando'),);
    
            return BlocBuilder<ConductorBloc, ConductorState>(
              builder: (context, state) {
    
                return Column(
                  children: [
    
                    Expanded(
                      child: Stack(
                        children: [
                          Listener(
                            onPointerMove: (event) {
                              if (!hayPedido(state)){
                                _userBloc.camaraEnfocada = false;
                              }
                            },
                            child: GoogleMapWidget(
                              initPosition: LatLng(_position.latitude, _position.longitude), 
                              googleMapController: googleMapController,
                              markers: state.markers,
                              myLocationEnabled: false,
                              polylines: state.polylines,
                              zoom: 14,
                            ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buttonDrawer(), 
                                    (hayPedido(state)) ? 
                                      Container() :
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // _googleMapsWidget(),
                    WidgetDetailMap(
                      builder: (){
                        if (!hayPedido(state)){
                          return Column(
                            children: [
                              _buttonConectar(_conductorBloc),
                            ],
                          );
                        }else{
                          return Column(
                            children: [
        
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15),
                                child: 
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      children: [

                                        InformacionWidget(
                                          icons: Icons.arrow_downward,
                                          titulo: 'Origen',
                                          descripcion: state.detallePedido?.nombreOrigen ?? '',
                                        ),
                                        const SizedBox(height: 5,),
                                        InformacionWidget(
                                          icons: Icons.arrow_upward,
                                          titulo: 'Destino',
                                          descripcion: state.detallePedido?.nombreDestino ?? '',
                                        ),
                                        const SizedBox(height: 5,),
                                        (
                                          Enviroment().listaServicioHoraAvanzada.contains(state.detallePedido?.servicio ?? '-') ||
                                          (Enviroment().listaServicioPorHoraBasico.contains(state.detallePedido?.servicio ?? '-') && state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.finalizarCarrera)
                                        ) ? InformacionWidget(
                                          isColumn: false,
                                          colorDescription: Colors.blue,
                                          icons: Icons.timer,
                                          titulo: 'Hora de inicio',
                                          descripcion: state.detallePedido?.horaInicio ?? getHoraHelpers(),
                                        ) : Container(),
                                        // const SizedBox(height: 4,),
                                        InformacionWidget(
                                          isColumn: false,
                                          icons: Icons.person,
                                          titulo: 'Cliente',
                                          descripcion: state.detallePedido?.cliente ?? '',
                                        ),
                                        // const SizedBox(height: 4,),
                                        InformacionWidget(
                                          isColumn: false,
                                          icons: Icons.phone,
                                          titulo: 'Celular Ref',
                                          descripcion: state.detallePedido?.referencia.toString() ?? '',
                                        ),
                                        // const SizedBox(height: 4,),
                                        InformacionWidget(
                                          isColumn: false,
                                          icons: Icons.map_outlined,
                                          titulo: 'Descripcion Carga',
                                          descripcion: state.detallePedido?.descripcionDescarga ?? '',
                                        ),
                                        // const SizedBox(height: 4,),
                                        Row(
                                          children: [
                                            (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.estoyAqui) ? 
                                            Expanded(
                                              child: ButtonApp(
                                                text: 'Estoy aqui',
                                                color: Colors.amber,
                                                textColor: Colors.black,
                                                onPressed: (){
                                                                              
                                                  // TODO: Comenzar RutaF
                                                  showCustomDialog(
                                                    context: context,
                                                    title: 'Estas seguro??',
                                                    content: '¿Confirmar que llego al lugar de recogida?',
                                                    onPressed: () async {
                                                      
                                            
                                                      final status = await _conductorBloc.actualizarPedido(
                                                        idConductor: _userBloc.user!.idUsuario, 
                                                        idPedido: state.detallePedido!.pedidoId, 
                                                        idVehiculo: _userBloc.user!.place, 
                                                        estado: 'NOCL'
                                                      );
                                                      if (status){
                                                        _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.comenzarCarrera));
                                                        _conductorBloc.emitYaEstoyAqui();
                                                      }
                                                  
                                                    }
                                                  );
                                                  
                                                                              
                                                },
                                              ),
                                            ) : (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.comenzarCarrera) ? 
                                            Expanded(
                                              child: ButtonApp(
                                                text: 'Comenzar carrera',
                                                color: Colors.blue,
                                                textColor: Colors.white,
                                                onPressed: (){
                                                  
                                                  showCustomDialog(
                                                    context: context,
                                                    title: 'Estas seguro??',
                                                    content: '¿Estas seguro que quieres comenzar el viaje?',
                                                    onPressed: () async {
                                                      
                                                      if (Enviroment().listaServicioPorHoraBasico.contains(state.detallePedido?.servicio ?? '-')){
                                                        _conductorBloc.add(OnSetDetallePedido(
                                                          DetalleNotificacionConductor(
                                                            origen: state.detallePedido!.origen, 
                                                            destino: state.detallePedido!.destino, 
                                                            servicio: state.detallePedido!.servicio, 
                                                            cliente: state.detallePedido!.cliente, 
                                                            clienteId: state.detallePedido!.clienteId, 
                                                            nombreOrigen: state.detallePedido!.nombreOrigen, 
                                                            nombreDestino: state.detallePedido!.nombreDestino, 
                                                            descripcionDescarga: state.detallePedido!.descripcionDescarga, 
                                                            referencia: state.detallePedido!.referencia, 
                                                            monto: state.detallePedido!.monto, 
                                                            socketClientId: state.detallePedido!.socketClientId, 
                                                            pedidoId: state.detallePedido!.pedidoId, 
                                                            estado: state.detallePedido!.estado,
                                                            horaInicio: getHoraHelpers(),
                                                            tipoPago: state.detallePedido!.tipoPago
                                                          )
                                                        ));
                                                      }
                                                      _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.finalizarCarrera));
                                                      _conductorBloc.add(OnSetClearPolylines());
                                                      _conductorBloc.add(OnSetRemoveMarker(MarkerIdEnum.origen));
                                                      
                                                      _conductorBloc.add(
                                                        OnSetAddMarker(
                                                          Marker(
                                                            markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                                            position: state.detallePedido!.destino,
                                                            icon: MapIcons.iconMarkerDestino ?? BitmapDescriptor.defaultMarker
                                                          )
                                                        )
                                                      );

                                                      _getPolylines(state);
                                                      final statusPedido = await _conductorBloc.actualizarPedido(
                                                        estado: 'VICO',
                                                        idConductor: _userBloc.user!.idUsuario,
                                                        idPedido: state.detallePedido!.pedidoId,
                                                        idVehiculo: _userBloc.user!.place
                                                      );
                                                  
                                                      if (statusPedido){
                                                        if (Enviroment().listaServicioPorHoraBasico.contains(state.detallePedido!.servicio)){
                                                          await _conductorBloc.adiccionarHora(
                                                            idPedido: state.detallePedido!.pedidoId
                                                          );
                                                  
                                                        }
                                            
                                                        _conductorBloc.emitComenzarCarrera();
                                                      }
                                              
                                                    
                                                    }
                                                  );
                                                  
                                                },
                                              ),
                                            ): Expanded(
                                              child: ButtonApp(
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
                                                        idVehiculo: _userBloc.user!.place
                                                      );
                                                      if (status){
                                                        if (
                                                          Enviroment().listaServicioHoraAvanzada.contains(state.detallePedido?.servicio ?? '-') ||
                                                          Enviroment().listaServicioPorHoraBasico.contains(state.detallePedido?.servicio ?? '-')
                                                        ){
                                                          
                                                          int? minutos = await _conductorBloc.getMinutosConsumidos(idPedido: state.detallePedido!.pedidoId);
                                                          if (minutos != null){
                                                            _conductorBloc.add(OnSetTiempoTranscurrido(minutos));
                                                            
                                                            final Response precioResponse = await ConductorService.getPrecioHoras(
                                                              servicio: state.detallePedido!.servicio,
                                                              minutos: minutos
                                                            );

                                                  
                                                            print('El precio es');
                                                            print(precioResponse.body);
                                                            final precio = json.decode(precioResponse.body)['costo'];
                                                            if (precio != null){


                                                              // TODO: Guardar el precio en el pedido
                                                              final statusPrecio = await _conductorBloc.updatePrecioTotal(
                                                                idPedido: state.detallePedido!.pedidoId, monto: precio
                                                              );

                                                              if (statusPrecio){
                                                                _conductorBloc.add(OnSetDetallePedido(DetalleNotificacionConductor(
                                                                  origen: _conductorBloc.state.detallePedido!.origen, 
                                                                  destino: _conductorBloc.state.detallePedido!.destino, 
                                                                  servicio: _conductorBloc.state.detallePedido!.servicio, 
                                                                  cliente: _conductorBloc.state.detallePedido!.cliente, 
                                                                  clienteId: _conductorBloc.state.detallePedido!.clienteId, 
                                                                  nombreOrigen: _conductorBloc.state.detallePedido!.nombreOrigen, 
                                                                  nombreDestino: _conductorBloc.state.detallePedido!.nombreDestino, 
                                                                  descripcionDescarga: _conductorBloc.state.detallePedido!.descripcionDescarga, 
                                                                  referencia: _conductorBloc.state.detallePedido!.referencia, 
                                                                  monto: precio, 
                                                                  socketClientId: _conductorBloc.state.detallePedido!.socketClientId, 
                                                                  pedidoId: _conductorBloc.state.detallePedido!.pedidoId, 
                                                                  estado: _conductorBloc.state.detallePedido!.estado,
                                                                  tiempoTranscurrido: minutos,
                                                                  tipoPago: _conductorBloc.state.detallePedido!.tipoPago
                                                                )));


                                                                _conductorBloc.emitFinalizarPedido(
                                                                  minutos: minutos
                                                                );
                                                                _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));
                                                                // TODO: Aqui cuando finaliza el pedido
                                                                _conductorBloc.add(OnSetClearPolylines());
                                                                _getPolylines(state);
                                                                _conductorBloc.eliminarCrearEstado(
                                                                  idUsuario: _userBloc.user!.idUsuario,
                                                                  servicio: _userBloc.user!.subCategoria
                                                                );
                                                                navigator.pushNamedAndRemoveUntil('ConductorFinalizacion', (route) => false);

                                                              }

                                                             
                                                            }
                                                  
                                                          }
                                                  
                                                  
                                                          
                                                        }else{
                                                  
                                                  
                                                          _conductorBloc.emitFinalizarPedido();
                                                          _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.estoyAqui));
                                                          // TODO: Aqui cuando finaliza el pedido
                                                          _conductorBloc.add(OnSetClearPolylines());
                                                          _getPolylines(state);
                                                          _conductorBloc.eliminarCrearEstado(
                                                            idUsuario: _userBloc.user!.idUsuario,
                                                            servicio: _userBloc.user!.subCategoria
                                                          );
                                                          navigator.pushNamedAndRemoveUntil('ConductorFinalizacion', (route) => false);
                                                        }
                                                  
                                                      }
                                                  
                                                    }
                                                  );
                                                },
                                              ),
                                            ),
    
                                            const SizedBox(width: 10,),
    
                                             Expanded(
                                                child: ButtonApp(
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
                                                        _conductorBloc.emitRespuestaPedidoProcesoCancelado();
                                                        final status = await _conductorBloc.actualizarPedido(
                                                          estado: 'CACO',
                                                          idConductor: _userBloc.user!.idUsuario,
                                                          idPedido: state.detallePedido!.pedidoId,
                                                          idVehiculo: _userBloc.user!.place
                                                        );
                                                        if (status){
                                                          final statusEstadoConductor = await _conductorBloc.eliminarEstado(
                                                            idUsuario: _userBloc.user!.idUsuario
                                                          );
                                                    
                                                          if (statusEstadoConductor){
                                                            _timer?.cancel();
                                                            _conductorBloc.clearSocketNotificacionNuevaSolicitudConductor();
                                                            _conductorBloc.add(OnSetEstadoPedidoAceptado(EstadoPedidoAceptadoEnum.sinPedido));
                                                            _conductorBloc.add(OnSetClearPolylines());
                                                            _conductorBloc.add(OnSetLimpiarPedidos());
                                                            _conductorBloc.add(OnSetNewMarkets({}));
                                                            _conductorBloc.yaHayPedido = false;
    
    
                                                            // if (_conductorBloc.state.detallePedido == null){
                                                            //   _conductorBloc.eliminarEstado();
                                                            // }

    
                                                            locationSubscription.cancel();
                                                            navigator.pushNamedAndRemoveUntil('bienbenidoConductor', (route) => false, arguments: _userBloc.user!.nombreusuario);
                                                          }
                                                        }
                                                    
                                                      }
                                                    );
                                                    
                                                
                                                    
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ) 
                              )
                            ],
                          );
                        }
                      },
                    )
                  ],
                );
              },
            );
          }
        ),
      ),
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
      onTap: () async {
        _userBloc.camaraEnfocada = true;
        Position positionD = await getPositionHelpers();
        final GoogleMapController controller = await googleMapController.future;
        if (_userBloc.camaraEnfocada){
          controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(positionD.latitude, positionD.longitude))
          );
        }
      },
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
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
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

  //// UTLIZADO PARA M3


  bool hayPedido(ConductorState state){

    Marker? destino = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);

    return (destino != null);
  }

  Future _getPolylines(ConductorState state) async {

    Position position = await getPositionHelpers();


    List<PointLatLng>? polyline = await _conductorBloc.getPolylines(
      origen: LatLng(position.latitude, position.longitude), 
      destino: state.detallePedido!.destino
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

