library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labcomunica/utils/utils.dart';
import 'package:labcomunica/widgets/app_bar.dart';
import 'package:labcomunica/widgets/bottom_bar.dart';

class ManutencaoComputadorPage extends StatefulWidget {
  final int computadorId;

  const ManutencaoComputadorPage({super.key, required this.computadorId});

  @override
  State<ManutencaoComputadorPage> createState() => _ManutencaoComputadorPageState();
}

class _ManutencaoComputadorPageState extends State<ManutencaoComputadorPage> {
  final TextEditingController observacaoController = TextEditingController();

  Map<String, dynamic>? computador;
  String? _statusDescricao;
  int? _statusId;
  DateTime? _dataAlteracao;
  List<Map<String, dynamic>> _statusList = [];

  @override
  void initState() {
    super.initState();
    fetchComputador();
    fetchStatusList();
  }

    Future<void> fetchStatusList() async {
    final api = getApi(context);

    String statusNome = "Em manutenção";
    String encodedNome = Uri.encodeComponent(statusNome);

    final res = await api.get('/status/$encodedNome/');

    if (is2xx(res.statusCode)) {
      setState(() {
        _statusList = List<Map<String, dynamic>>.from(decodeResponse(res));
      });
    } else {
      await treatResponse(context, res);
    }
  }

  Future<void> fetchStatusId(String descricao) async {
    final api = getApi(context);

    String encodedDescricao = Uri.encodeComponent(descricao);

    final res = await api.get('/status/Em manutenção/$encodedDescricao/');

    if (is2xx(res.statusCode)) {
      final data = decodeResponse(res);
      setState(() {
        _statusId = data['id'];
      });
    } else {
      await treatResponse(context, res);
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Concluindo...')
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchComputador() async {
    final api = getApi(context);
    final res = await api.get('/computadores/${widget.computadorId}/');

    if (!is2xx(res.statusCode)) {
      await treatResponse(context, res);
      Navigator.pop(context);
      return;
    }
    setState(() {
      computador = decodeResponse(res);
    });
  }

  Future<void> concluirManutencao() async {
    if (_statusId == null) {
      showMensagem(
        context,
        'Selecione um Status para continuar.',
      );
      return;
    }
    final apiService = Provider.of<ApiService>(context, listen: false);

    showLoadingDialog(context);
    final response = await apiService.post('/alteracoes/',
      {
        'tipo_alteracao': "Manutenção",
        'data_alteracao': _dataAlteracao != null
          ? '${_dataAlteracao!.year}-${_dataAlteracao!.month.toString().padLeft(2, '0')}-${_dataAlteracao!.day.toString().padLeft(2, '0')}'
          : '',
        'observacao': observacaoController.text == ''
            ? 'Sem obervações'
            : observacaoController.text,
        'computador_id': widget.computadorId,
        'tecnico_id': apiService.idEspecifico,
        'status_id': _statusId,
      },
    );
    Navigator.pop(context);

    if (!is2xx(response.statusCode)) {
      treatResponse(context, response);
      return;
    }

    await showMensagem(
      context,
      tipo: TipoMensagem.info,
      'Manutenção cadastrada com sucesso!',
    );
    goBackTo(context, '/listar-computadores');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoBar(),
      bottomNavigationBar:
          bottomBar('Manutenção Computador', Icons.collections_bookmark_outlined),
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
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Status (Descrição)',
                              border: OutlineInputBorder(),
                            ),
                            value: _statusDescricao,
                            items: _statusList.map<DropdownMenuItem<String>>((status) {
                              return DropdownMenuItem<String>(
                                value: status['descricao'] as String, // Garante que é String
                                child: Text(status['descricao']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _statusDescricao = value;
                              });
                              fetchStatusId(value!); // Chama a função para pegar o ID do status selecionado
                            },
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Data de Manutenção (dd/mm/yyyy)',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dataAlteracao = pickedDate;
                                });
                              }
                            },
                            controller: TextEditingController(
                              text: _dataAlteracao == null
                                  ? ''
                                  : '${_dataAlteracao!.day}/${_dataAlteracao!.month}/${_dataAlteracao!.year}',
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: observacaoController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Observações',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: concluirManutencao,
                              child: const Text('Concluir Manutenção'),
                            ),
                          ),
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