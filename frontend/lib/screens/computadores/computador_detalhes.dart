library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labcomunica/utils/api_service.dart';
import 'package:labcomunica/widgets/app_bar.dart';
import 'package:labcomunica/widgets/bottom_bar.dart';

class ComputadorDetalhesPage extends StatefulWidget {
  final int computadorId;

  const ComputadorDetalhesPage({super.key, required this.computadorId});

  @override
  State<ComputadorDetalhesPage> createState() => _ComputadorDetalhesPageState();
}

class _ComputadorDetalhesPageState extends State<ComputadorDetalhesPage> {
  Map<String, dynamic>? computador;

  @override
  void initState() {
    super.initState();
    fetchComputador();
  }

  Future<void> fetchComputador() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService
          .get('/computadores/${widget.computadorId}');
      if (response.statusCode == 200) {
        setState(() {
          computador = decodeResponse(response);
        });
      } else {
        throw Exception('Falha ao carregar computador');
      }
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoBar(),
      bottomNavigationBar:
          bottomBar('Detalhar Computador', Icons.computer_outlined),
      backgroundColor: Colors.white,
      body: computador == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.grey[300],
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patrimonio: ${computador!['patrimonio']}'),
                          Text('Marca: ${computador!['marca']}'),
                          Text('Hostname: ${computador!['hostname']}'),
                          Text('Sistema Operacional: ${computador!['sistema_operacional']}'),
                          Text('Última Alteração: ${computador!['data_ultima_alteracao']}'),
                          Text('Dias Desde a Última Alteração: ${computador!['dias_desde_alteracao']}'),
                          const SizedBox(height: 10),
                          Text('Local do Laboratório: ${computador!['laboratorio']['local']}'),
                          Text('Nome do Laboratório: ${computador!['laboratorio']['nome']}'),
                          const SizedBox(height: 10),
                          Text('Tipo de Status: ${computador!['status']['nome']}'),
                          Text('Descrição do Status: ${computador!['status']['descricao']}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}