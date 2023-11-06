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

  // Para el formulario.
  final _formKey = GlobalKey<FormState>();

  // Lista para el detalle del pedido
  static List<String> listaDetallePedido = <String>['RIPIO', 'ARENILLA', 'ARENA FINA', 'RELLENO'];

  // Todas las opciones que se deben mostrar por Hora en el formulario
  static List<String> listaPorHora = <String>['Grua Pluma', 'Grua Crane 30 Ton', 'Grua Crane 50 Ton', 'Monta Carga 1 Tonelada', 'Monta Carga 2 Tonelada', 'Monta Carga 5 Tonelada',];

  // Controlador para controlar el campo de texto
  TextEditingController tecOrigen = TextEditingController();
  TextEditingController tecDestino = TextEditingController();
  TextEditingController tecNroContrato = TextEditingController();
  TextEditingController tecDescripcion = TextEditingController();

  // Variable para tener el valor seleccionado por el combo box, que aparece en el caso de VOLQUETAS
  String detalleServicio = listaDetallePedido.first;

  // Controlador para google map
  Completer <GoogleMapController> mapController = Completer();

  // Para manejar el estado del evento, si se esta enviando la informacion o no, esto es importante para cuando
  // el usuario haga click al boton para x accion, el boton llege al estado de TRUE, donde el boton se bloquea y muestra
  // un mensaje de CARGANDO, para asi dar entender que la aplicacion esta realizando la accion, y asi evitar que el usuario
  // piense que la app se a colgado, y se pueda evitar que el usuario presione muchas veces el boton
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {    
    
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    // Para obtener los argumentos mandados desde la bienvenida
    final List<String> listaRecibida = ModalRoute.of(context)!.settings.arguments as  List<String>;

    // Declarar estas variables, donde puedo acceder a los metodos como tambien, realizar una llamada a los eventos
    // para cambiar el valor de un estado, esta es importante ya que, asi se evita usar el setState, y solo
    // redibuje el widget especifico 
    final usuarioPedidoBloc = BlocProvider.of<UsuarioPedidoBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);


    return Scaffold(
        // Diseño del AppBar
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
          // Agregar un buton con un icono, donde al hacer click me redirecciones a la ventana de bienvenida para el usuario
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

          // Para hacer un scroll, ya que cuando el usuario selecciona un input, se deplega un teclado, y ese teclado va
          // a ocupar un alto de la pantalla
          child: SingleChildScrollView(
                
                // Widget para crear un formulario, este widget me da toda las herramientas para crear un
                // formulario completo, con sus validaciones
                child: Form(

                  // la key del formulario
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Aqui solo muestra el titulo "Detalle del pedido"
                      _textDetallePedido(),

                      Column(
                        children: [
                          
                          // Aqui se usa el primer Bloc, lo que quiere decir esta parte es lo siguiente
                          // Cualquier minimo cambio de un estado del UsuarioPedidoBloc, todos los widget que estan
                          // dentro del BLocBuilder se van a redibujar, eso quiere decir, los Widget que estan atras no
                          // se vuelven a redibujar, aqui se envia como parametro, a que BLoc esta haciendo referencia
                          // para acceder a sus estados, en la variable state se encuentra los estados de este bloc
                          BlocBuilder<UsuarioPedidoBloc, UsuarioPedidoState>(
                            builder: (context, state) {
        
                              return Column(
                                children: [

                                  // Primer campo, para poder visualizar el Detalle del servicio, donde el usuario
                                  // no puede editar, esto es simplemente para visualizar
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

                                  // Campo para Lugar de Origen, este Widget se encuentra en la carpeta 
                                  // 'src/widgets/text_form_field_map.dart', aqui esta todo
                                  // Pero para evitar llamar uno por uno de estos Widget, hay un archivo dentro de este llamado
                                  // widget.dart, donde aqui estan todos los widget dentro de esta carpeta Widgets, esto lo hago asi
                                  // para evitar importar uno por uno, con solo importar 'src/widgets/widget.dart', ya todos los widgets de esa carpeta
                                  // se pueden usar sin importarlos

                                  // Este Widget, usa un Widget de la libreria 'TypeAheadFormField', este Widget es una ayuda para
                                  // poder visualizar opciones mediante el usuario escriba un texto, como si fuera un combo box pero
                                  // editable.
                                  TextFormFieldMapWidget(

                                    // Unos de los principales parametros es enviar el boton de "x", este boton sirve. a la hora de hacer
                                    // click ahi, este boton va a borrar todo el texto dentro de este input, como tambien
                                    // borrar el market seleccionado por el usuario
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        tecOrigen.text = '';
                                        // aqui se llama al primer evento de la aplicacion, solo llamando al usuarioPedidoBloc que es
                                        // el nombre que declaramos al principio que apunta a UsuarioPedidoBLoc, para que Bloc pueda detectar los
                                        // cambios, se tiene que ejecutar con un eveto, en este caso seria el 'add' que tiene lo siguiente
                                        
                                        // nombreBLoc.add( nombreEvento ( parametros ))

                                        // con esto, cuando se llama a este evento, pues el valor de este estado cambia, en este caso
                                        // estamos llamando al evento de, EliminarMarkerPorId, donde basicamente busca el Marker con ese
                                        // Id y lo elimina, despues estos cambios se visualizara en el mapa, que ya no hay un marker
                                        usuarioPedidoBloc.add(OnDeleteMarkerById(MarkerIdEnum.origen));
                                      }, 
                                      icon: const Icon(Icons.cancel_outlined)
                                    ),
                                    textEditingController: tecOrigen,
                                    usuarioPedidoBloc: usuarioPedidoBloc,
                                    labelText: 'Lugar de origen',

                                    // Estas son las sugerencias que aparecen, ya todo esta configurado en el Widget que he creado
                                    // llamando la funcion donde consulto para obtener todos los posibles lugares cuando el usuario empiece
                                    // a escribir en el input, y claramente el usuario pueda seleccionarlo
                                    suggestionsCallback: (String pattern) { 
                                      return usuarioPedidoBloc.searchPlace(place: pattern);
                                    }, 
                                    
                                    // Al seleccionar una sugerencia, se va a visualizar, cambiando el valor del controlador 
                                    onSuggestionSelected: (suggestion) {
                                      tecOrigen.text = suggestion.toString();
                                      // _usuarioPedidoBloc.add(OnSelected(suggestion.toString(), type));

                                      // Despues de que seleccione, almaceno toda la informacion seleccionado por el usuario
                                      // para que, haga una busqueda, ya que Google Map, cuando envio un lugar
                                      // me suele mandar muchos datos, como el nombre, y la posicion
                                      // y es la posicion que se requiere para poder dibujar en el mapa, y tenerlo guardado
                                      // para poder almacenar en la base de datos, la posicion es por lat lng
                                      PositionModel? position;
                                      for (var element in usuarioPedidoBloc.placeModel) {
                                        if (element.name == suggestion.toString()){
                                          if (element.position != null){
                                            position = element.position!;
                                          }
                                        }
                                      }
                                      // si me dio una posicion que no es nula, pues ejecuta un evento ya programado
                                      // donde la logica del evento, es simplemente agregar un nuevo marker a la lista de
                                      // markers para poder mostrar en el mapa, este evento detecta, si enviamos un marker
                                      // con un id que coincide con otro marker ya guardado, ya que es un Set, no una List
                                      // lo que hace es eliminar ese Marker, y reemplazarlo por el nuevo, con las nuevas coordenadas
                                      if (position != null){
                                        usuarioPedidoBloc.add(OnSetAddNewMarkets(
                                          Marker(
                                            markerId: MarkerId(MarkerIdEnum.origen.toString()),
                                            position: LatLng(position.lat, position.lng)
                                          )
                                        ));
                                      }
        
        
                                    }, 

                                    // Para validar el campo, si el usuario ingresa el boton de Cotizar, primero verifica
                                    // si este campo esta vacio como muestra la logica, si lo esta muestra el siguiente 
                                    // mensaje
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty){
                                        return 'Este campo es obligatorio';
                                      }
                                      return null;
                                    },


                                    // Esto es para el icono que se encuentra en la parte derecha del input
                                    // donde el usuario al hacer click, se va a visualizar el mapa, donde este debe
                                    // seleccionarlo
                                    onPressIcon: () async {
                                      

                                      // Esta logica lo que hace, es definir el marcador principal para apuntar con la
                                      // camara, a la hora de visualizar el mapa, primero verifica, si hay un marker
                                      // con el id de origen, que es un ENUM para poder tener un mejor control
                                      // pues retorna ese marker

                                      // Aqui primero, llama un evento para poner falso a una bandera como false, esto es mas
                                      // para evitar confundir al usuario, para ver el pin si selecciona, o no ver nada de pin
                                      // si no selecciona el mapa.
                                      userBloc.add(OnSetIsClicPin(false));

                                      // uso un helpers, que es un codigo de ayuda, para poder realizar una busqueda del marker
                                      // si le mando la lista de markers, pero es un Set para evitar valores repetidos
                                      // y tambien mando el id del marker que quiero regresar
                                      // me puede devolver null, si me devuelve null, entonces significa que el usuario no
                                      // a seleccionado nada en el mapa, o no a seleccionado una opcion en el input
                                      Marker? marker = getMarkerHelper(markers: state.markers, id: MarkerIdEnum.origen);

                                      // si el marker no esta nulo, pues se cambia el estado de esta bandera a true, para 
                                      // significar que el usuario ya a seleccionado una posicion en el mapa, o a seleccionado
                                      // una opcion en el input
                                      if (marker != null) {
                                        userBloc.add(OnSetIsClicPin(true));
                                      } else {

                                        // En el caso contrario, si el marker es nulo, entonces se obtiene la posicion del
                                        // usuario con este helpers, que basicamente es una logica donde se saca la posicion
                                        // actual del usuario, y se le asigna a este marker, para hacer notar que
                                        // el usuario no a seleccionado nada. y el mapa se centre en su ubicacion actual

                                        Position position = await getPositionHelpers();
                                        marker = Marker(
                                          markerId: MarkerId(MarkerIdEnum.origen.toString()),
                                            position: LatLng(
                                              position.latitude, 
                                              position.longitude
                                            )
                                          );
                                      }
                                      
                                      // cuando todo esta configurado, se envia el evento para agregar el pin en el mapa
                                      // esto es mas un apoyo, para poder visualizar en el mapa.
                                      userBloc.add(OnSetMarker(marker));
                                      if (!context.mounted) return;

                                      // hace un push a esta nueva ventana
                                      Navigator.pushNamed(context, 'SelectMapUser', arguments: tecOrigen);
                                      
                                    },
                                  ),

                                  // la misma logica que el anterior, pero esta vez es para el destino, el input del destino
                                  // con su boton para abrir el mapa, y esta arreglado para comportarse como el destino,
                                  // este es casi identico al primero, es la misma logica, los mismos paso pero para destino
                                  // marcando al marker del destino, y con el texteditingcontroller con el destino
                                  TextFormFieldMapWidget(
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        tecDestino.text = '';
                                        usuarioPedidoBloc.add(OnDeleteMarkerById(MarkerIdEnum.destino));
                                      }, 
                                      icon: const Icon(Icons.cancel_outlined)
                                    ),
                                    onSuggestionSelected: (suggestion) {
                                      tecDestino.text = suggestion.toString();
        
                                      PositionModel? position;
                                      for (var element in usuarioPedidoBloc.placeModel) {
                                        if (element.name == suggestion.toString()){
                                          if (element.position != null){
                                            position = element.position!;
                                          }
                                        }
                                      }
                                      
                                      if (position != null){
                                        usuarioPedidoBloc.add(OnSetAddNewMarkets(
                                          Marker(
                                            markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                            position: LatLng(position.lat, position.lng)
                                          )
                                        ));
                                      }
        
        
                                    }, 
                                    textEditingController: tecDestino,
                                    usuarioPedidoBloc: usuarioPedidoBloc,
                                    labelText: 'Lugar de destino',
                                    suggestionsCallback: (String pattern) { 
                                      return usuarioPedidoBloc.searchPlace(place: pattern);
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
                                      // for (var elementMarker in state.markers) {
                                      //   if (elementMarker.markerId.value == MarkerIdEnum.destino.toString()){
                                      //     marker = elementMarker;
                                      //     userBloc.add(OnSetIsClicPin(true));
                                      //   }
                                      //   if (elementMarker.markerId.value == MarkerIdEnum.origen.toString()){
                                      //     origen = Marker(
                                      //       markerId: MarkerId(MarkerIdEnum.destino.toString()),
                                      //       position: elementMarker.position
                                      //     );
                                      //   }
                                      // }
                                                                          
                                      // if (marker == null) {

                                      // }
        
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

                      // Este es el otro diseño, para mostrar el campo de contactos para la entrega, esta llamando a una clase
                      // de TextFormFieldWIdget, para reutilizar esta clase, la misma logica de antes, esto es para
                      // poder user las mismas propiedades de un Widget que se reutiliza muchas veces
                      // claramente enviando datos como parametros para tener diferentes comportameitn, pero mismos estilos
                      // igual que en anterior, con solo importar el 'widget.dart' ya esta importando todos los
                      // widget de la carpeta 'widgets'

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
                      
                      // condicional, donde verifica que si, la opcion seleccionada por el usuario en vienvenida es
                      // VOLQUETA, se muestra el combo Box, que igual que en anterior, es un Widget reutilizable que se
                      // encuentra en la carpeta widgets
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

                      // El boton para calcular el pedido
                      _btnCalcularPedido(context, usuarioPedidoBloc, userBloc, listaRecibida),
                    ],
                  ),
                ),
              ),
        )
    );
  }


  Widget _btnCalcularPedido(BuildContext context, UsuarioPedidoBloc usuarioPedidoBloc, UserBloc userBloc, List<String> listaRecibida){
    
    // Este boton tiene dos comporamiento, bueno dos estilos por asi decirlo
    // EL primero, si _isLoading = false, significa que el boton se redibujara con normalidad
    // donde el usuario puede seleccionar, ahora si el boton es _isLoading = true, significa que
    // este formulario entra en un estado de CARGANDO, donde el boton se bloqueara y mostrara un mensajae de
    // cargando, para que el usuario pueda ver que la solicitud se esta enviando, y evitar que precione dos o mas veces el boton
    // realizando multiples solicitues con muchas respuesta.
    return (!_isLoading) ? Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

      child: ButtonApp(
        text: 'Cotizar Pedido',
        color: Colors.amber,
        textColor: Colors.black,
        //onPressed: _con.registerUsuario,
        onPressed: () async {
          
          // cuando el boton es precionado, entra en un estado de LOADING
          setState(() {
            _isLoading = true;
          });
          
          // Para verificar  si el usuario selecciono una opcion de VOLQUETAS en la venta de bienvenida, pues
          // el tecDescripcion tendra el valor del detalleServicio, que es la variable donde se guarda los valores
          // del combo box
          if (listaRecibida[0] == 'VOLQUETAS'){
            tecDescripcion.text = detalleServicio;
          } 

          // esto es parte del widget, FORM, donde si todo esta valido, entonces continuara con la ejecutcion
          // caso contrario, analizara cada Input que tiene este Form, y visualizara el mensaje para mostrar en
          // la validacion
          if (_formKey.currentState!.validate()) {
            
            // aqui se asigna variables, 
            // El precio puede cambiar, si la consulta es por hora, pues no se guarda en la base de datos y solo se pone el 0,
            // si la consulta es por km, entonces se guardara en la base de datos
            String? precio;
            // Este es una bandera, para poder controlar que tipo de modal va a mostrar, si es el modal por hora o por km
            bool porHora = false;

            // Aqui es donde se decide a donde cunsultar, para calcular el precio por minuto o por kilometros
            if (listaPorHora.contains(listaRecibida[1])){
              precio = await usuarioPedidoBloc.calcularPrecioPorHora(servicio: listaRecibida[1]);
              porHora = true;
            }else{
              final servicio = (listaRecibida[0] == 'VOLQUETAS') ? '${listaRecibida[1]} $detalleServicio' : listaRecibida[1];
              precio = await usuarioPedidoBloc.calcularPrecioDistancia(servicio: servicio);
            }


            // Esto es por defecto en flutter, ya que, como hay un async, await, cuando se realiza una navegacion, o
            // se visualiza informacion como un modal en la ventana, ya que si esto no esta
            // flutter entrara como un warning, y esto puede generar comportamientos extraños en la app
            if (!mounted) return null;

            // Aqui verifica, si hay un precio, pues muestra el modal, si no lo hay, muestra un mensaje de error
            if (precio != null){
              showDialog(
                context: context,
                builder: (context) => _alertDialogCosto(
                  porHora: porHora,
                  usuarioPedidoBloc: usuarioPedidoBloc,
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

          // Cuando toda la logica de atras se finaliza, entra en un estado no NO LOADING
          setState(() {
            _isLoading = false;
          });

        },

      ),

      // El boton bloqueado cuando la app pasa en el estado de LOADING
    
    ) : Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

      child: ButtonApp(
        text: 'Cargando',
        color: Colors.amber[200],
        textColor: Colors.black,

      ),
    );
  }

  // El titulo del Detalle del Pedido
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


  // El alert del costo
  Widget _alertDialogCosto({
    required String precio, 
    required UsuarioPedidoBloc usuarioPedidoBloc, 
    required UserBloc userBloc, 
    required List<String> listaRecibida,
    required bool porHora
  }) {
    return AlertDialog(

      // Aqui mediante la bandera porHora, decidimos que titulo mostrar
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

          // Si el precio es por Hora, entonces mostrar un texto en rojo que diga POR HORA
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
            
            // Hace un pop al alert
            final navigator = Navigator.of(context);

            // asigna el valor del servicio, para almacenarlo a la db
            final servicio = (listaRecibida[0] == 'VOLQUETAS') ? '${listaRecibida[1]} $detalleServicio' : listaRecibida[1];

            // obtiene el Marker de Origen y Destino, mediante el Helpers
            Marker? origen = getMarkerHelper(markers: usuarioPedidoBloc.state.markers, id: MarkerIdEnum.origen);
            Marker? destino = getMarkerHelper(markers: usuarioPedidoBloc.state.markers, id: MarkerIdEnum.destino);

            // Si el origen y destino es nulo, entonces significa que no ha seleccionado nada en el mapa, o marcado
            // una opcion en el input
            if (!(origen == null || destino == null)){

              // Depsues de todo, se almacena en una variable toda la informacion, para no perderlo,
              // asi cuando se deba registrar, pueda rescatarlo sin problema
              final status = usuarioPedidoBloc.guardarPedido(
                idUsuario: userBloc.user!.idUsuario,
                ubiInicial: tecOrigen.text.trim(),  
                ubiFinal: tecDestino.text.trim(),  
                metodoPago: 'QR',  
                monto: (listaPorHora.contains(listaRecibida[1])) ? '0' : precio, 
                servicio: servicio, 
                descripcionDescarga: tecDescripcion.text.trim(), 
                celentrega: int.parse(tecNroContrato.text.trim()),
                origen: origen,
                destino: destino
              );

              // para poder obtener y enviar el estado de CUANTO TIEMPO, Y LA KILOMETRO, que se saca
              // por los dos puntos, de origen y destino, para asi poder visualizar en el mapa
              // el tiempo y la distancia por KM entre los dos puntos
              usuarioPedidoBloc.sendEventDistanciaDuracion(origen: origen.position, destino: destino.position);

              // Para redibujar por donde debe ir el usuario en el mapa.
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

              // Si todo esta correcto, sigue el siguiente paso, ir a la pagina de "MapaUsuario"
              if (status){
                navigator.pop();
                navigator.pushNamedAndRemoveUntil(
                  'MapaUsuario', 
                  (route) => false);
              
              // En caso de que falle, entonces mostrar un mensaje de error
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

        // EL botton de cancelar, que hace un pop
        TextButton(
          onPressed: () {

            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

}
