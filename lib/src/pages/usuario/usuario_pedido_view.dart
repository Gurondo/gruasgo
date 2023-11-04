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
import 'package:gruasgo/src/helpers/get_marker.dart';
import 'package:gruasgo/src/helpers/get_position.dart';
import 'package:gruasgo/src/models/models/position_model.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/widgets/widget.dart';


class UsuarioPedido extends StatefulWidget {
  const UsuarioPedido({super.key});

  @override
  State<UsuarioPedido> createState() => _UsuarioPedidoState();
}

class _UsuarioPedidoState extends State<UsuarioPedido> {

  final _formKey = GlobalKey<FormState>();

  static List<String> listDropdownMenu = <String>['RIPIO', 'ARENILLA', 'ARENA FINA', 'RELLENO'];

  TextEditingController tecOrigen = TextEditingController();
  TextEditingController tecDestino = TextEditingController();
  TextEditingController tecNroContrato = TextEditingController();
  TextEditingController tecDescripcion = TextEditingController();
  String detalleServicio = listDropdownMenu.first;

  Completer <GoogleMapController> mapController = Completer();

  bool _isLoading = false;
  

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

    final List<String> listaRecibida = ModalRoute.of(context)!.settings.arguments as  List<String>;

    print('------------------------');
    print(listaRecibida[1]);
    listaRecibida.forEach((element) {
      print(element);
    });

