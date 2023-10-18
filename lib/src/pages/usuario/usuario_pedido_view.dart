import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';


class UsuarioPedido extends StatefulWidget {
  const UsuarioPedido({super.key});

  @override
  State<UsuarioPedido> createState() => _UsuarioPedidoState();
}

class _UsuarioPedidoState extends State<UsuarioPedido> {

 // final usuarioRegisterController _con = usuarioRegisterController();


  // List<Map> _myJson = [{"id":0,"name":"ventas"},{"id":1,"name":"admin"}];
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
          //title: Text('Mi Aplicación'),
          /*  actions: [
          //leading:
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              // Aquí puedes manejar la acción de abrir el menú o el cajón de navegación
            },
          ),
        ],*/
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _textDetallePedido(),
              _txtdesde(),
           //   const SizedBox(height: 15),
              _txthasta(),
              _txtCelular(),
              _txtDescripcionCarga(),
              _btnCalcularPedido(context),
            ],
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

  Widget _txtdesde(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70, // ALTO DEL TEXT
      child: TextField(
       // controller: _con.monbreapellidoController,
        maxLength: 35,
        style: const TextStyle(fontSize: 17),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
        ],
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Lugar de recogida',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txthasta(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70, // ALTO DEL TEXT
      child: TextField(
        // controller: _con.monbreapellidoController,
        maxLength: 35,
        style: const TextStyle(fontSize: 17),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
        ],
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Lugar de recogida',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtDescripcionCarga (){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70,
      child: TextField(
       // controller: _con.emailController,
        style: const TextStyle(fontSize: 17),
        maxLength: 30,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Descripcion de la carga',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _imagenes(){
    return Container(
/*      width: 100, // Ancho del primer widget
      height: 100, // Alto del primer widget*/
      //margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 3),
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      //color: Colors.white,
      child:
      Image.asset(
        'assets/img/591.png',  // Ruta de la imagen en la carpeta de assets
        width: 80,              // Ancho de la imagen
        height: 80,             // Alto de la imagen
      ),
      /*CircleAvatar(
        backgroundImage: AssetImage('assets/img/my_location.png'),
      ),*/
    );
  }

  Widget _txtCelular(){
    return Container(
      //width: 233, // Ancho del segundo widget
      //height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter> [
          FilteringTextInputFormatter.digitsOnly,
        ],
      //  controller: _con.celularController,
        style: const TextStyle(fontSize: 17),
        maxLength: 8,
        decoration: InputDecoration(
          labelText: 'Numero de contacto para entrega',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _alertDialogCosto() {
    return AlertDialog(
      title: Text('¿EL COSTO DEL SERVICIO SERA DE?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('assets/img/money.jpg',
            width: 70,
            height: 70,),
          Text(
            'Bs 200',
            style: TextStyle(
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
          child: Text('REALIZAR PEDIDO'),
        ),
        TextButton(
          onPressed: () {
            // Acción para "Cancelar"
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
      ],
    );
  }


  Widget _btnCalcularPedido(BuildContext context){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

      child: ButtonApp(
        text: 'Cotizar Pedido',
        color: Colors.amber,
        textColor: Colors.black,
        //onPressed: _con.registerUsuario,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _alertDialogCosto(),
          );
        },

      ),
    );
  }
}
