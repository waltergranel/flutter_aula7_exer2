import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_aula7_exer2/dolar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  DateTime dataInicio = DateTime.now();
  var dolarHoje = '';
  var dolarAnoUltimo = '';
  var dolarAnoPenultimo = '';
  var dolarAnoAntePenultimo = '';
  late DateTime dataAtualizada;
  final TextEditingController dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    buscarDatas();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.currency_exchange,
                    size: 30,
                  ),
                  Text(
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      '  Aplicativo de Cotação do Dólar'),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  'Cotação do Dolar Hoje - Data: ${dataInicio.day}/${dataInicio.month}/${dataInicio.year}'),
              Text(
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                  dolarHoje),
              const Text(
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  'Cotação do Dólar nos últimos três anos:'),
              Text(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  'Data: ${dataInicio.day}/${dataInicio.month}/${dataInicio.year - 1} $dolarAnoUltimo'),
              Text(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  'Data: ${dataInicio.day}/${dataInicio.month}/${dataInicio.year - 2} $dolarAnoPenultimo'),
              Text(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  'Data: ${dataInicio.day}/${dataInicio.month}/${dataInicio.year - 3} $dolarAnoAntePenultimo'),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: dataController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Informe a data (DD/MM/AAAA):'),
              ),
              TextButton(
                onPressed: buscarDatas,
                child: const Text('Consulta Cotação do Dolar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void buscarDatas() async {
    String url = '';
    String dt = '';
    if (dataController.text != "") {
      String dataConsulta = dataController.text;
      DateFormat formato = DateFormat('dd/MM/yyyy');
      dataInicio = formato.parse(dataConsulta);
    }

    for (int i = 0; i < 4; i++) {
      dataAtualizada =
          DateTime(dataInicio.year - i, dataInicio.month, dataInicio.day);

      if (dataAtualizada.weekday == DateTime.saturday) {
        dataAtualizada = dataAtualizada.add(const Duration(days: 2));
      } else if (dataAtualizada.weekday == DateTime.sunday) {
        dataAtualizada = dataAtualizada.add(const Duration(days: 1));
      }

      dt = '${dataAtualizada.year}';
      if (dataAtualizada.month < 10) {
        dt += '0${dataAtualizada.month}';
      } else {
        dt += '${dataAtualizada.month}';
      }
      if (dataAtualizada.day < 10) {
        dt += '0${dataAtualizada.day}';
      } else {
        dt += '${dataAtualizada.day}';
      }
      url =
          'https://economia.awesomeapi.com.br/json/daily/USD-BRL/?start_date=$dt&end_date=$dt';
      final resp = await http.get(Uri.parse(url));

      if (resp.body.length <= 21) {
        setState(() {
          dolarHoje = 'Não Encontrado';
        });
      } else if (resp.statusCode == 200) {
        final List<dynamic> vlr = jsonDecode(resp.body);
        List<Dolar> vlr2 = vlr.map((item) => Dolar.fromJson(item)).toList();

        setState(() {
          if (i == 0) {
            dolarHoje = vlr2
                .map((cotacao) =>
                    'Valor (Mínimo): ${cotacao.dolarLow} - (Máximo): ${cotacao.dolarHigh}')
                .join();
          } else if (i == 1) {
            dolarAnoUltimo = vlr2
                .map((cotacao) =>
                    '\nValor (Mínimo): ${cotacao.dolarLow} - (Máximo): ${cotacao.dolarHigh}')
                .join();
          } else if (i == 2) {
            dolarAnoPenultimo = vlr2
                .map((cotacao) =>
                    '\nValor (Mínimo): ${cotacao.dolarLow} - (Máximo): ${cotacao.dolarHigh}')
                .join();
          } else if (i == 3) {
            dolarAnoAntePenultimo = vlr2
                .map((cotacao) =>
                    '\nValor (Mínimo): ${cotacao.dolarLow} - (Máximo): ${cotacao.dolarHigh}')
                .join();
          }
        });
      } else {
        // diferente de 200
        throw Exception('Falha no carregamento.');
      }
      dt = '';
    }
  }
}