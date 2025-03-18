library;

import 'package:flutter/material.dart';
import 'package:labcomunica/utils/api_service.dart';
import 'package:labcomunica/utils/mensagem_dialogs.dart';
import 'package:labcomunica/utils/validators.dart';
import 'package:labcomunica/utils/style.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailCtr = TextEditingController();
  final senhaCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          // Lado esquerdo com logo e nome do app
          Expanded(
            flex: 1,
            child: Container(
              color: corPrimaria, // Verde escuro
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/dcomp-logo-ufs.png', 
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'LabComunica',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lado direito com formulário
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Seja bem-vindo ao',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Text(
                          'LabComunica',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: corPrimaria,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextFields(screenWidth),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              _recuperarSenha(context);
                            },
                            child: const Text(
                              'Esqueci minha senha',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: WideButton(
                            text: 'Fazer Login',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _entrar();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Função de recuperação de senha
  void _recuperarSenha(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    //Cria um pop-up onde o usuário deve inserir o seu email para então receber as instruções de recuperação de senha
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Recuperar Senha'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Por favor, insira seu E-mail para recuperar sua senha:'),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'E-mail', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String email = emailController.text;
                      await enviarEmailSenha(email, context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Enviar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  /// Service que comunica com o backend e faz o POST da recuperação de senha
  Future<void> enviarEmailSenha(String email, BuildContext context) async {
    try {
      final response = await ApiService().post('/login/esqueci-senha', {
        'email': email,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(
              child: Text(
                  'E-mail será enviado se o e-mail informado estiver cadastrado!')),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Center(child: Text('Falha ao enviar e-mail. Tente Novamente!')),
          backgroundColor: Colors.red,
        ));
        throw Exception('Falha na requisição de mudar senha');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Center(child: Text('Falha ao enviar e-mail. Tente Novamente!')),
        backgroundColor: Colors.red,
      ));
      rethrow;
    }
  }

  Widget _buildTextFields(double screenWidth) {
    return Column(
      children: [
        TextFormField(
          controller: emailCtr,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: validateEmail,
        ),
        const SizedBox(height: 20),
        TextFormField(
          obscureText: true,
          controller: senhaCtr,
          decoration: InputDecoration(
            labelText: 'Senha',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Digite sua senha';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _entrar() async {
    final api = getApi(context);

    final resp = await api.login(
      emailCtr.text,
      senhaCtr.text,
    );
    if (resp.statusCode != 200) {
      final detail = decodeResponse(resp)['detail'];
      showMensagem(context, 'Falha ao fazer login.\n$detail');
      return;
    }

    Navigator.pushReplacementNamed(context, '/home');
  }
}

class WideButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final Widget? icon;

  const WideButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget content =
        icon != null ? _buildContentWithIcon() : _buildContentDefault();

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(250, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: content,
    );
  }

  Widget _buildContentWithIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(
          width: 10,
        ),
        _buildContentDefault(),
      ],
    );
  }

  Text _buildContentDefault() {
    return Text(
      text,
      style: const TextStyle(fontSize: 18),
    );
  }
}