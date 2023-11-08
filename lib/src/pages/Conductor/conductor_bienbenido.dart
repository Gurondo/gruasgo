

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruasgo/src/bloc/conductor/conductor_bloc.dart';
import 'package:gruasgo/src/helpers/helpers.dart';

import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';

class ConductorBienbenido extends StatefulWidget {
  const ConductorBienbenido({ Key? key }) : super(key: key);

  @override
  State<ConductorBienbenido> createState() => _ConductorBienvenidaState();
}

class _ConductorBienvenidaState extends State<ConductorBienbenido> {


  // Bandera para controlar el estado de esta app, si esta cargando, el boton se bloquea mostrando un mensaje de cargando,, para evitar que el conductor 
  // haga muchas veces click al boton realizando muchas peticiones al servidor
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {

    final conductorBloc = BlocProvider.of<ConductorBloc>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
          //title: Text('Mi Aplicación'),
          actions: [
            //leading:
            IconButton(
              icon: const Icon(Icons.exit_to_app_sharp), // Icono cerrar sesion
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
        body: Center(
          child: FutureBuilder<bool>(
            future: conductorBloc.buscarEstado(),
            builder: (context, snapshot) {
              
              if (!snapshot.hasData) return const Text('Cargando');
              if (!snapshot.data!) return const Text('Error');

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 40),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Bienvenido Conductor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _imagen(),

                    )
                  ),
                  (!_isLoading) ? Container(
                    height: 50,
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(right: 60, left: 60, bottom: 20),
                    child: ButtonApp(
                      text: 'Conectarse'.toUpperCase(),
                      color: Colors.amber,
                      textColor: Colors.black,
                      onPressed: () async {
                          
                          setState(() {   
                            _isLoading = true;
                          });
                          final navigator = Navigator.of(context);
                          final position = await getPositionHelpers();
                          
                          final status = await conductorBloc.crearEstado();

                          // enviar la lat y lng del conductor que esta ahora mismo
                          if (status){
                            conductorBloc.openSocket(
                              lat: position.latitude, 
                              lng: position.longitude
                            );

                            await navigator.pushNamed('MapaConductor');

                            setState(() {
                              _isLoading = false;
                            });
                          }else{
                            setState(() {
                              _isLoading = false;
                            });
                            // TODO: Mensaje de error
                          }
                       
                        },
                    ),
                  ) : Container(
                    height: 50,
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(right: 60, left: 60, bottom: 20),
                    child: ButtonApp(
                      text: 'Conectandose...'.toUpperCase(),
                      color: Colors.amber[200],
                      textColor: Colors.black,
                      onPressed: (){

                      },
                    ),
                  )
                ],
              );

            },
          ),
        ),
      )
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
}