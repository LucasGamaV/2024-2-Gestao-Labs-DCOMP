import 'package:intl/intl.dart';

String formatMoney(double value) {
  return NumberFormat('#,##0.00', 'pt_BR').format(value);
}


// Formata uma string no formato ISO '2025-02-16T18:52:51.673Z' para '16/02/2025'.
String formatarData(String dataISO) {
  DateTime dateTime = DateTime.parse(dataISO);
  String dataFormatada = DateFormat('dd/MM/yyyy').format(dateTime);
  return dataFormatada;
}