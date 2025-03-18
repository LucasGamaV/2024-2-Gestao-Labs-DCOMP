library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Verifica se o campo nome está vazio
String? validateTexto(String? value, {int characterLimit = 150}) {
  if (value == null || value.trim().isEmpty) {
    return 'Por favor, insira um valor.';
  }
  if (value.length > 150) {
    return 'O texto não pode ultrapassar 150 caracteres';
  }
  return null;
}

String? validateMatricula(String? value) {
  return validateTexto(value, characterLimit: 20);
}

bool isEmpty(String? value) => value == null || value.trim().isEmpty;

bool allEmpty(List<String?> values) => values.every(isEmpty);

bool anyEmpty(List<String?> values) => values.any(isEmpty);

/// Verifica se o campo email está vazio ou se o email é válido de acordo com uma expressão regular
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor, insira um email';
  }
  // Regex para validar email com TLDs válidos
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(value)) {
    return 'Por favor, insira um email válido';
  }
  if (value.length > 254) {
    return 'O email não pode ultrapassar 254 caracteres.';
  }
  final [beforeAt, afterAt] = value.split('@');
  if (beforeAt.length > 64) {
    return 'O email não pode ultrapassar 64 caracteres antes do @';
  }
  if (afterAt.length > 254) {
    return 'O email não pode ultrapassar 254 caracteres após o @';
  }
  return null;
}

String? onlyDigits(String? text) => text?.replaceAll(RegExp(r'\D'), '');

String? validateCPF(String? value) {
  if (value == null || !validateCPFAux(value)) {
    return 'Insira um CPF válido';
  }
  return null;
}

/// Função que faz a regra de validação do CPF
bool validateCPFAux(String cpf) {
  // Remove todos os caracteres que não sejam dígitos
  cpf = cpf.replaceAll(RegExp(r'\D'), '');

  if (cpf.length != 11) return false;

  // Verifica se todos os dígitos são iguais (ex: 111.111.111-11)
  if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

  int calcularDigitoVerificador(String cpfParcial, int pesoInicial) {
    int soma = 0;
    for (int i = 0; i < cpfParcial.length; i++) {
      soma += int.parse(cpfParcial[i]) * pesoInicial--;
    }
    int resto = (soma * 10) % 11;
    return resto == 10 ? 0 : resto;
  }

  // Verifica o primeiro dígito verificador
  String cpfParcial = cpf.substring(0, 9);
  int primeiroDigito = calcularDigitoVerificador(cpfParcial, 10);
  if (primeiroDigito != int.parse(cpf[9])) return false;

  // Verifica o segundo dígito verificador
  cpfParcial = cpf.substring(0, 10);
  int segundoDigito = calcularDigitoVerificador(cpfParcial, 11);
  if (segundoDigito != int.parse(cpf[10])) return false;

  return true;
}

/// Função que faz a regra de validação do CNPJ
bool validarCNPJAux(String cnpj) {
  // Remove todos os caracteres que não sejam dígitos
  cnpj = cnpj.replaceAll(RegExp(r'\D'), '');

  if (cnpj.length != 14) return false;

  // Verifica se todos os dígitos são iguais (ex: 11.111.111/1111-11)
  if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

  // Função para calcular o dígito verificador
  int calcularDigitoVerificador(String cnpjParcial, List<int> pesos) {
    int soma = 0;
    for (int i = 0; i < cnpjParcial.length; i++) {
      soma += int.parse(cnpjParcial[i]) * pesos[i];
    }
    int resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  // Pesos para o primeiro e segundo dígitos verificadores
  List<int> pesosPrimeiroDigito = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  List<int> pesosSegundoDigito = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  // Verifica o primeiro dígito verificador
  String cnpjParcial = cnpj.substring(0, 12);
  int primeiroDigito =
      calcularDigitoVerificador(cnpjParcial, pesosPrimeiroDigito);
  if (primeiroDigito != int.parse(cnpj[12])) return false;

  // Verifica o segundo dígito verificador
  cnpjParcial = cnpj.substring(0, 13);
  int segundoDigito =
      calcularDigitoVerificador(cnpjParcial, pesosSegundoDigito);
  if (segundoDigito != int.parse(cnpj[13])) return false;

  return true;
}

/// Valida se o usuário digitou uma senha e se ela tem pelo menos 8 caracteres
String? validateSenha(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Por favor, insira sua senha';
  } else if (value.length < 8) {
    return 'A senha deve ter pelo menos 8 caracteres';
  }
  return null;
}

String capitalize(String s) {
  return '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
}

Widget buildTextField(
    String label, TextEditingController controller, bool permiteDecimal) {
  return SizedBox(
    width: 90,
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: permiteDecimal),
      inputFormatters: permiteDecimal
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              //LimitarValorInputFormatter(),
            ]
          : [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*$')),
            ],
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

class LimitarValorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    double? valor = double.tryParse(newValue.text);

    if (valor != null && (valor < 0.0 || valor > 100.00)) {
      return oldValue;
    }

    return newValue;
  }
}