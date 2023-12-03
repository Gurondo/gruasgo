import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/enum/estado_pedido_aceptado_enum.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/pages/usuario/usuarioMapa_controller.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';
import 'package:gruasgo/src/widgets/informacion_widget.dart';
import 'package:gruasgo/src/widgets/show_custom_dialog_widget.dart';

class UsuarioMap extends StatefulWidget {
  const UsuarioMap({super.key});

  @override
  State<UsuarioMap> createState() => _UsuarioMapState();
}

class _UsuarioMapState extends State<UsuarioMap>{



  final UsuarioMapController _con = UsuarioMapController();
  

  late UsuarioPedidoBloc _usuarioPedidoBloc;
  late UserBloc _userBloc;

  Completer<GoogleMapController> googleMapController = Completer<GoogleMapController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    final navigator = Navigator.of(context);
    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);

    _usuarioPedidoBloc.conectarseSocket(idUsuario: _userBloc.user!.idUsuario);

    _usuarioPedidoBloc.listenPedidoProcesoCancelado(
      navigator: navigator,
      nombreUsuario: _userBloc.user!.nombreusuario
    );
    _usuarioPedidoBloc.respuesta(showAlert: showAlert);
    _usuarioPedidoBloc.actualizarContador();
    _usuarioPedidoBloc.listenPosicionConductor();
    _usuarioPedidoBloc.listenConductorEstaAqui();
    _usuarioPedidoBloc.listenPedidoFinalizado(navigator: navigator);
    _usuarioPedidoBloc.listenComenzarCarrera();
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   _con.init(context, refresh);  //// REFRESH  PARA M3
    // });
  }

  @override
  void dispose() {

    _usuarioPedidoBloc.clearSocketPedidoFinalizado();
    _usuarioPedidoBloc.clearSocketConductorEstaAqui();
    _usuarioPedidoBloc.clearSocketRespuestaUsuario();
    _usuarioPedidoBloc.clearSocketPedidoProcesadoCancelado();
    _usuarioPedidoBloc.clearSocketActualizarContador();
    _usuarioPedidoBloc.clearSocketPosicionConductor();
    _usuarioPedidoBloc.clearSocketComenzarCarrera();
    _usuarioPedidoBloc.add(OnRemoveMarker(MarkerIdEnum.conductor));

    googleMapController.future.then((controllerValue) => {
      controllerValue.dispose()
    });

    _usuarioPedidoBloc.desconectarseSocket();
    
    // TODO: implement dispose
    super.dispose();
  }

  String getText ({
    required UsuarioPedidoState state
  }) {
    if (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.estoyAqui) return 'El conductor se encuentra en camino';
    if (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.comenzarCarrera) return 'El conductor ya esta en el lugar';
    if (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.finalizarCarrera) return 'El conductor inicio la carrera';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);


    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: Scaffold(
        key: _con.key,
        drawer: _drawer(),
        body: BlocBuilder<UsuarioPedidoBloc, UsuarioPedidoState>(
          builder: (context, state) {


            final Marker? conductor = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.conductor);
            if (conductor != null){
              _actualizarPosicionCamara(conductor.position);
            }

            return Column(
              children: [
                
                

                Expanded(
                  child: Stack(
                    children: [
                      GoogleMapWidget(
                        initPosition: getMarkerHelper(markers: _usuarioPedidoBloc.state.markers, id: MarkerIdEnum.origen)?.position ?? getMarkerHelper(markers: _usuarioPedidoBloc.state.markers, id: MarkerIdEnum.destino)!.position,
                        googleMapController: googleMapController,
                        markers: state.markers,
                        polylines: state.polylines,
                        ajustarZoomOrigenDestino: true,
                        myLocationEnabled: false,
                      ),
                      SafeArea(
                        child: (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.sinPedido) ?
                         Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.yellow,
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Text(state.distancia),
                                )),
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.yellow,
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Text(state.duracion)),
                                ),
                              ],
                            ),
                          ),
                        ) : 
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(211, 255, 255, 255),
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  getText(state: state)
                                )
                              ),
                            ),
                          ],
                        )
                        
                      ),

                      (state.conductorEstaAqui) ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: const EdgeInsets.only(top: 50, bottom: 15),
                          height: 160,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('El conductor ya esta en el lugar', style: TextStyle(fontSize: 15),),
                              const SizedBox(height: 12,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ButtonApp(
                                  text: 'Aceptar',
                                  color: Colors.amber,
                                  onPressed: (){
                                    _usuarioPedidoBloc.add(OnConductorEstaAqui(false));
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ) : Container(),

                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                        )
                      )
                      
                    ],

                    
                  ),
                ),
              
    
                (state.idConductor == '') ? 
    
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.only(top: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 5,),
                        InformacionWidget(
                          icons: Icons.add_location,
                          titulo: 'Origen',
                          descripcion: _usuarioPedidoBloc.pedidoModel?.bubinicial ?? '',
                        ),
                        const SizedBox(height: 5,),
                        InformacionWidget(
                          icons: Icons.my_location,
                          titulo: 'Destinjo',
                          descripcion: _usuarioPedidoBloc.pedidoModel?.bubfinal ?? '',
                        ),

                        InformacionWidget(
                          colorDescription: Colors.red,
                          isColumn: false,
                          icons: Icons.car_crash,
                          titulo: 'Vehiculo',
                          descripcion: _usuarioPedidoBloc.pedidoModel?.bservicio ?? '',
                        ),
                        
                        (_usuarioPedidoBloc.pedidoModel!.bmonto != '0') ? const SizedBox(height: 5,) : Container(),
                        
                        (_usuarioPedidoBloc.pedidoModel!.bmonto != '0') ? InformacionWidget(
                          colorDescription: Colors.red,
                          isColumn: false,
                          icons: Icons.attach_money,
                          titulo: 'Precio',
                          descripcion: '${_usuarioPedidoBloc.pedidoModel!.bmonto} Bs.',
                        ) : Container(),
                        
                        const SizedBox(height: 12,),
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: _buttonRequest(
                                usuarioPedidoBloc: _usuarioPedidoBloc,
                                userBloc: userBloc
                              )),
                              const SizedBox(width: 12,),
                              Expanded(child: _buttonCancel(_usuarioPedidoBloc))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ) : Column(
                  children: [
                    const SizedBox(height: 10,),
                    InformacionWidget(
                      icons: Icons.add_location,
                      titulo: 'Origen',
                      descripcion: _usuarioPedidoBloc.pedidoModel?.bubinicial ?? '',
                    ),
                    const SizedBox(height: 5,),
                    InformacionWidget(
                      icons: Icons.my_location,
                      titulo: 'Destino',
                      descripcion: _usuarioPedidoBloc.pedidoModel?.bubfinal ?? '',
                    ),
                    const SizedBox(height: 5,),
                    InformacionWidget(
                      colorDescription: Colors.red,
                      isColumn: false,
                      icons: Icons.rectangle_outlined,
                      titulo: 'Placa',
                      descripcion: _usuarioPedidoBloc.pedidoModel?.placa ?? '',
                    ),
                    const SizedBox(height: 5,),
                    InformacionWidget(
                      colorDescription: Colors.red,
                      isColumn: false,
                      icons: Icons.car_crash,
                      titulo: 'Vehiculo',
                      descripcion: _usuarioPedidoBloc.pedidoModel?.bservicio ?? '',
                    ),
                    const SizedBox(height: 10,),
                    (state.estadoPedidoAceptado == EstadoPedidoAceptadoEnum.estoyAqui) ? 
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ButtonApp(
                        color: Colors.amber,
                        text: 'Cancelar el pedido',
                        onPressed: (){
                          
                          showCustomDialog(
                            context: context,
                            title: 'Estas seguro??',
                            content: '¿Estas seguro que quieres cancelar el viaje?',
                            onPressed: () async {
                              
                    
                              final navigator = Navigator.of(context);
                              final resp = await usuarioPedidoBloc.cancelarPedidoEnProceso();
                              if (resp){
                                usuarioPedidoBloc.emitPedidoCanceladoEnProceso();
                                usuarioPedidoBloc.add(OnSetIdConductor(-1));
                                usuarioPedidoBloc.add(OnClearPolylines());
                                navigator.pushNamedAndRemoveUntil('bienbendioUsuario', (route) => false);
                              }
                            }
                          );

                          
                        },
                      ),
                    ) : 
                    Container()
                  ],
                )
    
              ],
            );
          },
        ),
      ),
    );
  }


  Future<void> _actualizarPosicionCamara(LatLng conductor)async{
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(conductor.latitude, conductor.longitude))
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
                  'Nombre de usuario',
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
            title: const Text('Historial Viajes'),
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

  Widget _buttonRequest({
    required UsuarioPedidoBloc usuarioPedidoBloc,
    required UserBloc userBloc
  }) {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      // margin: const EdgeInsets.only(right: 60, left: 60, bottom: 20),
      child: ButtonApp(
        text: 'SOLICITAR',
        color: Colors.amber,
        textColor: Colors.black,
        onPressed: () async {
          
          final navigator = Navigator.of(context);

          final status = await usuarioPedidoBloc.registrarPedido(
            idUsuario: userBloc.user!.idUsuario, 
            ubiInicial: usuarioPedidoBloc.pedidoModel!.bubinicial, 
            ubiFinal: usuarioPedidoBloc.pedidoModel!.bubfinal, 
            metodoPago: usuarioPedidoBloc.pedidoModel!.bmetodopago, 
            monto: usuarioPedidoBloc.pedidoModel!.bmonto, 
            servicio: usuarioPedidoBloc.pedidoModel!.bservicio, 
            descripcionDescarga: usuarioPedidoBloc.pedidoModel!.bdescarga, 
            celentrega: usuarioPedidoBloc.pedidoModel!.bcelentrega
          );

          if (status){
            usuarioPedidoBloc.solicitar(
              origen: usuarioPedidoBloc.pedidoModel!.origen,
              destino: usuarioPedidoBloc.pedidoModel!.destino,
              servicio: usuarioPedidoBloc.pedidoModel!.bservicio,
              pedidoId: usuarioPedidoBloc.pedidoModel!.bidpedido,
              nombreUsuario: userBloc.user!.nombreusuario,
              clienteid: userBloc.user!.idUsuario,
            );

            navigator.pushNamed('UsuarioBuscando');
          }else{
            print('Error a la hora de crear el pedido, por eso no se notificara a los conductores');
          }
        },
      ),
    );
  }

  Widget _buttonCancel(UsuarioPedidoBloc usuarioPedidoBloc) {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      // margin: const EdgeInsets.only(right: 60, left: 60, bottom: 20),
      child: ButtonApp(
        text: 'Cancelar'.toUpperCase(),
        color: Colors.amber,
        textColor: Colors.black,
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, 'bienbendioUsuario', (route) => false);
        },
      ),
    );
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
  

}

