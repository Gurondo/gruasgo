import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/pages/usuario/usuarioMapa_controller.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';

class UsuarioMap extends StatefulWidget {
  const UsuarioMap({super.key});

  @override
  State<UsuarioMap> createState() => _UsuarioMapState();
}

class _UsuarioMapState extends State<UsuarioMap>{



  final UsuarioMapController _con = UsuarioMapController();
  

  late UsuarioPedidoBloc _usuarioPedidoBloc;

  Completer<GoogleMapController> googleMapController = Completer<GoogleMapController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final navigator = Navigator.of(context);
    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    _usuarioPedidoBloc.listenPedidoProcesoCancelado();
    _usuarioPedidoBloc.respuesta(showAlert: showAlert);
    _usuarioPedidoBloc.actualizarContador();
    _usuarioPedidoBloc.listenPosicionConductor();
    _usuarioPedidoBloc.listenConductorEstaAqui();
    _usuarioPedidoBloc.listenPedidoFinalizado(navigator: navigator);
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
    
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);


    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: Scaffold(
        key: _con.key,
        drawer: _drawer(),
        body: BlocBuilder<UsuarioPedidoBloc, UsuarioPedidoState>(
          builder: (context, state) {
            return Column(
              children: [
    
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMapWidget(
                        initPosition: getMarkerHelper(markers: _usuarioPedidoBloc.state.markers, id: MarkerIdEnum.origen)!.position,
                        googleMapController: googleMapController,
                        markers: state.markers,
                        polylines: state.polylines,
                        ajustarZoomOrigenDestino: true,
                      ),
                      SafeArea(
                        child: Align(
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
                        ),
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
                      ) : Container()
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
                        const SizedBox(height: 12,),
                        InformacionWidget(
                          icons: Icons.add_location,
                          titulo: 'Desde',
                          descripcion: _usuarioPedidoBloc.pedidoModel?.bubinicial ?? '',
                        ),
                        const SizedBox(height: 12,),
                        InformacionWidget(
                          icons: Icons.my_location,
                          titulo: 'Hasta',
                          descripcion: _usuarioPedidoBloc.pedidoModel?.bubfinal ?? '',
                        ),
                        
                        (_usuarioPedidoBloc.pedidoModel!.bmonto != '0') ? const SizedBox(height: 12,) : Container(),
                        
                        (_usuarioPedidoBloc.pedidoModel!.bmonto != '0') ? InformacionWidget(
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
                ) : Container(
                  child: TextButton(
                    onPressed: (){
                      _usuarioPedidoBloc.add(OnSetIdConductor(''));
                    Navigator.pushNamedAndRemoveUntil(context, 'bienbendioUsuario', (route) => false, arguments: userBloc.user!.nombreusuario);
                  }, child: Text('data')),
                ),
    
              ],
            );
          },
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
              // origen: usuarioPedidoBloc.state.origen!,
              // destino: usuarioPedidoBloc.state.destino!,
              servicio: usuarioPedidoBloc.pedidoModel!.bservicio,
              nombreOrigen: _usuarioPedidoBloc.pedidoModel?.bubinicial ?? '',
              nombreDestino: _usuarioPedidoBloc.pedidoModel?.bubfinal ?? '',
              descripcionDescarga:
                  _usuarioPedidoBloc.pedidoModel?.bdescarga ?? '',
              monto: double.parse(
                  (_usuarioPedidoBloc.pedidoModel?.bmonto ?? 0).toString()),
              referencia: _usuarioPedidoBloc.pedidoModel!.bcelentrega,
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

class InformacionWidget extends StatelessWidget {
  
  final IconData icons;
  final String titulo;
  final String descripcion;

  const InformacionWidget({
    super.key,
    required this.icons,
    required this.titulo,
    required this.descripcion
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Icon(icons, color: Colors.black87,),
        ),
        Expanded(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(titulo, style: const TextStyle(fontSize: 16),)),
              const SizedBox(height: 3,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(descripcion, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black54),),)
            ],
          )
        )
      ],
    );
  }
}
