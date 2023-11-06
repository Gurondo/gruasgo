import 'package:flutter/material.dart';

class DropButtonWidget extends StatelessWidget {
  const DropButtonWidget({
    super.key,
    required this.value,
    required this.listDropdownMenu,
    required this.label,
    required this.onChanged
  });

  final String value;
  final String label;
  final List<String> listDropdownMenu;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              
              borderRadius: BorderRadius.circular(9)
            ),
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: DropdownButton(
              underline: const SizedBox(),
              value: value,
              isExpanded: true,
              items: listDropdownMenu.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(left: 5),
              padding: const EdgeInsets.all(8),
              child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13),)
            )
          ),
        ],
      ),
    );
  }
}