    _usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);


    return Scaffold(
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
          leading: IconButton(
            onPressed: (){
              Navigator.pushNamedAndRemoveUntil(context, 'bienbendioUsuario', (route) => false);
            }, 
            icon: const Icon(Icons.arrow_back_ios_new_outlined)
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
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

                                  Container(
                                    margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
                                    height: 70, 
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: listaRecibida[1],
                                      style: const TextStyle(fontSize: 17),
                                        decoration: InputDecoration(
                                          labelText: 'Detalle del servicio',
                                          filled: true, // Habilita el llenado de color de fondo
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ) ,
                                    ),
                                  ),

                                TextFormFieldMapWidget(
                                  suffixIcon: IconButton(
                                    onPressed: (){
                                      tecOrigen.text = '';
                                      _usuarioPedidoBloc.add(OnDeleteMarkerById(MarkerIdEnum.origen));
                                    }, 
                                    icon: const Icon(Icons.cancel_outlined)
                                  ),
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

                                  onPressIcon: () async {
                                    
                                    final String idMarker = MarkerIdEnum.origen.toString();
                                    Marker? marker;
                                    userBloc.add(OnSetIsClicPin(false));
                                    bool isClickPin = false;
                                    for (var elementMarker in state.markers) {
                                      if (elementMarker.markerId.value == MarkerIdEnum.origen.toString()){
                                        marker = elementMarker;
                                        userBloc.add(OnSetIsClicPin(true));
                                        isClickPin = true;
                                        break;
                                      }
                                    }

                                    if (marker == null){
                                      Position position = await getPositionHelpers();
                                      marker = Marker(
                                        markerId: MarkerId(MarkerIdEnum.origen.toString()),
                                          position: LatLng(
                                            position.latitude, 
                                            position.longitude
                                          )
                                        );
                                    }
                                    
                                    userBloc.add(OnSetMarker(marker));
                                    if (!context.mounted) return;
                                    Navigator.pushNamed(context, 'SelectMapUser', arguments: tecOrigen);
                                    // if (!context.mounted) return;
                                    // _showModal(context, marker, mapController, idMarker, isClickPin, tecOrigen);

                                  },
                                ),

                                TextFormFieldMapWidget(
                                  suffixIcon: IconButton(
                                    onPressed: (){
                                      tecDestino.text = '';
                                      _usuarioPedidoBloc.add(OnDeleteMarkerById(MarkerIdEnum.destino));
                                    }, 
                                    icon: const Icon(Icons.cancel_outlined)
                                  ),
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

                                  onPressIcon: () async {

                                    final String idMarker = MarkerIdEnum.destino.toString();
                                    Marker? marker;
                                    Marker? origen;
                                    userBloc.add(OnSetIsClicPin(false));
                                    bool isClickPin = false;
                                    for (var elementMarker in state.markers) {
                                      if (elementMarker.markerId.value == MarkerIdEnum.destino.toString()){
                                        marker = elementMarker;
                                        userBloc.add(OnSetIsClicPin(true));
                                        isClickPin = true;
                                      }
                                      if (elementMarker.markerId.value == MarkerIdEnum.origen.toString()){
                                        origen = Marker(
                                          markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                          position: elementMarker.position
                                        );
                                      }
                                    }
                                                                        
                                    if (marker == null) {
                                      if (origen != null){
                                        marker = origen;
                                      }else{

                                        if (marker == null){
                                          Position position = await getPositionHelpers();
                                          marker = Marker(
                                            markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                              position: LatLng(
                                                position.latitude, 
                                                position.longitude
                                              )
                                            );
                                        }
                                      }
                                    }

                                    userBloc.add(OnSetMarker(marker));
                                    if (!context.mounted) return;
                                    Navigator.pushNamed(context, 'SelectMapUser', arguments: tecDestino);
                                    // _showModal(context, marker, mapController, idMarker, isClickPin, tecDestino);

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
                    

                    (listaRecibida[0] == 'VOLQUETAS') ? 
                      DropButtonWidget(
                        label: 'Seleccione el tipo de carga',
                        detalleServicio: detalleServicio, 
                        listDropdownMenu: listDropdownMenu,
                        onChanged: (String? value){
                          if (value != null){
                            detalleServicio = value;
                            setState(() {
                            });
                          }
                        },
                      ) : TextFormFieldWidget(
                      label: 'Descripcion de la carga',
                      tecNroContrato: tecDescripcion,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty){
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),


                    // DropdownMenu<String>(
                      
                    //   width: double.infinity,
                    //   dropdownMenuEntries: listDropdownMenu.map<DropdownMenuEntry<String>>((String value) => DropdownMenuEntry(value: value, label: value)).toList()
                    // ),

                    _btnCalcularPedido(context, _usuarioPedidoBloc, userBloc, listaRecibida),
                  ],
                ),
              ),
            )
    );
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


  Widget _alertDialogCosto({
    required String precio, 
    required UsuarioPedidoBloc usuarioPedidoBloc, 
    required UserBloc userBloc, 
    required List<String> listaRecibida,
    required String title
  }) {
    return AlertDialog(
      title: Text(title.toUpperCase()),
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

            final servicio = (listaRecibida[0] == 'VOLQUETAS') ? '${listaRecibida[1]} $detalleServicio' : listaRecibida[1];

            Marker? origen = getMarkerHelper(markers: usuarioPedidoBloc.state.markers, id: MarkerIdEnum.origen);
            Marker? destino = getMarkerHelper(markers: usuarioPedidoBloc.state.markers, id: MarkerIdEnum.destino);

            if (!(origen == null || destino == null)){
              final status = usuarioPedidoBloc.guardarPedido(
                idUsuario: userBloc.user!.idUsuario,
                ubiInicial: tecOrigen.text.trim(),  
                ubiFinal: tecDestino.text.trim(),  
                metodoPago: 'QR',  
                monto: precio, 
                servicio: servicio, 
                descripcionDescarga: tecDescripcion.text.trim(), 
                celentrega: int.parse(tecNroContrato.text.trim()),
                origen: origen,
                destino: destino
              );

              usuarioPedidoBloc.sendEventDistanciaDuracion(origen: origen.position, destino: destino.position);

              final polyline = await usuarioPedidoBloc.getPolylines(origen: origen.position, destino: destino.position);
                if (polyline != null){
                  usuarioPedidoBloc.add(OnSetAddNewPolylines(
                    Polyline(
                      polylineId: PolylineId(PolylineIdEnum.origenToDestino.toString()),
                      color: Colors.black,
                      width: 4,
                      points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
                    )
                  ));
                }

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
              }
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


  Widget _btnCalcularPedido(BuildContext context, UsuarioPedidoBloc usuarioPedidoBloc, UserBloc userBloc, List<String> listaRecibida){
    return (!_isLoading) ? Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

      child: ButtonApp(
        text: 'Cotizar Pedido',
        color: Colors.amber,
        textColor: Colors.black,
        //onPressed: _con.registerUsuario,
        onPressed: () async {
          
          // TODO: Borrar

          // _usuarioPedidoBloc.pedidoModel = PedidoModel(
          //     btip: 'nodsa',
          //     bidpedido: 'dsadsa',
          //     bidusuario: '0',
          //     bubinicial: 'aqui vcerca',
          //     bubfinal: 'aqui lejos',
          //     bmetodopago: 'efectivo',
          //     bmonto: 20.5,
          //     bservicio: 'gruas',
          //     bdescarga: 'toyota x',
          //     bcelentrega: 456789123,
          //     origen: const LatLng(-17.7922212, -63.1483421),
          //     destino: const LatLng(-17.7754632, -63.1467689)
          //   );

          //   _usuarioPedidoBloc.add(OnSetAddNewMarkets(
          //     Marker(
          //       markerId: MarkerId(MarkerIdEnum.destino.toString()),
          //       position: const LatLng(-17.7754632, -63.1467689)
          //     )
          //   ));
          //   _usuarioPedidoBloc.add(OnSetAddNewMarkets(
          //     Marker(
          //       markerId: MarkerId(MarkerIdEnum.origen.toString()),
          //       position: const LatLng(-17.7922212, -63.1483421)
          //     )
          //   ));

          //   _usuarioPedidoBloc.sendEventDistanciaDuracion(
          //     origen: const LatLng(-17.7922212, -63.1483421), 
          //     destino: const LatLng(-17.7754632, -63.1467689)
          //   );

          //   _usuarioPedidoBloc.add(OnSetIdConductor(''));

          //   final polyline = await _usuarioPedidoBloc.getPolylines(origen: const LatLng(-17.7922212, -63.1483421), destino: const LatLng(-17.7754632, -63.1467689));
          //   if (polyline != null){
          //     _usuarioPedidoBloc.add(OnSetAddNewPolylines(
          //       Polyline(
          //         polylineId: PolylineId(PolylineIdEnum.origenToDestino.toString()),
          //         color: Colors.black,
          //         width: 4,
          //         points: polyline.map((e) => LatLng(e.latitude, e.longitude)).toList()
          //       )
          //     ));
          //   }



          // Navigator.pushNamed(context, 'MapaUsuario');
          
          if (listaRecibida[0] == 'VOLQUETAS'){
            tecDescripcion.text = detalleServicio;
          } 

          if (_formKey.currentState!.validate()) {
            
            String? precio;
            String title = '';

            // Aqui es donde se decide a donde cunsultar, para calcular el precio por minuto o por kilometros
            if ([
              'Grua Pluma', 
              'Grua Crane 30 Ton', 
              'Grua Crane 50 Ton', 
              'Monta Carga 1 Tonelada', 
              'Monta Carga 2 Tonelada', 
              'Monta Carga 5 Tonelada',
            ].contains(listaRecibida[1])){
              precio = await usuarioPedidoBloc.calcularPrecioPorHora(servicio: listaRecibida[1]);
              title = 'el costo del servicio por hora sera: ';
            }else{
              final servicio = (listaRecibida[0] == 'VOLQUETAS') ? '${listaRecibida[1]} $detalleServicio' : listaRecibida[1];
              precio = await usuarioPedidoBloc.calcularPrecioDistancia(servicio: servicio);
              title = '¿El costo del servicio sera de?';
            }

          
            if (!mounted) return null;
            if (precio != null){
              showDialog(
                context: context,
                builder: (context) => _alertDialogCosto(
                  usuarioPedidoBloc: usuarioPedidoBloc,
                  title: title,
                  listaRecibida: listaRecibida,
                  precio: precio ?? '', 
                  userBloc: userBloc,
                ),
              );
            }else{
              showAboutDialog(
                context: context, 
                applicationName: 'Error',
                applicationVersion: 'No existe un registros con los datos ingresados',
              );
            }

          }

        },

      ),
    ) : Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

      child: ButtonApp(
        text: 'Cargando',
        color: Colors.amber[200],
        textColor: Colors.black,

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
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 0),
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