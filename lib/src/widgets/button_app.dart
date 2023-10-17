import 'package:flutter/material.dart';


class ButtonApp extends StatelessWidget {
  //const ButtonApp({super.key});
  Color? color;
  Color? textColor;
  String? text;
  Function? onPressed;

  ButtonApp({
     this.color,
     this.textColor = Colors.black,
     this.onPressed,
     @required this.text
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        onPressed?.call();
      },
      child:
      Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 60,   // TAMAÑO DEL BOTON
              alignment: Alignment.center,
              child: Text(text!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              )
            ),
          ),
/*          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 70,
              child: CircleAvatar(
                child: Icon(Icons.arrow_forward_ios),
                backgroundColor: Colors.white
              ),
            ),
          )*/
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(15),
        )
      ),
    );
  }
}
