import 'package:flutter/widgets.dart';

class KeyValue extends StatelessWidget {
  final String textKey;
  final dynamic value;

  const KeyValue(this.textKey, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$textKey: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value == null ? 'Não informado' : value.toString()),
      ],
    );
  }
}