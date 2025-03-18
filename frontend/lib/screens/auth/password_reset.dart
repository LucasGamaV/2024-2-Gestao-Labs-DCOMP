library;

import 'package:flutter/material.dart';
import 'package:labcomunica/utils/api_service.dart';
import 'package:labcomunica/utils/mensagem_dialogs.dart';
import 'package:labcomunica/utils/validators.dart';

class PasswordResetDialog extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final TextEditingController novaSenhaController = TextEditingController();

  PasswordResetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.info,
                  color: Colors.blue,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'É necessário atualizar sua senha e refazer o login.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: novaSenhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: Icon(Icons.lock),
                        border: UnderlineInputBorder(),
                      ),
                      validator: validateSenha,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(24),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final api = getApi(context);
                    final resp = await api.post('/login/atualizar-senha', {
                      'usuario_id': api.userId,
                      'senha': novaSenhaController.text,
                    });
                    if (resp.statusCode != 200) {
                      final detail = decodeResponse(resp)['detail'];
                      showMensagem(
                        context,
                        'Falha ao resetar a senha. \nDetalhes: $detail',
                      );
                      return;
                    }
                    api.shouldResetPassword = false;
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Atualizar senha',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}