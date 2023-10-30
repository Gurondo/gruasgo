import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/conductor/conductor_bloc.dart';
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

  Completer<GoogleMapController> googleMapController = Completer<GoogleMapController>();

  Timer? _timer;
  late ConductorBloc _conductorBloc;

  @override
  void initState() {
    
    // TODO: implement initState
    super.initState();

    _conductorBloc = BlocProvider.of<ConductorBloc>(context);
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {

      final position = await getPositionHelpers();
      _conductorBloc.updatePosition(lat: position.latitude, lng: position.longitude);

    });

    final navigator = Navigator.of(context);
    _conductorBloc.respuestaSolicitudConductor(navigator: navigator);

    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   _con.init(context, refresh);  //// REFRESH  PARA M3
    // });
  }

  @override
  void dispose() {
    
    _timer?.cancel();
    _conductorBloc.clearSocketSolicitudConductor();

    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    _conductorBloc = BlocProvider.of<ConductorBloc>(context);

    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: FutureBuilder<Position>(
        future: getPositionHelpers(),
        builder : (context, snapshot) {

          
          if (snapshot.connectionState == ConnectionState.done){
            return Stack(
              children: [
                GoogleMapWidget(
                  initPosition: LatLng(snapshot.data!.latitude, snapshot.data!.longitude), 
                  googleMapController: googleMapController,
                  markers: {
                    Marker(
                      markerId: const MarkerId('position'),
                      position: LatLng(snapshot.data!.latitude, snapshot.data!.longitude)
                    )
                  },
                ),
                // _googleMapsWidget(),
                SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buttonDrawer(),
                          _buttonCenterPosition()
                        ],
                      ),
                      Expanded(child: Container()),
                      _buttonDesconectar(_conductorBloc),
                    ],
                  ),
                )

              ],
            );
          } else{
            return Container();
          }

         
        }
      ),
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
                  'Nombre de conductor',
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

  Widget _buttonCenterPosition(){
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

  Widget _buttonDrawer(){
    return  Container(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: _con.openDrawer,
          icon: const Icon(Icons.menu, color: Colors.white,) ,
        ),
      );
  }


  Widget _buttonDesconectar(ConductorBloc conductorBloc){
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 60,vertical: 30),
      child: ButtonApp(
        text: 'Desconectarse'.toUpperCase(),
        color: Colors.amber,
        onPressed: (){
          conductorBloc.closeSocket();
          Navigator.pop(context);
        },
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

  //// UTLIZADO PARA M3
  // void refresh (){
  //   setState(() {
  //   });
  // }



}
