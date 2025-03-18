import 'package:flutter/material.dart';
import 'package:labcomunica/screens/computadores/computador_manutencao.dart';
import 'package:labcomunica/utils/utils.dart';
import 'package:labcomunica/screens/computadores/computador_detalhes.dart';
import 'package:labcomunica/widgets/app_bar.dart';
import 'package:labcomunica/widgets/bottom_bar.dart';
import 'package:labcomunica/widgets/no_results.dart';
import 'package:labcomunica/widgets/menu/menu_drawer.dart';

class ListarComputadoresPage extends StatefulWidget {
  const ListarComputadoresPage({super.key});

  @override
  State<ListarComputadoresPage> createState() => _ListarComputadoresPageState();
}

class _ListarComputadoresPageState extends State<ListarComputadoresPage> {
  List<dynamic> computadores = [];
  String? filtroMarca;
  String? filtroSO;
  String? filtroLocal;

  @override
  void initState() {
    super.initState();
    fetchComputadores();
  }

  Future<void> fetchComputadores() async {
    final api = getApi(context);
    final response = await api.get('/computadores/');

    if (!is2xx(response.statusCode)) {
      await treatResponse(context, response);
      return;
    }
    setState(() {
      computadores = decodeResponse(response);
    });
  }

  List<dynamic> getComputadoresFiltrados() {
    return computadores.where((comp) {
      final marcaOk = filtroMarca == null || comp['marca'] == filtroMarca;
      final soOk = filtroSO == null || comp['sistema_operacional'] == filtroSO;
      final localOk = filtroLocal == null || comp['laboratorio']['local'] == filtroLocal;
      return marcaOk && soOk && localOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final computadoresFiltrados = getComputadoresFiltrados();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 600;

        Widget content = computadores.isEmpty
            ? const NoResultsWarning(
                substantivo: 'computador',
                substantivoFeminino: false,
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Marca'),
                          value: filtroMarca,
                          onChanged: (value) => setState(() => filtroMarca = value),
                          items: computadores
                              .map((e) => e['marca'].toString())
                              .toSet()
                              .map((marca) => DropdownMenuItem(
                                    value: marca,
                                    child: Text(marca),
                                  ))
                              .toList(),
                        ),
                        DropdownButton<String>(
                          hint: const Text('Sistema Operacional'),
                          value: filtroSO,
                          onChanged: (value) => setState(() => filtroSO = value),
                          items: computadores
                              .map((e) => e['sistema_operacional'].toString())
                              .toSet()
                              .map((so) => DropdownMenuItem(
                                    value: so,
                                    child: Text(so),
                                  ))
                              .toList(),
                        ),
                        DropdownButton<String>(
                          hint: const Text('Local'),
                          value: filtroLocal,
                          onChanged: (value) => setState(() => filtroLocal = value),
                          items: computadores
                              .map((e) => e['laboratorio']['local'].toString())
                              .toSet()
                              .map((local) => DropdownMenuItem(
                                    value: local,
                                    child: Text(local),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: computadoresFiltrados.length,
                      itemBuilder: (context, index) {
                        final computador = computadoresFiltrados[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text('Patrimônio: ${computador['patrimonio']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Marca: ${computador['marca']}'),
                                  Text('Hostname: ${computador['hostname']}'),
                                  Text('Dias Sem Alteração: ${computador['dias_desde_alteracao']}'),
                                  Text('Última Alteração: ${computador['data_ultima_alteracao']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.search, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ComputadorDetalhesPage(
                                            computadorId: computador['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.build, color: Colors.red),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ManutencaoComputadorPage(
                                            computadorId: computador['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );

        if (isLargeScreen) {
          return Scaffold(
            appBar: const LogoBar(),
            body: Row(
              children: [
                const SizedBox(
                  width: 250,
                  child: MenuDrawer('listar-computadores'),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: const LogoBar(),
            drawer: const MenuDrawer('listar-computadores'),
            bottomNavigationBar:
                bottomBar('Computadores', Icons.computer_outlined),
            body: content,
          );
        }
      },
    );
  }
}
