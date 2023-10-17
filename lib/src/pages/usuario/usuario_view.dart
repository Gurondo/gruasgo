import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:gruasgo/src/pages/usuario/usuario_controller.dart';

class usuarioReg extends StatefulWidget {
  const usuarioReg({super.key});

  @override
  State<usuarioReg> createState() => _usuarioRegState();
}

class _usuarioRegState extends State<usuarioReg> {

  final usuarioRegisterController _con = usuarioRegisterController();

  bool _obscureText = true;
 // List<Map> _myJson = [{"id":0,"name":"ventas"},{"id":1,"name":"admin"}];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('INIT STATE');

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
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
              _textRegistrarse(),
              _textCreuna(),
              const SizedBox(height: 15),
              _txtNombreAp(),
              _txtEmail(),
              Row(
                children: <Widget>[
                  _imagenes(),
                 // SizedBox(width: 20), // Espacio entre los dos widgets
                  _txtCelular(),
                ],
              ),
              _txtPassword(),
              _btnCreaCuenta(context),

            ],
          ),
        )
    );
  }

  Widget _textRegistrarse(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        'Registrate',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget _textCreuna(){
    return Container(
      alignment: Alignment.centerLeft,
      //margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10), // MARGENES DEL TEXTO LOGIN
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      child: const Text(
        'Crea una cuenta ahora',
        style: TextStyle(
          color: Colors.black87,
          decorationColor: Colors.black54, // Color del subrayado
          decorationThickness: 2.0, // Grosor del subrayado
          fontSize: 17,
        ),
      ),
    );
  }
  Widget _txtNombreAp(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70, // ALTO DEL TEXT
      child: TextField(
        controller: _con.monbreapellidoController,
        maxLength: 35,
        style: const TextStyle(fontSize: 17),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
        ],
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
            labelText: 'Nombre',
            filled: true, // Habilita el llenado de color de fondo
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
        ) ,
      ),
    );
  }

  Widget _txtEmail(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70,
      child: TextField(
        controller: _con.emailController,
        style: const TextStyle(fontSize: 17),
        maxLength: 30,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
            labelText: 'Correo Electrónico',
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
      width: 233, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 10),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter> [
          FilteringTextInputFormatter.digitsOnly,
        ],
        controller: _con.celularController,
        style: const TextStyle(fontSize: 17),
        maxLength: 8,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Telefono',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtPassword(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70,
      child: TextField(
        controller: _con.passwordController,
        style: const TextStyle(fontSize: 17),
        maxLength: 10,
        obscureText: _obscureText,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Contraseña',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText; // Cambia entre mostrar y ocultar la contraseña
              });
            },
          ),
        ) ,
      ),
    );
  }

  Widget _btnCreaCuenta(BuildContext context){
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

        child: ButtonApp(
          text: 'Crear Cuenta',
          color: Colors.amber,
          textColor: Colors.black,
         onPressed: _con.registerUsuario,
    /*async{
            final user = await _con.login();
            if (user != null) {
              if (user.nivel == 'admin') {
              } else if (user.nivel == 'ventas') {
                String userme = user.username;
                print('esto gustavo $userme');
                //Navigator.pushReplacementNamed(context, 'bienusr');
                Navigator.pushNamed(context, 'bienusr');
              }
            }
          } ,*/

        ),
    );
  }
}
