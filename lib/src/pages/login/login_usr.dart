import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:gruasgo/src/bloc/user/user_bloc.dart';
import 'package:gruasgo/src/pages/login/login_usr_controller.dart';
import 'package:gruasgo/src/widgets/button_app.dart';


class LoginUsr extends StatefulWidget {
  const LoginUsr({super.key});

  @override
  State<LoginUsr> createState() => _LoginUsrState();
}

class _LoginUsrState extends State<LoginUsr> {

 final loginController _con = loginController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('INIT STATE');
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      //print('MEDODO SCHUDELLER');
      _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    // TODO: Aqui agregando este bloc, para que pueda almacenar en un estado el usuario, asi este valor se recupera y no se pierde a lo largo de la app
    final userBloc = BlocProvider.of<UserBloc>(context);

    //print('METODO BUILD');
    return Scaffold(
/*      appBar: AppBar(
        backgroundColor: utils.Colors.logoColor,
      ),*/
        backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            _bannerApp(),
            //_textLogin(),
            const SizedBox(height: 30),
            _txtEmail(),
            _txtPassword(),
            _btnLogin(userBloc),
            _textOlvidaste(),
            _textRegistrarse(),
          ],
        ),
      )
    );
  }

  Widget _txtEmail(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController,
        decoration: InputDecoration(
         // hintText: 'Correo Electronico',
          labelText: 'E-MAIL',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
            ),
          suffixIcon: const Icon(
            Icons.email_outlined,
          )
        ) ,
      ),
    );
  }

  Widget _btnLogin(UserBloc userBloc){
    final BuildContext currentContext = context;
    return Container(
     margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 25),

     child: ButtonApp(
       text: 'Iniciar sesión',
       color: Colors.amber,
       textColor: Colors.black,
       onPressed: () async{
         final user = await _con.login();
         if (user != null) {
           if (user.TipoUsuario == 'usu'){
             String userme = user.nombreusuario;
            //  TODO: Aqui simplemente agregue el usuario al estado
             userBloc.user = user;
             Navigator.pushNamedAndRemoveUntil(currentContext, 'bienbendioUsuario', (route) => false,arguments: userme);
            // TODO: Aqui borrar para que vuelva a redireccionar donde siempre, este es solo para el modo desarrollo
            //  Navigator.pushNamedAndRemoveUntil(currentContext, 'MapaUsuario', (route) => false,arguments: userme);
           }
           if (user.TipoUsuario == 'conduc'){
             userBloc.user = user;
            //  Navigator.pushNamedAndRemoveUntil(currentContext, 'MapaConductor', (route) => false);
             Navigator.pushNamedAndRemoveUntil(currentContext, 'bienbenidoConductor', (route) => false);
           }


          // if (user.nivel == 'admin') {
          // } else if (user.nivel == 'ventas') {
             //String userme = user.username;
             //Navigator.pushReplacementNamed(context, 'bienusr');
            // Navigator.pushNamed(context, 'bienusr');
          // }
         }
       } ,

       //_con.login,
     )
    );
  }

  Widget _txtPassword(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: TextField(
        controller: _con.passwordController,
        obscureText: true,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
            labelText: 'CONTRASEÑA',
            filled: true, // Habilita el llenado de color de fondo
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: const Icon(
              Icons.lock_open_outlined,
            )
        ) ,
      ),
    );
  }

  Widget _textRegistrarse(){
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom:30),
      child: GestureDetector(
        onTap: _con.goToRegistroUsuario,
        child: const Text(
          'Registrarse',
          style: TextStyle(
            color: Colors.black87,
            decoration: TextDecoration.underline, // Aquí aplicamos el subrayado
            decorationColor: Colors.black54, // Color del subrayado
            decorationThickness: 2.0, // Grosor del subrayado
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _textOlvidaste(){
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom:20),
      child: const Text(
        '¿Olvidaste tu Contraseña?',
        style: TextStyle(
          color: Colors.black87,
          decoration: TextDecoration.underline, // Aquí aplicamos el subrayado
          decorationColor: Colors.black54, // Color del subrayado
          decorationThickness: 2.0, // Grosor del subrayado
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _bannerApp (){
    return ClipPath(
      clipper: OvalTopBorderClipper(),
      child: Container(
        color: Colors.white,
        //color: utils.Colors.logoColor,
        height: MediaQuery.of(context).size.height * 0.30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/img/logo_gruas.png',
              width: 270,
              height: 270,
            ),
          ],
        ),
      ),
    );
  }
}
