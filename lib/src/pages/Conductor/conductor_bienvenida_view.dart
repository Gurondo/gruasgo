

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/conductor/conductor_bloc.dart';
import 'package:gruasgo/src/helpers/helpers.dart';

import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/google_map_widget.dart';

class ConductorBienvenida extends StatefulWidget {
  const ConductorBienvenida({ Key? key }) : super(key: key);

  @override
  State<ConductorBienvenida> createState() => _ConductorBienvenidaState();
}

class _ConductorBienvenidaState extends State<ConductorBienvenida> {

  Completer <GoogleMapController> _mapController = Completer();



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
                //Navigator.pop(context);
                SystemNavigator.pop();
                // Aquí puedes manejar la acción de abrir el menú o el cajón de navegación
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Bienvenido Conductor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text('Imagen')
              )
            ),
            Container(
              height: 50,
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(right: 60, left: 60, bottom: 20),
              child: ButtonApp(
                text: 'Conectarse'.toUpperCase(),
                color: Colors.amber,
                textColor: Colors.black,
                onPressed: () async {
                    
                    final navigator = Navigator.of(context);
                    final position = await getPositionHelpers();
                    
                    conductorBloc.openSocket(
                      lat: position.latitude, 
                      lng: position.longitude
                    );

                    navigator.pushNamed('MapaConductor');
                  
                  },
              ),
            ),
          ],
        ),
      )
    );
  }
}