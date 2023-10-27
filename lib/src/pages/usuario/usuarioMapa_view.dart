import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
import 'package:gruasgo/src/pages/usuario/usuarioMapa_controller.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';

class UsuarioMap extends StatefulWidget {
  const UsuarioMap({super.key});

  @override
  State<UsuarioMap> createState() => _UsuarioMapState();
}

class _UsuarioMapState extends State<UsuarioMap> {

  final UsuarioMapController _con = UsuarioMapController();
  late UsuarioPedidoBloc _usuarioPedidoBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);



    _usuarioPedidoBloc.respuesta(showAlert: showAlert);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);  //// REFRESH  PARA M3
    });
  }

  @override
  void dispose() {
    _usuarioPedidoBloc.clearSocket();
    // TODO: implement dispose
    super.dispose();
  }

  final LatLng origen = const LatLng(-17.7995132, -63.1924906);
  final LatLng destino = const LatLng(-17.8005504, -63.1786198);
  Completer<GoogleMapController> googleMapController = Completer<GoogleMapController>();


  @override
  Widget build(BuildContext context) {
    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    
    

    LatLng origen = _usuarioPedidoBloc.pedidoModel!.origen;
    LatLng destino = _usuarioPedidoBloc.pedidoModel!.destino;
    
    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: FutureBuilder(
        future: _usuarioPedidoBloc.getDirecion(origen: origen, destino: destino),
        builder: (context, snapshot) {
          return Stack(
            
            children: [

              GoogleMapWidget(
                initPosition: origen, 
                googleMapController: googleMapController,
                markers: {
                  Marker(
                    markerId: const MarkerId('origen'),
                    position: origen
                  ),
                  Marker(
                    markerId: const MarkerId('destino'),
                    position: destino
                  )
                },
                polylines: {
                  (_usuarioPedidoBloc.polylines != null) ?
                    Polyline(
                      polylineId: const PolylineId('ruta'),
                      color: Colors.black,
                      width: 5,
                      points: _usuarioPedidoBloc.polylines!.map((e) => LatLng(e.latitude, e.longitude)).toList()
                    ) : 
                    const Polyline(
                      polylineId: PolylineId('ruta'),
                      color: Colors.black,
                      width: 5,
                    )
                  
                },
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
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: Text(_usuarioPedidoBloc.googleMapDirection?.routes[0].legs[0].distance.text ?? '')
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.yellow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: Text(_usuarioPedidoBloc.googleMapDirection?.routes[0].legs[0].duration.text ?? '')
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add_location),
                        title: const Text('Desde'),
                        subtitle: Text(_usuarioPedidoBloc.pedidoModel?.bubinicial ?? ''),
                      ),
                      ListTile(
                        leading: const Icon(Icons.my_location),
                        title: const Text('Hasta'),
                        subtitle: Text(_usuarioPedidoBloc.pedidoModel?.bubfinal ?? ''),
                      ),
                      ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: const Text('Precio'),
                        subtitle: Text('${_usuarioPedidoBloc.pedidoModel!.bmonto} Bs.'),
                      ),
                      _buttonRequest(_usuarioPedidoBloc),
                    ],
                  ),
                ),
              )

              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     // const Row(
              //     //   children: [
              //     //     Text('Distancia: '),
              //     //     Text(': 123 Km'),
              //     //   ],
              //     // ),
              //     // const Row(
              //     //   children: [
              //     //     Text('Tiempo: '),
              //     //     Text(': 123 mins'),
              //     //   ],
              //     // ),

              //     _buttonDrawer(),
              //     // _buttonCenterPosition(),
              //     Expanded(child: Container()),
              //     //_cardGooglePlaces(),
              //     _buttonRequest(),
              //   ],
              // ),

            ],
          );
        },

      ),
    );
  }




  Widget _iconMyLocation(){
    return Image.asset(
      'assets/img/my_location.png',
      width: 40,
      height: 40,
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                color: Colors.amber
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nombre de usuario',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                  maxLines: 1,
                ),
                Text(
                  'Email',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold
                  ),
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

  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(
        alignment: Alignment.centerRight,
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

  Widget _buttonDrawer(){
    return  Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: const Icon(Icons.menu, color: Colors.white,) ,
      ),
    );
  }


  Widget _buttonRequest(UsuarioPedidoBloc usuarioPedidoBloc){
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(right: 60, left: 60, bottom: 20),
      child: ButtonApp(
        text: 'SOLICITAR',
        color: Colors.amber,
        textColor: Colors.black,
        onPressed: (){
          usuarioPedidoBloc.solicitar(
            origen: usuarioPedidoBloc.state.origen!,
            destino: usuarioPedidoBloc.state.destino!,
            servicio: usuarioPedidoBloc.pedidoModel!.bservicio,
            nombreOrigen: _usuarioPedidoBloc.pedidoModel?.bubinicial ?? '',
            nombreDestino: _usuarioPedidoBloc.pedidoModel?.bubfinal ?? '',
            descripcionDescarga: _usuarioPedidoBloc.pedidoModel?.bdescarga ?? '',
            monto: double.parse((_usuarioPedidoBloc.pedidoModel?.bmonto ?? 0).toString()),
            referencia: _usuarioPedidoBloc.pedidoModel!.bcelentrega
          );
        },
        //onPressed: _alertDialogCosto
/*          onPressed: () {
    showDialog(
    context: context,
    builder: (context) => _alertDialogCosto(),
    );
    },*/
        //child: Text('Mostrar AlertDialog'),,
      ),
    );
  }

  Widget _googleMapsWidget(){
    return GoogleMap (
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false, // BOTON DE UBICACION POR DEFECTO ESQUINA SUPERIOR DERECHA
      markers: Set<Marker>.of(_con.markers.values),
    );
  }

  Widget _cardGooglePlaces() {
    return Container(

      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Desde',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10
                ),
              ),
              const Text(
                //_con.from ??
                    'Av. San Martin calle curi',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 5),
              const Divider(color: Colors.grey, height: 10),
              const SizedBox(height: 5),
              const Text(
                'Hasta',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10
                ),
              ),
              const Text(
                // _con.to ??
                    'Villa 1ro de mayo calle cusis 34',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              TextField(
                //controller: _con.monbreapellidoController,
                maxLength: 30,
                style: const TextStyle(fontSize: 14),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                ],
                decoration: InputDecoration(
                  // hintText: 'Correo Electronico',
                  labelText: 'Referencia',
                  filled: true, // Habilita el llenado de color de fondo
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ) ,
              ),
            ],
          ),
        ),
      ),
    );
  }


  //// UTLIZADO PARA M3
  void refresh (){
    setState(() {
    });
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
