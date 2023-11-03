import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';
import 'package:gruasgo/src/enum/marker_id_enum.dart';
import 'package:gruasgo/src/enum/polyline_id_enum.dart';
import 'package:gruasgo/src/models/models/pedido_model.dart';
import 'package:gruasgo/src/models/models/position_model.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/helpers/helpers.dart';
import 'package:gruasgo/src/widgets/widget.dart';


class UsuarioPedido extends StatefulWidget {
  const UsuarioPedido({super.key});

  @override
  State<UsuarioPedido> createState() => _UsuarioPedidoState();
}

class _UsuarioPedidoState extends State<UsuarioPedido> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController tecOrigen = TextEditingController();
  TextEditingController tecDestino = TextEditingController();
  TextEditingController tecNroContrato = TextEditingController();
  TextEditingController tecDescripcion = TextEditingController();

  Completer <GoogleMapController> mapController = Completer();


  late UsuarioPedidoBloc _usuarioPedidoBloc;

  @override
  void initState() {
    super.initState();
    //print('INIT STATE');
    
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
     // _con.init(context);
    });
  }

  @override
  void dispose() {    
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder<Position>(
          future: getPositionHelpers(),
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting){

              return const Center(child: Text('Cargando'),);
            
            }else{
              
              // _usuarioPedidoBloc.add(OnSetOrigen(LatLng(snapshot.data!.latitude, snapshot.data!.longitude)));

              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _textDetallePedido(),

                      Column(
                        children: [


                          BlocBuilder<UsuarioPedidoBloc, UsuarioPedidoState>(
                            builder: (context, state) {

                              return Column(
                                children: [

                                  
                                  TextFormFieldMapWidget(
                                    textEditingController: tecOrigen,
                                    usuarioPedidoBloc: _usuarioPedidoBloc,
                                    labelText: 'Lugar de origen',
                                    // initPosition: _usuarioPedidoBloc.state.origen ?? const LatLng(-17.7875271, -63.1782533),
                                    suggestionsCallback: (String pattern) { 
                                      return _usuarioPedidoBloc.searchPlace(place: pattern);
                                    }, 
                                    onSuggestionSelected: (suggestion) {
                                      tecOrigen.text = suggestion.toString();
                                      // _usuarioPedidoBloc.add(OnSelected(suggestion.toString(), type));

                                      PositionModel? position;
                                      for (var element in _usuarioPedidoBloc.placeModel) {
                                        if (element.name == suggestion.toString()){
                                          if (element.position != null){
                                            position = element.position!;
                                          }
                                        }
                                      }
                                      
                                      if (position != null){
                                        _usuarioPedidoBloc.add(OnSetAddNewMarkets(
                                          Marker(
                                            markerId: MarkerId(MarkerIdEnum.origen.toString()),
                                            position: LatLng(position.lat, position.lng)
                                          )
                                        ));
                                      }


                                    }, 
                                    onChanged: (p0) {
                                      _usuarioPedidoBloc.searchPlace(place: p0);
                                    },
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty){
                                        return 'Este campo es obligatorio';
                                      }
                                      return null;
                                    },

                                    onPressIcon: () {
                                      
                                      final String idMarker = MarkerIdEnum.origen.toString();
                                      Marker? marker;
                                      bool isClickPin = false;
                                      for (var elementMarker in state.markers) {
                                        if (elementMarker.markerId.value == MarkerIdEnum.origen.toString()){
                                          marker = elementMarker;
                                          isClickPin = true;
                                          break;
                                        }
                                      }

                                      marker ??= Marker(
                                          markerId: MarkerId(MarkerIdEnum.origen.toString()),
                                          position: LatLng(
                                            snapshot.data?.latitude ?? -17.7960352, 
                                            snapshot.data?.longitude ?? -63.1867462
                                          )
                                        );



                                      _showModal(context, marker, mapController, idMarker, isClickPin, tecOrigen);

                                    },
                                  ),

                                  TextFormFieldMapWidget(
                                    onSuggestionSelected: (suggestion) {
                                      tecDestino.text = suggestion.toString();
                                      // _usuarioPedidoBloc.add(OnSelected(suggestion.toString(), type));

                                      PositionModel? position;
                                      for (var element in _usuarioPedidoBloc.placeModel) {
                                        if (element.name == suggestion.toString()){
                                          if (element.position != null){
                                            position = element.position!;
                                          }
                                        }
                                      }
                                      
                                      if (position != null){
                                        _usuarioPedidoBloc.add(OnSetAddNewMarkets(
                                          Marker(
                                            markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                            position: LatLng(position.lat, position.lng)
                                          )
                                        ));
                                      }


                                    }, 
                                    textEditingController: tecDestino,
                                    usuarioPedidoBloc: _usuarioPedidoBloc,
                                    labelText: 'Lugar de destino',
                                    suggestionsCallback: (String pattern) { 
                                      return _usuarioPedidoBloc.searchPlace(place: pattern);
                                    }, 
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty){
                                        return 'Este campo es obligatorio';
                                      }
                                      return null;
                                    },

                                    onPressIcon: () {

                                      final String idMarker = MarkerIdEnum.destino.toString();
                                      Marker? marker;
                                      Marker? origen;
                                      bool isClickPin = false;
                                      for (var elementMarker in state.markers) {
                                        if (elementMarker.markerId.value == MarkerIdEnum.destino.toString()){
                                          marker = elementMarker;
                                          isClickPin = true;
                                        }
                                        if (elementMarker.markerId.value == MarkerIdEnum.origen.toString()){
                                          origen = elementMarker;
                                        }
                                      }

                                      if (marker == null) {
                                        if (origen != null){
                                          marker = origen;
                                        }else{
                                          marker ??= Marker(
                                            markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                            position: LatLng(
                                              snapshot.data?.latitude ?? -17.7960352, 
                                              snapshot.data?.longitude ?? -63.1867462
                                            )
                                          );
                                        }
                                      }


                                      _showModal(context, marker, mapController, idMarker, isClickPin, tecDestino);

                                      // Navigator.pushNamed(context, 'VistaMapaUsuarioPedido', arguments: {'type': 'destino', 'controller': tecDestino});
                                    },
                                  ),
                                ],
                              );
                            },
                          )
                  
                        ],
                      ),
                      // Lugar de recogida
 
                  
                      //   const SizedBox(height: 15),
                      TextFormFieldWidget(
                        tecNroContrato: tecNroContrato,
                        label: 'Numero de contacto para entrega',
                        textInputType: TextInputType.number,
                        maxLength: 8,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty){
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                      
                      TextFormFieldWidget(
                        label: 'Descripcion de la carga',
                        tecNroContrato: tecDescripcion,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty){
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                      ),

                      _btnCalcularPedido(context, _usuarioPedidoBloc, userBloc),
                    ],
                  ),
                ),
              );

            }

          }
        )
    );
  }

  Future<dynamic> _showModal(BuildContext context, Marker? marker, Completer<GoogleMapController> mapController, String idMarker, bool isClickPin, TextEditingController tec) {
    return showDialog(context: context, builder: (context) {
      return Scaffold(
        body: Stack(
          children: [
            GoogleMapWidget(
              initPosition: marker!.position,
              googleMapController: mapController,
              onTap: (p0) async {
                final navigator = Navigator.of(context);
                _usuarioPedidoBloc.add(OnSetAddNewMarkets(
                  Marker(
                    markerId: MarkerId(idMarker),
                    position: p0
                  )
                ));
                  final place = await _usuarioPedidoBloc.searchPlaceByCoors(coors: p0);
                if (place!=null){
                  tec.text = place;
                }
                navigator.pop();
              },
              markers: {
                (isClickPin) ? 
                marker :
                const Marker(markerId: MarkerId('none'))
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: const Text('Seleccione un punto en el mapa')
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  height: 50,
                  child: ButtonApp(
                    text: 'Cancelar',
                    color: Colors.amber,
                    textColor: Colors.black,
                    //onPressed: _con.registerUsuario,
                    onPressed: () async {
                      
                      Navigator.pop(context);
                
                    },
                
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },);
  }

  Widget _textDetallePedido(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        'Detalle del Pedido',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }


  Widget _alertDialogCosto(double precio, UsuarioPedidoBloc usuarioPedidoBloc, UserBloc userBloc) {
    return AlertDialog(
      title: const Text('¿EL COSTO DEL SERVICIO SERA DE?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('assets/img/money.jpg',
            width: 70,
            height: 70,),
          Text(
            'Bs ${precio.toString()}',
            style: const TextStyle(
              fontSize: 30, // Tamaño de la fuente, ajusta el valor según lo que necesites
              color: Colors.red, // Color del texto, puedes cambiarlo a otro color
              fontWeight: FontWeight.bold, // Opcional: Puedes agregar negrita u otras propiedades de fuente
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Acción para "Aceptar"

            final navigator = Navigator.of(context);

            final status = await usuarioPedidoBloc.registrarPedido(
              idUsuario: userBloc.user!.idUsuario, 
              ubiInicial: tecOrigen.text.trim(), 
              ubiFinal: tecDestino.text.trim(), 
              metodoPago: 'efectivo', 
              monto: precio, 
              servicio: 'gruas', 
              descripcionDescarga: tecDescripcion.text.trim(), 
              celentrega: int.parse(tecNroContrato.text.trim())
            );

            if (status){
              navigator.pop();
              navigator.pushNamedAndRemoveUntil(
                'MapaUsuario', 
                (route) => false);
              
            }else{
              navigator.pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('No pudo realizarse la solicitud')
              ));
              print('un error');
            }
          },
          child: const Text('REALIZAR PEDIDO'),
        ),
        TextButton(
          onPressed: () {

            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }


  Widget _btnCalcularPedido(BuildContext context, UsuarioPedidoBloc usuarioPedidoBloc, UserBloc userBloc){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

      child: ButtonApp(
        text: 'Cotizar Pedido',
        color: Colors.amber,
        textColor: Colors.black,
        //onPressed: _con.registerUsuario,
        onPressed: () async {
          
          // TODO: Borrar

          _usuarioPedidoBloc.pedidoModel = PedidoModel(
              btip: 'nodsa',
              bidpedido: 'dsadsa',
              bidusuario: '0',
              bubinicial: 'aqui vcerca',
              bubfinal: 'aqui lejos',
              bmetodopago: 'efectivo',
              bmonto: 20.5,
              bservicio: 'gruas',
              bdescarga: 'toyota x',
              bcelentrega: 456789123,
              origen: const LatLng(-17.7922212, -63.1483421),
              destino: const LatLng(-17.7754632, -63.1467689)
            );

            _usuarioPedidoBloc.add(OnSetAddNewMarkets(
              Marker(
                markerId: MarkerId(MarkerIdEnum.destino.toString()),
                position: const LatLng(-17.7754632, -63.1467689)
              )
            ));
            _usuarioPedidoBloc.add(OnSetAddNewMarkets(
              Marker(
                markerId: MarkerId(MarkerIdEnum.origen.toString()),
                position: const LatLng(-17.7922212, -63.1483421)
              )
            ));

            _usuarioPedidoBloc.sendEventDistanciaDuracion(
              origen: const LatLng(-17.7922212, -63.1483421), 
              destino: const LatLng(-17.7754632, -63.1467689)
            );

            _usuarioPedidoBloc.add(OnSetIdConductor(''));

            final polyline = await _usuarioPedidoBloc.getPolylines(origen: const LatLng(-17.7922212, -63.1483421), destino: const LatLng(-17.7754632, -63.1467689));
            if (polyline != null){
              _usuarioPedidoBloc.add(OnSetAddNewPolylines(
                Polyline(
                  polylineId: PolylineId(PolylineIdEnum.origenToDestino.toString()),
                  color: Colors.black,
                  width: 4,
                  points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
                )
              ));
            }



          Navigator.pushNamed(context, 'MapaUsuario');
          

          // if (_formKey.currentState!.validate()) {
            
          //   final precio = await usuarioPedidoBloc.calcularDistancia();

          //   if (!mounted) return null;
          //   if (precio != null){
          //     showDialog(
          //       context: context,
          //       builder: (context) => _alertDialogCosto(precio, usuarioPedidoBloc, userBloc),
          //     );
          //   }else{
          //     showAboutDialog(
          //       context: context, 
          //       applicationName: 'Error',
          //       applicationVersion: 'No existe un registros con los datos ingresados',
          //     );
          //   }

          // }

        },

      ),
    );
  }
}

class TextFormFieldWidget extends StatelessWidget {
  final TextEditingController tecNroContrato;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType textInputType;
  final int maxLength;

  const TextFormFieldWidget({
    super.key,
    this.textInputType = TextInputType.text,
    this.maxLength = 35,
    required this.tecNroContrato,
    required this.label,
    required this.validator
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 233, // Ancho del segundo widget
      //height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      child: TextFormField(
        keyboardType: textInputType,
        // inputFormatters: <TextInputFormatter> [
        //   FilteringTextInputFormatter.digitsOnly,
        // ],
        validator: validator,
        controller: tecNroContrato,
      //  controller: _con.celularController,
        style: const TextStyle(fontSize: 17),
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }
}