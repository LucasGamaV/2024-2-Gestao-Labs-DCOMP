library;

import 'package:flutter/material.dart';
import 'package:labcomunica/utils/style.dart';

Widget bottomBar(String title, IconData icon) {
  return BottomAppBar(
    color: corPrimaria,
    child: Center(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}