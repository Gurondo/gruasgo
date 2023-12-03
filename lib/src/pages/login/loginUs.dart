import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String username = "";
final String url = "http://3.14.79.171/aptra2023/login.php";
final Uri uri = Uri.parse(url);

class login_Usr extends StatefulWidget {
  const login_Usr({super.key});

  @override
  State<login_Usr> createState() => _login_UsrState();
}

class _login_UsrState extends State<login_Usr> {

  TextEditingController controllerUser = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();
  TextEditingController preuba = TextEditingController();

  String mensaje = '';

  Future<List> _login() async {
    final response = await http.post(uri, body: {
      //  colocar mismo nombre del campo de la base datos campo(username)

      "busuario": controllerUser.text,
      "bpassword": controllerPass.text,
    });

    var datauser = json.decode(response.body);

    if (datauser.length == 0) {
      setState(() {
        mensaje = "Login falla usuario o contraseña incorrecta ";
      });
    } else {
      if (datauser[0]['nivel'] == 'admin') {
        // ignore: use_build_context_synchronously
       /////// Navigator.pushReplacementNamed(context, '/powerPage');
      } else if (datauser[0]['nivel'] == 'ventas') {
        // ignore: use_build_context_synchronously

        username = datauser[0]['username'];
        setState(() {
          mensaje = "usuario : $username" ;
        });
        print("esto si funciona");

        //if (mounted) {
        //  Navigator.pushReplacementNamed(context, '/vendedoresPage');
        //}

       ///// Navigator.pushReplacementNamed(context, '/vendedoresPage');
      }

      //setState(() {
      //  username = datauser[0]['username'];
      //});
    }

    return datauser;
  }

  @override
  Widget build(BuildContext context) {
    print('METODO BUILD');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding:false,
      body: Form(
        child: Container(
          decoration: new BoxDecoration(
/*            image: new DecorationImage(
                image: new AssetImage("assets/images/digital.jpg"),
                fit: BoxFit.cover),*/
          ),
          child: Column(
            children: <Widget>[
              new Container(
                padding: EdgeInsets.only(top: 77.0),
                child: new CircleAvatar(
                  backgroundColor: Color(0xF81F7F3),
/*                  child: new Image(
                      width: 135,
                      height: 135,
                      image: new AssetImage("assets/images/avatar7.png")
                  ),*/
                ),
                width: 170.0,
                height: 170.0,
                decoration: BoxDecoration(shape: BoxShape.circle),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 93),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5)
                          ]),
                      child: TextFormField(
                        controller: controllerUser,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            hintText: 'Usuario'),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 50,
                      margin: EdgeInsets.only(top: 32),
                      padding: EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5)
                          ]),
                      child: TextFormField(
                        controller: controllerPass,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.key,
                              color: Colors.black,
                            ),
                            hintText: 'Password'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          right: 32,
                        ),
                        child: Text(
                          'Olvido su Contraseña',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      child: new Text("Ingresar"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue, // Color de fondo del botón
                        onPrimary: Colors.white,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(
                                30.0)), // Color del texto del botón
                      ),
                      onPressed: () {
                        _login();
                        //Navigator.pop(context);
                      },
                    ),
                    Text(
                      mensaje,
                      style: TextStyle(fontSize: 25.0, color: Colors.red),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
