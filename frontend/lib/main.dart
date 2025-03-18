/// # Documentação do LabComunica
///
/// Este projeto tem como objetivo ser um aplicativo web/mobile de gerenciamento e manutenção de computadores dos laboratórios de informática da UFS.
///
/// ## Estrutura do Projeto
///
/// O código está organizado em quatro principais categorias:
/// - **Models:** Modelos de dados.
/// - **Screens:** Telas principais.
/// - **Utils:** Funções auxiliares e utilitários.
/// - **Widgets:** Componentes reutilizáveis.
///
/// Siga as seções abaixo para mais detalhes
library main;

import 'package:flutter/material.dart';
import 'package:labcomunica/screens/computadores/listar_computadores.dart';
import 'package:labcomunica/screens/auth/perfil_usuario.dart';
import 'package:provider/provider.dart';
import 'package:labcomunica/screens/auth/login.dart';
import 'package:labcomunica/screens/home/home.dart';
import 'package:labcomunica/utils/style.dart';
import 'package:labcomunica/utils/utils.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ApiService(),
    child: const RoadMapApp(),
  ));
}

class RoadMapApp extends StatelessWidget {
  const RoadMapApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: 'LabComunica',
        theme: tema,
        home: Consumer<ApiService>(builder: (ctx, auth, _) {
          context.mounted;
          if (auth.checkingExistingToken) {
            return const Center(child: CircularProgressIndicator());
          }
          return auth.token != null ? const HomePage() : const Login();
        }),
        routes: {
          '/login': (context) => const AuthGuard(
                allowedPerfis: Perfil.todosPerfis,
                child: Login(),
              ),
          '/home': (context) => const AuthGuard(
                allowedPerfis: Perfil.todosPerfis,
                child: HomePage(),
              ),
          '/listar-computadores': (context) => const AuthGuard(
                allowedPerfis: Perfil.todosPerfis,
                child: ListarComputadoresPage(),
              ),
          '/perfil': (context) => const AuthGuard(
                allowedPerfis: Perfil.todosPerfis,
                child: PerfilUsuario(),
              ),
        },
      );
  }
}