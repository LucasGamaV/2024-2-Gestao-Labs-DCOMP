import 'package:flutter/material.dart';
import 'package:labcomunica/utils/api_service.dart';

class EscapeButtonMenu extends StatelessWidget {
  const EscapeButtonMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        BotaoSair(),
      ],
    );
  }
}

class BotaoSair extends StatelessWidget {
  const BotaoSair({super.key});

  @override
  Widget build(BuildContext context) {
    final api = getApi(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          api.logout();
          goBackTo(context, '/login');
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 22),
        label: const Text(
          'Sair',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
