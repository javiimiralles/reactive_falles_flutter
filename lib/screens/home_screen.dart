import 'package:flutter/material.dart';
import 'package:reactive_falles_flutter/themes/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('¡Has iniciado sesión!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
