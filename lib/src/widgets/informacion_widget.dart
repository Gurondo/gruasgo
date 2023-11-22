import 'package:flutter/material.dart';

class InformacionWidget extends StatelessWidget {
  
  final IconData icons;
  final String titulo;
  final String descripcion;
  final bool isColumn;

  const InformacionWidget({
    super.key,
    this.isColumn = true,
    required this.icons,
    required this.titulo,
    required this.descripcion
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(icons, color: Colors.black87,),
        ),
        Expanded(
          child: (isColumn) ? 
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(titulo, style: const TextStyle(fontSize: 16),)),
              const SizedBox(height: 3,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(descripcion, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black45),),)
            ],
          ) : 
          Row(
            children: [
              Text(titulo, style: const TextStyle(fontSize: 16),),
              const SizedBox(
                width: 10,
              ),
              Text(descripcion, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue),)
            ],
          )
        )
      ],
    );
  }
}