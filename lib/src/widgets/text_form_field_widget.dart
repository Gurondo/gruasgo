import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 0),
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