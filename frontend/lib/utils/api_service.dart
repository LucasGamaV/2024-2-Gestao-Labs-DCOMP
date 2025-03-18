library;

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labcomunica/screens/auth/auth.dart';
import 'package:labcomunica/screens/home/home.dart';
import 'package:labcomunica/utils/token_storage.dart';
import 'package:flutter/foundation.dart';

enum Perfil {
  administrador,
  professor,
  tecnico,
  aluno;

  factory Perfil.fromString(String perfil) => switch (perfil) {
        'tecnico' => Perfil.tecnico,
        'administrador' => Perfil.administrador,
        'professor' => Perfil.professor,
        'aluno' => Perfil.aluno,
        _ => throw ArgumentError('Perfil inválido: $perfil')
      };

  static const todosPerfis = Perfil.values;
  static const funcionarios = [
    Perfil.administrador,
    Perfil.professor,
    Perfil.tecnico
  ];

  @override
  String toString() => switch (this) {
        Perfil.administrador => 'Administrador',
        Perfil.professor => 'Professor',
        Perfil.tecnico => 'Técnico',
        Perfil.aluno => 'Aluno',
      };
}

/// Concentra configurações de ambiente, como a URL da API.
class EnvironmentConfig {
  static const String devUrl = 'http://localhost:8000';
  static const String webReleaseUrl = '';
  static const String otherReleaseUrl = 'https://labcomunica.com';

  static String get apiUrl {
    if (!kReleaseMode) {
      return devUrl;
    }
    if (kIsWeb) {
      return webReleaseUrl;
    }
    return otherReleaseUrl;
  }
}

/// Decodifica uma resposta obtida via rede, respeitando UTF-8.
/// Importante para preservar nomes com caracteres não-ASCII, como 'Patrícia'.
dynamic decodeResponse(http.Response response) =>
    json.decode(utf8.decode(response.bodyBytes));

/// Responsável por armazenar tokens e prover métodos de contato com a API do LabComunica.
class ApiService with ChangeNotifier {
  String? _token;
  Perfil? _perfil;
  DateTime? _expiration;
  int? _userId;
  int? _idEspecifico;
  String? _email;
  String? _nome;
  final TokenStorage _tokenStorage = TokenStorage();

