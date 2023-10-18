import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;

class UsarioBienbenido extends StatefulWidget {
  const UsarioBienbenido({super.key});

  @override
  State<UsarioBienbenido> createState() => _UsarioBienbenidoState();
}

class _UsarioBienbenidoState extends State<UsarioBienbenido> {

  @override
  Widget build(BuildContext context) {
    // print('METODO BUILD');
    final String username = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: utils.Colors.logoColor,
        //title: Text('Mi Aplicación'),
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
        /*  actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Agrega aquí la lógica para manejar la selección del menú
              if (value == 'opcion1') {
                // Acción para la opción 1 del menú
              } else if (value == 'opcion2') {
                // Acción para la opción 2 del menú
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'opcion1',
                  child: Text('Opción 1'),
                ),
                PopupMenuItem<String>(
                  value: 'opcion2',
                  child: Text('Opción 2'),
                ),
              ];
            },
          ),
        ],*/
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Opción 1'),
              onTap: () {
                // Agrega aquí la lógica para la opción 1 del Drawer
                Navigator.pop(context); // Cierra el Drawer
              },
            ),
            ListTile(
              title: const Text('Opción 2'),
              onTap: () {
                // Agrega aquí la lógica para la opción 2 del Drawer
                Navigator.pop(context); // Cierra el Drawer
              },
            ),
          ],
        ),
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
              const SizedBox(height: 20),
              _textBienbenido(username),
              _textoServicio(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _gruaA('assets/img/gruaA.png','GRUA','Grua Gancho','',''),
                  _gruaA('assets/img/gruaB.png','GRUA','Grua Plancha','',''),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _gruaA('assets/img/gruaC.png','CAMION CON PLUMA','2 Toneladas','5 Toneladas',''),
                  _gruaA('assets/img/gruaD.png','GRUA GRANE ALTO TONELAJE','10 Toneladas','20 Toneladas','50 Toneladas'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _gruaA('assets/img/gruaE.png','MONTA CARGA','1 Tonelada','3 Toneladas',''),
                  _gruaA('assets/img/gruaF.png','VOLQUETAS','3 Cubos','10 Cubos','25 Cubos'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


/*  Widget _btnPedido(){
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 25),

        child: ButtonApp(
          text: 'Nuevo Pedido',
          onPressed: () async{
            // Navigator.pushReplacementNamed(context, 'loginus');
          } ,
          //_con.login,
        )
    );
  }*/

  Widget _textBienbenido(String usuario){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: Text(
        'Bienbenid@ $usuario',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      ),
    );
  }

  Widget _textoServicio(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        '¿Que tipo de Servicio Necesita?',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
    );
  }

  Widget _gruaA(String imagen,String servicio, String opcion1, String opcion2, String opcion3) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(servicio,
              textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                  child :Text('Selecciona una opcion'),
                  ),
                  ListTile(
                    title: Text(opcion1),
                    onTap: () {
                      // Acción para la opción 1
                      Navigator.of(context).pop(); // Cierra el AlertDialog
                      Navigator.pushNamedAndRemoveUntil(context, 'UsuarioPedido', (route) => false);
                    },
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 0,
                  ),
                  ListTile(
                    title: Text(opcion2),
                    onTap: () {
                      // Acción para la opción 2
                      Navigator.of(context).pop(); // Cierra el AlertDialog
                    },
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 0,
                  ),
                  ListTile(
                    title: Text(opcion3),
                    onTap: () {
                      // Acción para la opción 3
                      Navigator.of(context).pop(); // Cierra el AlertDialog
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        width: 140,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
        child: Image.asset(
          imagen,
          width: 140,
          height: 120,
        ),
      ),
    );
  }
}
