library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:labcomunica/utils/utils.dart';

///Define os tipos de mensagem
enum TipoMensagem {
  info,
  alerta,
  erroNegocio,
  erroInfra,
  confirm,
}

///Tipos de ícone da mensagem
IconData getMensagemIcon(TipoMensagem tipo) => switch (tipo) {
      TipoMensagem.info => Icons.info,
      TipoMensagem.alerta => Icons.warning_amber_rounded,
      TipoMensagem.erroNegocio => Icons.error,
      TipoMensagem.erroInfra => Icons.cloud_off,
      TipoMensagem.confirm => Icons.question_mark,
    };

///Tipos de cor da mensagem
Color getMensagemColor(TipoMensagem tipo) => switch (tipo) {
      TipoMensagem.info => Colors.blue,
      TipoMensagem.alerta => Colors.amber,
      TipoMensagem.erroNegocio => Colors.red,
      TipoMensagem.erroInfra => Colors.black,
      TipoMensagem.confirm => Colors.black,
    };

///Tipos de título da mensagem
String getMensagemTitle(TipoMensagem tipo) => switch (tipo) {
      TipoMensagem.info => 'Informação',
      TipoMensagem.alerta => 'Atenção',
      TipoMensagem.erroNegocio => 'Erro',
      TipoMensagem.erroInfra => 'Erro do Sistema',
      TipoMensagem.confirm => 'Tem certeza?'
    };

///Widget de diálogo genérico para informar ao usuário status das ações do sistema
// Generic dialog widget
class MensagemDialog extends StatelessWidget {
  final TipoMensagem tipoMensagem;
  final String mensagem;

  const MensagemDialog({
    super.key,
    required this.tipoMensagem,
    required this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    final icon = getMensagemIcon(tipoMensagem);
    final color = getMensagemColor(tipoMensagem);
    final title = getMensagemTitle(tipoMensagem);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                ),
                padding: const EdgeInsets.all(20),
                child: Icon(
                  icon,
                  color: color,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // Description
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              // Close button
              tipoMensagem == TipoMensagem.confirm
                  ? showConfirmButtons(context)
                  : Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          'FECHAR',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostra os botões de confirmação do popup, retornando true se SIM for clicado, false
  /// caso contrário.
  Row showConfirmButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botão "Sim".
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          child: const Text(
            'SIM',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Botão "Não".
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          child: const Text(
            'NÃO',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

String cleanDescription(String desc) {
  var cleanedDesc = desc.replaceFirst('Exception: ', '');
  return utf8.decode(cleanedDesc.codeUnits);
}

Future<bool?> showMensagem(
  BuildContext context,
  String mensagem, {
  TipoMensagem tipo = TipoMensagem.erroNegocio,
}) async {
  return await showDialog<bool?>(
    context: context,
    builder: (context) => MensagemDialog(
      tipoMensagem: tipo,
      mensagem: mensagem,
    ),
  );
}

Future<void> treatResponse(BuildContext context, http.Response response) async {
  if (is2xx(response.statusCode)) return;

  final (tipo, mensagem) = switch (response.statusCode) {
    422 => (TipoMensagem.erroNegocio, 'Erro ao validar informações.'),
    >= 400 && < 500 => (
        TipoMensagem.erroNegocio,
        decodeResponse(response)['detail']
      ),
    _ => (
        TipoMensagem.erroInfra,
        'Erro interno.'
      )
  };
  await showMensagem(context, mensagem, tipo: tipo);
}