import 'package:flutter/material.dart';

class NoResultsWarning extends StatelessWidget {
  static const textStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  const NoResultsWarning({
    super.key,
    this.substantivo = 'resultado',
    this.substantivoFeminino = false,
  });

  final String substantivo;
  final bool substantivoFeminino;

  String descriptionText() {
    return substantivoFeminino
        ? 'Nenhuma $substantivo foi encontrada no sistema.'
        : 'Nenhum $substantivo foi encontrado no sistema.';
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 40,
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              const Text(
                'Sem resultados.',
                style: textStyle,
              ),
              Text(
                descriptionText(),
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}