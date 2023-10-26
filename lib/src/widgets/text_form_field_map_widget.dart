
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gruasgo/src/bloc/bloc.dart';

class TextFormFieldMapWidget extends StatelessWidget {

  final String labelText;
  final String? Function(String?)? validator;
  final LatLng initPosition;
  final Function() onPressIcon;
  final Function(String)? onChanged;
  final UsuarioPedidoBloc usuarioPedidoBloc;
  final Future<Iterable<String>> Function(String) suggestionsCallback;
  final String type;
  final TextEditingController textEditingController;

  const TextFormFieldMapWidget({
    super.key,
    this.onChanged,
    required this.labelText,
    required this.initPosition,
    required this.onPressIcon,
    required this.suggestionsCallback,
    required this.usuarioPedidoBloc,
    required this.type,
    required this.textEditingController,
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
            child: TypeAheadFormField(
              
              validator: validator,
              textFieldConfiguration: TextFieldConfiguration(
                controller: textEditingController,
                autofocus: true,
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontStyle: FontStyle.italic
                ),
                decoration: InputDecoration(
                  labelText: labelText,
                  filled: true, // Habilita el llenado de color de fondo
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ) ,
              ),
              onSuggestionSelected: (suggestion) {
                textEditingController.text = suggestion.toString();
                usuarioPedidoBloc.add(OnSelected(suggestion.toString(), type));
              }, 
              itemBuilder: (context, String itemData) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(itemData),
                );
              }, 
              suggestionsCallback: suggestionsCallback, 
            ),
            // child: TextFormField(
            //   initialValue: 'x,y',
            //   // controller: controller,
            //   validator: validator,
            //   onChanged: onChanged,
            //  // controller: _con.monbreapellidoController,
            //   maxLength: 35,
            //   style: const TextStyle(fontSize: 17),
            //   inputFormatters: [
            //     FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
            //   ],
            //   decoration: InputDecoration(
            //     // hintText: 'Correo Electronico',
            //     labelText: labelText,
            //     filled: true, // Habilita el llenado de color de fondo
            //     fillColor: Colors.white,
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ) ,
            // ),
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