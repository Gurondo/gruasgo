import 'package:flutter/material.dart';
import 'package:gruasgo/src/widgets/button_app.dart';

// Un diseño facil para cuando finaliza el pedido y el conductor puede ver el detalle, valorar al usuario.

class ConductorFinalizacion extends StatelessWidget {
  const ConductorFinalizacion({ Key? key }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(3000, 600),
                  bottomRight: Radius.elliptical(3000, 600)
                )
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(
                      Icons.check_circle, size: 100,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text('Tu viaje ha finalizado'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Text('Valor del viaje'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text('5.0 Bs.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
                  ),
        
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.pin_drop),
              title: Text('Desde', style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text('Lugar x'),
            ),
            const ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('Hasta', style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text('Lugar y'),
            ),
            Text('Califica a tu cliente'.toUpperCase(), style: TextStyle(color: Colors.blue[600]),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: (){}, 
                  icon: const Icon(Icons.star_border, size: 30,)
                ),
                IconButton(
                  onPressed: (){}, 
                  icon: const Icon(Icons.star_border, size: 30)
                ),
                IconButton(
                  onPressed: (){}, 
                  icon: const Icon(Icons.star_border, size: 30)
                ),
                IconButton(
                  onPressed: (){}, 
                  icon: const Icon(Icons.star_border, size: 30)
                ),
                IconButton(
                  onPressed: (){}, 
                  icon: const Icon(Icons.star_border, size: 30)
                ),
              ],
            ),

            Expanded(child: Container()),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: ButtonApp(
                  text: 'Enviar',
                  color: Colors.amber,
                  icons: Icons.navigate_next_rounded,
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}