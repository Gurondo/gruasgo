import 'package:flutter/material.dart';

class DropButtonWidget extends StatelessWidget {
  const DropButtonWidget({
    super.key,
    required this.detalleServicio,
    required this.listDropdownMenu,
    required this.label,
    required this.onChanged
  });

  final String detalleServicio;
  final String label;
  final List<String> listDropdownMenu;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(label)
          ),
          DropdownButton(
            value: detalleServicio,
            isExpanded: true,
            items: listDropdownMenu.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged
          ),
        ],
      ),
    );
  }
}