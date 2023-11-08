import 'dart:async';

import 'package:flutter/material.dart';
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

  bool esInicio = true;

  TextEditingController tecOrigen = TextEditingController();


  Completer <GoogleMapController> mapController = Completer();


  
  @override
  void initState() {
    

    super.initState();
  }

  @override
  void dispose() {    
    
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _obtenerDatos(UsuarioPedidoBloc usuarioPedidoBloc) async {
    
    esInicio = false;
    Position position = await getPositionHelpers();
    usuarioPedidoBloc.add(OnSetAddNewMarkets(
      Marker(
        markerId: MarkerId(MarkerIdEnum.origen.toString()),
        position: LatLng(position.latitude, position.longitude)
      )
    ));

    String? sitio = await usuarioPedidoBloc.searchPlaceByCoors(coors: LatLng(position.latitude, position.longitude));
    tecOrigen.text = sitio ?? '';
  }

  @override
  Widget build(BuildContext context) {
    

    final usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);

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
        
        // Widget para bloquear el boton de atras, que viene por defecto en los telefono
        body: WillPopScope(
          onWillPop: () => Future(() => false),

          child: SingleChildScrollView(
            
            child: (esInicio) ? 
            FutureBuilder(
              future: _obtenerDatos(usuarioPedidoBloc), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Align(
                    alignment: Alignment.center,
                    child: Text('Cargando')
                  );
                }
                return FormWidget(
                  tecOrigen: tecOrigen,
                  usuarioPedidoBloc: usuarioPedidoBloc,
                );

              },
            ) : 
          
          FormWidget(
            tecOrigen: tecOrigen,
            usuarioPedidoBloc: usuarioPedidoBloc,
          )
          // TODO: Hawstya aqui
          ),
        )
    );
  }





}


class FormWidget extends StatefulWidget {
  const FormWidget({ 
    Key? key, 
    required this.tecOrigen,
    required this.usuarioPedidoBloc
  }) : super(key: key);
  final TextEditingController tecOrigen;
  final UsuarioPedidoBloc usuarioPedidoBloc;
  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {

  final _formKey = GlobalKey<FormState>();

  static List<String> listaDetallePedido = <String>['RIPIO', 'ARENILLA', 'ARENA FINA', 'RELLENO'];
  static List<String> listaPorHora = <String>['Grua Pluma', 'Grua Crane 30 Ton', 'Grua Crane 50 Ton', 'Monta Carga 1 Tonelada', 'Monta Carga 2 Tonelada', 'Monta Carga 5 Tonelada',];
  String detalleServicio = listaDetallePedido.first;

  TextEditingController tecDestino = TextEditingController();
  TextEditingController tecNroContrato = TextEditingController();
  TextEditingController tecDescripcion = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    final List<String> listaRecibida = ModalRoute.of(context)!.settings.arguments as  List<String>;
    final userBloc = BlocProvider.of<UserBloc>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 10),

