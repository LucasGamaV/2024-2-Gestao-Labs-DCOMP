/// ### Auth
///
/// Auth trata do contexto de login
///
/// #### Conteúdo:
///
/// - `CadFuncionarios`: Tela que permite o cadastro de funcionários, que são dos tipos Técnico e Gestor.
/// - `CadUsuario`: Tela que permite o cadastro de usuários da via.
/// - `Login`: Tela que permite o login de qualquer tipo de usuário.
/// - `PasswordReset`: Tela que permite a recuperação da senha.
/// - `PerfilUsuario`: Contém as informações do usuário.

library auth;

export 'login.dart';
export 'password_reset.dart';
export 'perfil_usuario.dart';