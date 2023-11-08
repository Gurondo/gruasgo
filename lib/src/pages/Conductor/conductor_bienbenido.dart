import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';

class ConductorBienbenido extends StatefulWidget {
  const ConductorBienbenido({super.key});

  @override
  State<ConductorBienbenido> createState() => _ConductorBienbenidoState();
}

class _ConductorBienbenidoState extends State<ConductorBienbenido> {
  @override
  Widget build(BuildContext context) {
    // print('METODO BUILD');

    return Scaffold(
      drawer: _drawer(),
      appBar: AppBar(

        backgroundColor: utils.Colors.logoColor,

        title: Container(
          alignment: Alignment.center,
/*          child: Text('ADMINISTRACION',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),),*/
        ),
        actions: [
          //leading:

          IconButton(
            icon: const Icon(Icons.exit_to_app_sharp), // Icono cerrar sesion
            onPressed: () {
              //Navigator.pop(context);
              SystemNavigator.pop();
              // Aquí puedes manejar la acción de abrir el menú o el cajón de navegación
            },
          ),
        ],
      ),

      backgroundColor: Colors.white,

      body:
      WillPopScope(
        onWillPop: (){
          return Future(() => false); //Descativar el boton volver atraz
        },

        child:  SingleChildScrollView(
          child: Column(
            children: [
              _textBienbenido(),
              const SizedBox(height: 100),
              //_textTitulo(),
              _imagen(),
              const SizedBox(height: 5),
              _btnConectarse(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textBienbenido(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        'Bienbenido Conductor',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      ),
    );
  }

  Widget _imagen(){
    return Container(
      // width: 100, // Ancho del primer widget
      // height: 100, // Alto del primer widget
      alignment: Alignment.center,
      //margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 3),
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      //color: Colors.white,
      child:
      Image.asset(
        'assets/img/bienConductor.png',  // Ruta de la imagen en la carpeta de assets
        width: 400,              // Ancho de la imagen
        height: 400,             // Alto de la imagen
      ),
      /*CircleAvatar(
        backgroundImage: AssetImage('assets/img/my_location.png'),
      ),*/
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.amber
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MENU CONDUCTOR',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Historial de carreras'),
            trailing: const Icon(Icons.list),
            // leading: Icon(Icons.cancel),
            onTap: () {
             // Navigator.pushNamedAndRemoveUntil(context, 'RegistroConductor', (route) => true);
            },
          ),
          ListTile(
            title: const Text('Saldo Cuenta'),
            trailing: const Icon(Icons.attach_money),
            // leading: Icon(Icons.cancel),
            onTap: () {
              // Navigator.pushNamedAndRemoveUntil(context, 'RegistroConductor', (route) => true);
            },
          ),
        ],
      ),
    );
  }

  Widget _btnConectarse(){
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

        child: ButtonApp(
          text: 'CONECTARSE',
          color: Colors.amber,
          textColor: Colors.black,
          onPressed: (){
            Navigator.pushNamedAndRemoveUntil(context, 'MapaConductor', (route) => false);
          },
        )
    );
  }
}
