import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:gruasgo/src/pages/home/home_controller.dart';

class HomePage extends StatelessWidget{
  HomeController _con = new HomeController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _con.init(context);  // INICIALIZAMOS NUESTRO CONTROLADOR
    return Scaffold(
      // backgroundColor: Colors.amber,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.amber,Colors.white]
            )
          ),
          child: Column(
            children: [
              _BannerApp(context),
              SizedBox(height: 50),
              Text('SELECCIONA TU ROL'),
              SizedBox(height: 30),
              _imagenes(context,'assets/img/pasajero.png'),
              SizedBox(height: 10),
              _textosUsuarios('Cliente'),
              SizedBox(height: 30),
              _imagenes(context,'assets/img/driver.png'),
              SizedBox(height: 10),
              _textosUsuarios('Conductor')
            ],
          ),
        ),
      ),
    );
  }

  Widget _BannerApp (BuildContext context){
    return ClipPath(
      clipper: OvalTopBorderClipper(),
      child: Container(
        color: Colors.amber,
        height: MediaQuery.of(context).size.height * 0.30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/img/logo_gruas.png',
              width: 150,
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenes(BuildContext context, String imagen){
    return GestureDetector(
      onTap: _con.goToLoginPage,

      child: CircleAvatar(
        backgroundImage: AssetImage(imagen),
        radius: 50,
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  Widget _textosUsuarios(String typeUser){
    return  Text(typeUser,
      style: TextStyle(
          color: Colors.black
      ),
    );
  }

/*  void goToLoginPage(BuildContext context){

    Navigator.pushNamed(context, 'login');
  }*/
}
