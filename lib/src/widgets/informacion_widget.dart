import 'package:flutter/material.dart';

class InformacionWidget extends StatelessWidget {
  
  final IconData icons;
  final String titulo;
  final String descripcion;

  const InformacionWidget({
    super.key,
    required this.icons,
    required this.titulo,
    required this.descripcion
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Icon(icons, color: Colors.black87,),
        ),
        Expanded(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(titulo, style: const TextStyle(fontSize: 16),)),
              const SizedBox(height: 3,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(descripcion, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black54),),)
            ],
          )
        )
      ],
    );
  }
}