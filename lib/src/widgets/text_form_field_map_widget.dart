
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gruasgo/src/bloc/usuario_pedido/usuario_pedido_bloc.dart';

class TextFormFieldMapWidget extends StatelessWidget {

  final String labelText;
  final String? Function(String?)? validator;
  final Function() onPressIcon;
  final UsuarioPedidoBloc usuarioPedidoBloc;
  final Future<Iterable<String>> Function(String) suggestionsCallback;
  final TextEditingController textEditingController;
  final void Function(String) onSuggestionSelected;
  final Widget? suffixIcon;
  final double marginButton;


  const TextFormFieldMapWidget({
    super.key,
    required this.labelText,
    required this.onPressIcon,
    required this.suggestionsCallback,
    required this.usuarioPedidoBloc,
    required this.textEditingController,
    required this.onSuggestionSelected,
    this.suffixIcon,
    this.validator,
    this.marginButton = 10
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: marginButton),
      height: 70, // ALTO DEL TEXT
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TypeAheadFormField(
              minCharsForSuggestions: 1,
              validator: validator,
              textFieldConfiguration: TextFieldConfiguration(

                
                controller: textEditingController,
                autofocus: false,
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontStyle: FontStyle.italic
                ),
                decoration: InputDecoration(
                  suffixIcon: suffixIcon,
                  labelText: labelText,
                  filled: true, // Habilita el llenado de color de fondo
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ) ,
              ),
              onSuggestionSelected: onSuggestionSelected,

              itemBuilder: (context, String itemData) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(itemData),
                );
              }, 
              suggestionsCallback: suggestionsCallback, 
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