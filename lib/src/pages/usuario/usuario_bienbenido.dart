import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;

class UsarioBienbenido extends StatefulWidget {
  const UsarioBienbenido({super.key});

  @override
  State<UsarioBienbenido> createState() => _UsarioBienbenidoState();
}

class _UsarioBienbenidoState extends State<UsarioBienbenido> {
  String selectedServicio = '';
 // var arguments;
  late final List<String> listaElementos;

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
                  _gruaA('assets/img/GruaGancho.png','GRUAS','Grua Gancho','',''),
                  _gruaA('assets/img/GruaPlataforma.png','GRUAS','Grua Plataforma','',''),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _gruaA('assets/img/GruaPluma.png','GRUAS','Grua Pluma','',''),
                  _gruaA('assets/img/GruaGrane.png','GRUAS','Grua Crane 30 Ton','Grua Crane 50 Ton',''),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _gruaA('assets/img/Montacarga.png','MONTA CARGA','Monta Carga 1 Tonelada','Monta Carga 2 Toneladas','Monta Carga 5 Toneladas'),
                  _gruaA('assets/img/Volquetas.png','VOLQUETAS','Volqueta de 5cb','Volqueta de 8cb','Volqueta de 12cb'),
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
                  const Align(
                    alignment: Alignment.centerLeft,
                  child :Text('Selecciona una opcion'),
                  ),
                  ListTile(
                    title: Text(opcion1),
                    onTap: () {
                      setState(() {
                        selectedServicio = opcion1;
                        listaElementos = [servicio, selectedServicio];

                      });
                      // Acción para la opción 1
                      if (selectedServicio.isNotEmpty && servicio.isNotEmpty) {
                        
                        Navigator.of(context).pop(); // Cierra el AlertDialog
                        
                        // Navigator.pushNamed(context, 'UsuarioPedido', arguments: listaElementos);
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'UsuarioPedido', (route) => false,
                            arguments: listaElementos);
                      }
                    },
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 0,
                  ),
                  ListTile(
                    title: Text(opcion2),
                    onTap: () {
                      setState(() {
                        selectedServicio = opcion2;
                        listaElementos = [servicio, selectedServicio];
                      });
                      if (selectedServicio.isNotEmpty && servicio.isNotEmpty) {
                        Navigator.of(context).pop(); // Cierra el AlertDialog
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'UsuarioPedido', (route) => false,
                            arguments: listaElementos);
                      }
                    },
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 0,
                  ),
                  ListTile(
                    title: Text(opcion3),
                    onTap: () {
                      setState(() {
                        selectedServicio = opcion3;
                        listaElementos = [servicio, selectedServicio];
                      });
                      if (selectedServicio.isNotEmpty && servicio.isNotEmpty) {
                        Navigator.of(context).pop(); // Cierra el AlertDialog
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'UsuarioPedido', (route) => false,
                            arguments: listaElementos);
                      }
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
        // TODO: Quitar esto, solo lo puse porque no tenia las imagenes
        child: const SizedBox(
          width: 140,
          height: 120,
        ),
        // child: Image.asset(
        //   imagen,
        //   width: 140,
        //   height: 120,
        // ),
      ),
    );
  }
}

