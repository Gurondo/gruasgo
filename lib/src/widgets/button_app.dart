import 'package:flutter/material.dart';


class ButtonApp extends StatelessWidget {
  //const ButtonApp({super.key});
  final Color? color;
  final Color? textColor;
  final String text;
  final Function? onPressed;
  final double paddingHorizontal;
  final IconData? icons;

  const ButtonApp({
    super.key, 
    this.color,
    this.paddingHorizontal = 0,
    this.textColor = Colors.black,
    this.onPressed,
    this.icons,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        )
      ),
      child:
      Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 60,   // TAMAÑO DEL BOTON
                alignment: Alignment.center,
                child: (icons != null) ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(360),
                          color: Colors.white,
                        ),
                        child: Icon(icons, color: Colors.black,)
                      )
                    ],
                  ) : 
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
              ),
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
    );
  }
}
