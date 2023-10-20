import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('INIT STATE');

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
     // _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    final usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder<Position>(
          future: getPositionHelpers(),
          builder: (context, snapshot) {
            
            if (!snapshot.hasData){

              return const Center(child: Text('Cargando'),);
            
            }else{
              
              usuarioPedidoBloc.add(OnSetOrigen(LatLng(snapshot.data!.latitude, snapshot.data!.longitude)));

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
                                    type: 'origen',
                                    usuarioPedidoBloc: usuarioPedidoBloc,
                                    labelText: 'Lugar de origen',
                                    initPosition: usuarioPedidoBloc.state.origen ?? const LatLng(-17.7875271, -63.1782533),
                                    suggestionsCallback: (String pattern) { 
                                      return usuarioPedidoBloc.searchPlace(place: pattern);
                                    }, 
                                    onChanged: (p0) {
                                      usuarioPedidoBloc.searchPlace(place: p0);
                                    },
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty){
                                        return 'Este campo es obligatorio';
                                      }
                                      return null;
                                    },

                                    onPressIcon: () {
                                      Navigator.pushNamed(context, 'VistaMapaUsuarioPedido', arguments: 'origen');
                                    },
                                  ),

                                  TextFormFieldMapWidget(
                                    textEditingController: tecDestino,
                                    type: 'destino',
                                    usuarioPedidoBloc: usuarioPedidoBloc,
                                    labelText: 'Lugar de destino',
                                    initPosition: usuarioPedidoBloc.state.origen ?? const LatLng(-17.7875271, -63.1782533),
                                    suggestionsCallback: (String pattern) { 
                                      return usuarioPedidoBloc.searchPlace(place: pattern);
                                    }, 
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty){
                                        return 'Este campo es obligatorio';
                                      }
                                      return null;
                                    },

                                    onPressIcon: () {
                                      Navigator.pushNamed(context, 'VistaMapaUsuarioPedido', arguments: 'destino');
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

                      _btnCalcularPedido(context, usuarioPedidoBloc),
                    ],
                  ),
                ),
              );

            }

          }
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


  Widget _alertDialogCosto(double precio) {
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
          onPressed: () {
            // Acción para "Aceptar"
            Navigator.of(context).pop();
            Navigator.pushNamedAndRemoveUntil(context, 'MapaUsuario', (route) => false);
          },
          child: const Text('REALIZAR PEDIDO'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Hacer el pedido aqui
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }


  Widget _btnCalcularPedido(BuildContext context, UsuarioPedidoBloc usuarioPedidoBloc){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

      child: ButtonApp(
        text: 'Cotizar Pedido',
        color: Colors.amber,
        textColor: Colors.black,
        //onPressed: _con.registerUsuario,
        onPressed: () async {
          
          if (_formKey.currentState!.validate()) {
            
            final precio = await usuarioPedidoBloc.calcularDistancia();

            if (!mounted) return null;
            if (precio != null){
              showDialog(
                context: context,
                builder: (context) => _alertDialogCosto(precio),
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