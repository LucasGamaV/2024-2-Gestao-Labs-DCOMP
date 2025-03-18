/// ## Utils
///
/// Os **Utils** são os arquivos utilitários reutilizáveis do sistema
///
/// ### Conteúdo principal:
/// - `ApiService`: É onde está concentrado as funções genéricas para lidar com a api.
/// - `MensagemDialogs`: É onde estão as funções de mensagens padrões que dão feedback para o usuário.
/// - `TokenStorage`: É o arquivo que salva, recupera ou deleta um token.
/// - `Validators`: É onde estão as funções de validação de campo
library utils;

import 'package:flutter/material.dart';

export 'api_service.dart';
export 'mensagem_dialogs.dart';
export 'token_storage.dart';
export 'validators.dart';
export 'file_utils.dart';

Map<String, dynamic> getArguments(BuildContext context) {
  final arguments = ModalRoute.of(context)!.settings.arguments;
  if (arguments == null) return {};
  return arguments as Map<String, dynamic>;
}

bool is2xx(int statusCode) {
  return statusCode >= 200 && statusCode < 300;
}