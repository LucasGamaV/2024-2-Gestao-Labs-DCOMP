import 'package:flutter/material.dart';
import 'package:labcomunica/utils/api_service.dart';
import 'package:labcomunica/utils/style.dart';
import 'package:labcomunica/widgets/menu/escape_button_menu.dart';
import 'package:labcomunica/widgets/menu/menu_item.dart';

class MenuDrawer extends StatelessWidget {
  final String currentRoute;

  const MenuDrawer(this.currentRoute, {super.key});


  @override
  Widget build(BuildContext context) {
    final api = getApi(context);
    final perfil = api.perfil;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [corPrimaria, corSecundaria],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
              ),
              child: SizedBox(
                height: 200,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // fecha o drawer
                      Navigator.pushNamed(context, '/perfil'); // redireciona para perfil
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (api.nome != null && api.nome!.isNotEmpty) ...[
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 28,
                            child: Text(
                              api.nome![0].toUpperCase(),
                              style: const TextStyle(fontSize: 26.0, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            api.nome!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/dcomp-logo-ufs.png',
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  MenuItemWidget(
                    caption: 'Home',
                    routeName: '/home',
                    currentRoute: currentRoute,
                    icon: const Icon(Icons.home, color: Colors.white, size: 28),
                  ),
                  const Divider(),
                  if (perfil == Perfil.professor) ...telasProfessor(),
                  if (perfil == Perfil.administrador) ...telasAdministrador(),
                  if (perfil == Perfil.aluno) ...telasAluno(),
                  if (perfil == Perfil.tecnico) ...telasTecnico(context),
                ],
              ),
            ),
            const EscapeButtonMenu(),
          ],
        ),
      ),
    );
  }

  List<Widget> telasProfessor() {
    return [];
  }

  List<Widget> telasTecnico(BuildContext context) {
    return [
      MenuItemWidget(
        caption: 'Listar Computadores',
        routeName: '/listar-computadores',
        currentRoute: currentRoute,
        icon: const Icon(Icons.list_alt_rounded, color: Colors.white, size: 28),
      ),
      Divider(color: Colors.white.withOpacity(0.5)),
    ];
  }

  List<Widget> telasAdministrador() {
    return [];
  }

  List<Widget> telasAluno() {
    return [];
  }
}
