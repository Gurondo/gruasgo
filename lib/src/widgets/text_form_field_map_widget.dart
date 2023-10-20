
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TextFormFieldMapWidget extends StatelessWidget {

  final String labelText;
  final String? Function(String?)? validator;
  final LatLng initPosition;
  final Function() onPressIcon;
  final Function(String)? onChanged;

  const TextFormFieldMapWidget({
    super.key,
    this.onChanged,
    required this.labelText,
    required this.initPosition,
    required this.onPressIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70, // ALTO DEL TEXT
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              initialValue: 'x,y',
              // controller: controller,
              validator: validator,
              onChanged: onChanged,
             // controller: _con.monbreapellidoController,
              maxLength: 35,
              style: const TextStyle(fontSize: 17),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
              ],
              decoration: InputDecoration(
                // hintText: 'Correo Electronico',
                labelText: labelText,
                filled: true, // Habilita el llenado de color de fondo
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ) ,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: const Icon(Icons.pin_drop, size: 28, color: Colors.blue,),
              onPressed: onPressIcon
            ),
          )
        ],
        
      ),
    );
  }
}