          Container(
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
          ),

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
                            widget.tecOrigen.text = '';
                            widget.usuarioPedidoBloc.add(OnDeleteMarkerById(MarkerIdEnum.origen));
                          }, 
                          icon: const Icon(Icons.cancel_outlined)
                        ),
                        textEditingController: widget.tecOrigen,
                        usuarioPedidoBloc: widget.usuarioPedidoBloc,
                        labelText: 'Lugar de origen',

                        suggestionsCallback: (String pattern) { 
                          return widget.usuarioPedidoBloc.searchPlace(place: pattern);
                        }, 
                        
                        onSuggestionSelected: (suggestion) {
                          widget.tecOrigen.text = suggestion.toString();
                          PositionModel? position;
                          for (var element in widget.usuarioPedidoBloc.placeModel) {
                            if (element.name == suggestion.toString()){
                              if (element.position != null){
                                position = element.position!;
                              }
                            }
                          }
                          if (position != null){
                            widget.usuarioPedidoBloc.add(OnSetAddNewMarkets(
                              Marker(
                                markerId: MarkerId(MarkerIdEnum.origen.toString()),
                                position: LatLng(position.lat, position.lng)
                              )
                            ));
                          }


                        }, 

                        validator: (value) {
                          if (value == null || value.trim().isEmpty){
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },


                        onPressIcon: () async {
                          

                          userBloc.add(OnSetIsClicPin(false));

                          Marker? marker = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);

                          if (marker != null) {
                            userBloc.add(OnSetIsClicPin(true));
                          } else {

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

                          Navigator.pushNamed(context, 'SelectMapUser', arguments: widget.tecOrigen);
                          
                        },
                      ),

                      TextFormFieldMapWidget(
                        suffixIcon: IconButton(
                          onPressed: (){
                            tecDestino.text = '';
                            widget.usuarioPedidoBloc.add(OnDeleteMarkerById(MarkerIdEnum.destino));
                          }, 
                          icon: const Icon(Icons.cancel_outlined)
                        ),
                        onSuggestionSelected: (suggestion) {
                          tecDestino.text = suggestion.toString();

                          PositionModel? position;
                          for (var element in widget.usuarioPedidoBloc.placeModel) {
                            if (element.name == suggestion.toString()){
                              if (element.position != null){
                                position = element.position!;
                              }
                            }
                          }
                          
                          if (position != null){
                            widget.usuarioPedidoBloc.add(OnSetAddNewMarkets(
                              Marker(
                                markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                position: LatLng(position.lat, position.lng)
                              )
                            ));
                          }


                        }, 
                        textEditingController: tecDestino,
                        usuarioPedidoBloc: widget.usuarioPedidoBloc,
                        labelText: 'Lugar de destino',
                        suggestionsCallback: (String pattern) { 
                          return widget.usuarioPedidoBloc.searchPlace(place: pattern);
                        }, 
                        validator: (value) {
                          if (value == null || value.trim().isEmpty){
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },

                        onPressIcon: () async {

                          Marker? marker = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);
                          Marker? origen = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.destino);
                          userBloc.add(OnSetIsClicPin(false));

                          if (marker != null){
                            userBloc.add(OnSetIsClicPin(true));
                          }else{
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
                        },
                      ),
                    ],
                  );
                },
              )
      
            ],
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: TextFormFieldWidget(
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
          ),
          
          (listaRecibida[0] == 'VOLQUETAS') ? 
            DropButtonWidget(
              label: 'Seleccione el tipo de carga',
              value: detalleServicio, 
              listDropdownMenu: listaDetallePedido,
              onChanged: (String? value){
                if (value != null){
                  detalleServicio = value;
                  setState(() {
                  });
                }
              },
              // EN caso contrario, es un Input normal y corriente para describir cosas de la carga
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
          (!isLoading) ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

            child: ButtonApp(
              text: 'Cotizar Pedido',
              color: Colors.amber,
              textColor: Colors.black,
              onPressed: () async {
                
                setState(() {
                  isLoading = true;
                });
                
                if (listaRecibida[0] == 'VOLQUETAS'){
                  tecDescripcion.text = detalleServicio;
                } 

                if (_formKey.currentState!.validate()) {
                  
                  String? precio;
                  bool porHora = false;

                  if (listaPorHora.contains(listaRecibida[1])){
                    precio = await widget.usuarioPedidoBloc.calcularPrecioPorHora(servicio: listaRecibida[1]);
                    porHora = true;
                  }else{
                    final servicio = (listaRecibida[0] == 'VOLQUETAS') ? '${listaRecibida[1]} $detalleServicio' : listaRecibida[1];
                    precio = await widget.usuarioPedidoBloc.calcularPrecioDistancia(servicio: servicio);
                  }


                  if (!mounted) return null;

                  if (precio != null){
                    showDialogPrecio(context, porHora, precio, listaRecibida, userBloc);
                  }else{
                    showAboutDialog(
                      context: context, 
                      applicationName: 'Error',
                      applicationVersion: 'No existe un registros con los datos ingresados',
                    );
                  }

                }

                setState(() {
                  isLoading = false;
                });

              },

            ),
          
          ) : Container(
            margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

            child: ButtonApp(
              text: 'Cargando',
              color: Colors.amber[200],
              textColor: Colors.black,

            ),
          ),
        ],
      ),
    );
}

  Future<dynamic> showDialogPrecio(BuildContext context, bool porHora, String? precio, List<String> listaRecibida, UserBloc userBloc) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(

        title: Text( (!porHora) ? 'EL COSTO DEL SERVICIO SERA' : '¿EL COSTO DEL SERVICIO SERA DE?'),
        // Diseño del modas
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/img/money.jpg',
              width: 60,
              height: 60,),
            Text(
              // Visualizacion del precio
              'Bs ${precio.toString()}',
              style: const TextStyle(
                fontSize: 30, // Tamaño de la fuente, ajusta el valor según lo que necesites
                color: Colors.red, // Color del texto, puedes cambiarlo a otro color
                fontWeight: FontWeight.bold, // Opcional: Puedes agregar negrita u otras propiedades de fuente
              ),
            ),

            (porHora) ?
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('POR HORA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                ],
              )
            ) : Container()
          ],
        ),
        actions: <Widget>[

          // Cuando preciona el boton "ACEPTAR"
          TextButton(
            onPressed: () async {
              
              final navigator = Navigator.of(context);

              final servicio = (listaRecibida[0] == 'VOLQUETAS') ? '${listaRecibida[1]} $detalleServicio' : listaRecibida[1];

              Marker? origen = getMarkerHelper(markers: widget.usuarioPedidoBloc.state.markers, id: MarkerIdEnum.origen);
              Marker? destino = getMarkerHelper(markers: widget.usuarioPedidoBloc.state.markers, id: MarkerIdEnum.destino);

              if (!(origen == null || destino == null)){

                final status = widget.usuarioPedidoBloc.guardarPedido(
                  idUsuario: userBloc.user!.idUsuario,
                  ubiInicial: widget.tecOrigen.text.trim(),  
                  ubiFinal: tecDestino.text.trim(),  
                  metodoPago: 'QR',  
                  monto: (listaPorHora.contains(listaRecibida[1])) ? '0' : precio ?? '', 
                  servicio: servicio, 
                  descripcionDescarga: tecDescripcion.text.trim(), 
                  celentrega: int.parse(tecNroContrato.text.trim()),
                  origen: origen,
                  destino: destino
                );

                widget.usuarioPedidoBloc.sendEventDistanciaDuracion(origen: origen.position, destino: destino.position);

                final polyline = await widget.usuarioPedidoBloc.getPolylines(origen: origen.position, destino: destino.position);
                  if (polyline != null){
                    widget.usuarioPedidoBloc.add(OnSetAddNewPolylines(
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
      ),
    );
  }
}