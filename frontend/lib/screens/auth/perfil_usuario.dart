import 'package:flutter/material.dart';
import 'package:labcomunica/utils/api_service.dart';
import 'package:labcomunica/utils/mensagem_dialogs.dart';
import 'package:labcomunica/widgets/app_bar.dart';
import 'package:labcomunica/widgets/menu/menu_drawer.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userData = await loadUserData();
    if (mounted) {
      setState(() {
        data = userData;
      });
    }
  }

  Future<Map<String, dynamic>> loadUserData() async {
    final api = getApi(context);
    final response = await api.get('/usuarios/perfil');
    if (response.statusCode != 200) {
      showMensagem(context, 'Erro ao recuperar dados do perfil.');
      Navigator.pop(context);
    }
    return decodeResponse(response);
  }

  @override
  Widget build(BuildContext context) {
    final api = getApi(context);
    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    if (api.token == null) {
      return const Text('Falha interna');
    }

    if (data == null) {
      return Scaffold(
        appBar: const LogoBar(),
        drawer: isLargeScreen ? null : const MenuDrawer('/perfil'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final usuario = data!;
    final perfil = api.perfil;

    return Scaffold(
      appBar: const LogoBar(),
      drawer: isLargeScreen ? null : const MenuDrawer('/perfil'),
      body: Row(
        children: [
          if (isLargeScreen)
            const SizedBox(
              width: 250,
              child: MenuDrawer('/perfil'),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  usuario['usuario']['nome'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  usuario['usuario']['email'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: const Text('Nome'),
                                  subtitle: Text(usuario['usuario']['nome']),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.email_outlined),
                                  title: const Text('Email'),
                                  subtitle: Text(usuario['usuario']['email']),
                                ),
                                const Divider(),
                                if (Perfil.funcionarios.contains(perfil)) ...[
                                  ListTile(
                                    leading: const Icon(Icons.badge),
                                    title: const Text('Matrícula'),
                                    subtitle: Text(usuario['matricula']),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
