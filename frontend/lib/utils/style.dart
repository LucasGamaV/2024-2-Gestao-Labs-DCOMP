/// Utilidades de estilo.
library;

import 'package:flutter/material.dart';

const corPrimaria = Color.fromRGBO(22, 132, 223, 1);
const corSecundaria = Colors.white;

Color colorIfSelected(bool selected) => selected ? corPrimaria : Colors.grey;

final tema = ThemeData(
    primaryColor: corPrimaria,
    primarySwatch: Colors.lightGreen,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: corPrimaria,
        foregroundColor: corSecundaria,
        minimumSize: const Size(120, 50),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: corPrimaria,
        foregroundColor: corSecundaria,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: corPrimaria,
      foregroundColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: corPrimaria,
      centerTitle: true,
    ));