library;

import 'package:flutter/material.dart';
import 'package:labcomunica/utils/style.dart';

class FloatingMenuButton extends StatelessWidget {
  const FloatingMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: 16,
      top: 16,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: corPrimaria,
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}