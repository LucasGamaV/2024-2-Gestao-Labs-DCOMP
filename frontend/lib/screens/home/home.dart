import 'package:flutter/material.dart';
import 'package:labcomunica/widgets/app_bar.dart';
import 'package:labcomunica/widgets/menu/menu_drawer.dart';

class HomePage extends StatelessWidget {
  static const String route = '/';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 600;

        if (isLargeScreen) {
          // Layout para telas grandes (menu fixo na lateral)
          return Scaffold(
            appBar: const LogoBar(),
            body: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: const MenuDrawer('home'),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/dcomp-logo-ufs.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Layout para telas pequenas (menu como drawer)
          return Scaffold(
            appBar: const LogoBar(),
            drawer: const MenuDrawer('home'),
            body: Center(
              child: Image.asset(
                'assets/images/dcomp-logo-ufs.png',
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }
}