  Perfil? get perfil => _perfil;
  String? get email => _email;
  int? get userId => _userId;
  int? get idEspecifico => _idEspecifico;
  String? get nome => _nome;
  bool shouldResetPassword = false;
  String? get token {
    if (_expiration != null &&
        _expiration!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  bool checkingExistingToken = false;

  ApiService() {
    _tryExistingToken();
  }

  ApiService.empty();

  /// Test the current token and throws if it's invalid (not accepted by the API).
  Future<void> checkValidToken() async {
    final resp = await post('/login/test-token', {});
    if (resp.statusCode != 200) throw Exception('Invalid token');
  }

  /// Attemps to use an existing token in the device's storage.
  Future<void> _tryExistingToken() async {
    checkingExistingToken = true;
    try {
      final storageToken = await _tokenStorage.getToken();
      updateTokenInfo(storageToken!);
      await checkValidToken();
    } catch (e) {
      logout();
    }
    checkingExistingToken = false;
    notifyListeners();
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('${EnvironmentConfig.apiUrl}/login/access-token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      updateTokenInfo(responseData['access_token'] ?? '');
    }
    return response;
  }

  void updateTokenInfo(String token) {
    _token = token;
    _tokenStorage.saveToken(token);

    final tokenPayload = _parseJwt(token);

    _perfil = Perfil.fromString(tokenPayload['tipo_usuario']);
    _expiration = DateTime.now().add(Duration(minutes: tokenPayload['exp']));
    _userId = tokenPayload['sub'];
    _email = tokenPayload['email'];
    _nome = tokenPayload['nome'];
    _idEspecifico = tokenPayload['id_especifico'];
  }

  void logout() {
    limparCampos();
    _tokenStorage.deleteToken();
    notifyListeners();
  }

  void limparCampos() {
    _perfil = null;
    _email = null;
    _userId = null;
    _idEspecifico = null;
    _nome = null;
    _token = null;
    _expiration = null;
  }

  Uri getUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    var uri = Uri.parse('${EnvironmentConfig.apiUrl}$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFunc, Uri uri,
      {dynamic body}) async {
    try {
      _logRequest(uri, body);
      final response = await requestFunc();
      _logResponse(uri, response);
      return response;
    } catch (e) {
      log('Error during API call to $uri: $e');
      rethrow;
    }
  }

  void _logRequest(Uri uri, dynamic body) {
    log('Request URL: $uri');
    if (body != null) log('Request Body: ${jsonEncode(body)}');
  }

  void _logResponse(Uri uri, http.Response response) {
    log('Response for URL: $uri');
    log('Status Code: ${response.statusCode}');
    log('Response Body: ${response.body}');
  }

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = getUri(path, queryParams: queryParams);
    return _sendRequest(() => http.get(uri, headers: _headers()), uri);
  }

  Future<http.Response> post(
    String path,
    dynamic body, {
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = getUri(path, queryParams: queryParams);
    return _sendRequest(
      () => http.post(uri, headers: _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }

  Future<http.Response> put(
    String path,
    dynamic body, {
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = getUri(path, queryParams: queryParams);
    return _sendRequest(
      () => http.put(uri, headers: _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }

  Future<http.Response> patch(
    String path,
    dynamic body, {
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = getUri(path, queryParams: queryParams);
    return _sendRequest(
      () => http.patch(uri, headers: _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }

  Future<http.Response> delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = getUri(path, queryParams: queryParams);
    return _sendRequest(
      () => http.delete(uri, headers: _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }
}

/// Retorna o ApiService presente no dado context. Não escuta por notificações.
ApiService getApi(BuildContext context) =>
    Provider.of<ApiService>(context, listen: false);

/// Transforma `isso_aqui` em `ISSO AQUI`.
String formatResponseText(String s) => s.toUpperCase().replaceAll('_', ' ');

/// Remove e renomeia valores num Map que representa um json.
/// Em geral, a função remove campos que não fazem sentido de serem mostrados aos usuários finais:
/// - valores null são transformados na string 'Não definido.'.
/// - true/false são transformados em strings 'Sim' e 'Não'.
/// - campos com 'id' são excluídos.
void cleanupJsonAux(dynamic data) {
  if (data is Map) {
    data.removeWhere((key, value) =>
        key.toString().toLowerCase().contains(RegExp(r'\bid\b|_id|id_')));

    data.forEach((key, value) {
      if (value == null) {
        // O type system do Dart acha que dart[key] tem tipo 'num?'.
        // Se não conseguir resolver, remover esse branch e transformar nulls
        // logo antes de mostrar na tela via Text().
        // data[key] = 'Não definido.';
      } else if (value is bool) {
        data[key] = value ? 'Sim' : 'Não';
      } else if (value is Map || value is List) {
        cleanupJsonAux(value);
      }
    });
  } else if (data is List) {
    for (var i = 0; i < data.length; i++) {
      if (data[i] is Map || data[i] is List) {
        cleanupJsonAux(data[i]);
      }
    }
  }
}

Map<String, dynamic> cleanupJson(Map<String, dynamic> data) {
  cleanupJsonAux(data);
  return data;
}

/// Encapsula uma tela que deve ser acessada apenas por certos tipos de usuário.
class AuthGuard extends StatelessWidget {

  static const telasSemAuth = [
    Login,
  ];

  final Widget child;
  final List<Perfil> allowedPerfis;

  const AuthGuard({
    super.key,
    required this.allowedPerfis,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);

    if (api.checkingExistingToken) {
      return const Center(child: CircularProgressIndicator());
    }

    final isAuthenticated = api.token != null;
    if (!isAuthenticated) {
      if (telasSemAuth.contains(child.runtimeType)) return child;

      // Estamos usando Navigator invés de retornar a página de Login pois queremos "popar"
      // todo o stack de navegação.
      goBackTo(context, '/login', postFrame: true);
      return const Center(child: CircularProgressIndicator());
    }

    final perfil = api.perfil;

    if (!allowedPerfis.contains(perfil) || child.runtimeType == Login) {
      return const HomePage();
    }
    return child;
  }
}

/// Limpa o stack do Navigator e pusha routeName..
/// Caso a rota não for de login, pusha a '/home' antes de routeName.
void goBackTo(
  BuildContext context,
  String routeName, {
  bool postFrame = false,
}) {
  final shouldPushHome = !['/login', '/home'].contains(routeName);

  if (postFrame) {
    // Precisamos evitar uma exceção aqui que ocorre com chamadas de Navigator dentro
    // de um método build.
    // Abaixo nós pedimos ao Flutter para voltar a tela de Login após o frame atual
    // ter terminado de desenhar.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _goBackToCallback(context, routeName, shouldPushHome),
    );
    return;
  }
  _goBackToCallback(context, routeName, shouldPushHome);
}

void _goBackToCallback(
  BuildContext context,
  String routeName,
  bool shouldPushHome,
) {
  if (shouldPushHome) {
    Navigator.of(context)
      ..popUntil((_) => false)
      ..pushNamed('/home')
      ..pushNamed(routeName);
    return;
  }
  Navigator.of(context)
    ..popUntil((_) => false)
    ..pushNamed(routeName);
}