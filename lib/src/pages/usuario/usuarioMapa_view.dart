import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/pages/usuario/usuarioMapa_controller.dart';
import 'package:gruasgo/src/widgets/button_app.dart';

class UsuarioMap extends StatefulWidget {
  const UsuarioMap({super.key});

  @override
  State<UsuarioMap> createState() => _UsuarioMapState();
}

class _UsuarioMapState extends State<UsuarioMap> {

  UsuarioMapController _con = UsuarioMapController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);  //// REFRESH  PARA M3
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                _buttonDrawer(),
                _cardGooglePlaces(),
                _buttonCenterPosition(),
                Expanded(child: Container()),
                _buttonRequest(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _iconMyLocation(),
          ),

        ],
      ),
    );
  }


  Widget _alertDialogCosto() {
    return AlertDialog(
      title: Text('¿EL COSTO DEL SERVICIO SERA DE?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('assets/img/money.jpg',
            width: 70,
            height: 70,),
          Text(
            'Bs 200',
            style: TextStyle(
              fontSize: 30, // Tamaño de la fuente, ajusta el valor según lo que necesites
              color: Colors.red, // Color del texto, puedes cambiarlo a otro color
              fontWeight: FontWeight.bold, // Opcional: Puedes agregar negrita u otras propiedades de fuente
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Acción para "Aceptar"
            Navigator.of(context).pop();
          },
          child: Text('Aceptar'),
        ),
        TextButton(
          onPressed: () {
            // Acción para "Cancelar"
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
      ],
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'Nombre de usuario',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  child: Text(
                    'Email',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 10),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/img/profile.jpg'),
                  radius: 40,
                )
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.amber
            ),
          ),
          ListTile(
            title: Text('Historial Viajes'),
            trailing: Icon(Icons.edit),
            // leading: Icon(Icons.cancel),
            onTap: () {},
          ),
          ListTile(
            title: Text('Cerrar sesion'),
            trailing: Icon(Icons.power_settings_new),
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
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: CircleBorder(),
          color: Colors.amber[300],
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
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
        icon: Icon(Icons.menu, color: Colors.white,) ,
      ),
    );
  }


  Widget _buttonRequest(){
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.symmetric(horizontal: 60,vertical: 30),
      child: ButtonApp(
        text: 'SOLICITAR',
        color: Colors.amber,
        textColor: Colors.black,
        //onPressed: _alertDialogCosto
          onPressed: () {
    showDialog(
    context: context,
    builder: (context) => _alertDialogCosto(),
    );
    },
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Desde',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10
                ),
              ),
              Text(
                //_con.from ??
                    'DSjje jois ljlkdf',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                ),
                maxLines: 2,
              ),
              SizedBox(height: 5),
              Container(
                // width: double.infinity,
                  child: Divider(color: Colors.grey, height: 10)
              ),
              SizedBox(height: 5),
              Text(
                'Hasta',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10
                ),
              ),
              Text(
                // _con.to ??
                    'ej iosjoeijlsji fei',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                ),
                maxLines: 2,
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

}
