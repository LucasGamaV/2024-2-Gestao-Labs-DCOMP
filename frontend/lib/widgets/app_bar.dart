import 'package:flutter/material.dart';
import 'package:labcomunica/utils/style.dart';

class LogoBar extends StatefulWidget implements PreferredSizeWidget {
  const LogoBar({super.key});

  @override
  State<LogoBar> createState() => _LogoBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _LogoBarState extends State<LogoBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [corPrimaria, corSecundaria],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
          child: Image.asset(
            'assets/images/dcomp-logo-ufs.png',
            height: 40,
          ),
        ),
      ),
    );
  }
}
