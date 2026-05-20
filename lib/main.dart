import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boss Cash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Fondo oscuro elegante
      ),
      home: const CalculadoraBossCash(),
    );
  }
}

class CalculadoraBossCash extends StatefulWidget {
  const CalculadoraBossCash({super.key});

  @override
  State<CalculadoraBossCash> createState() => _CalculadoraBossCashState();
}

class _CalculadoraBossCashState extends State<CalculadoraBossCash> {
  final TextEditingController _montoController = TextEditingController();
  double _resultadoPesos = 0.0;
  double _resultadoBolivares = 0.0;

  // Tasas fijas solicitadas
  final double tasaPesos = 51.85;
  final double tasaBolivares = 70.50;

  void _calcular() {
    double montoInput = double.tryParse(_montoController.text) ?? 0.0;
    setState(() {
      _resultadoPesos = montoInput * tasaPesos;
      _resultadoBolivares = montoInput * tasaBolivares;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CALCULADORA BOSS CASH', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        elevation: 10,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Cuadro de entrada de texto
            TextField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 22),
              decoration: InputDecoration(
                labelText: 'Monto en Dólares (\$)',
                labelStyle: const TextStyle(color: Colors.purpleAccent, fontSize: 18),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.purple, width: 2.0),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.purpleAccent, width: 3.0),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.purpleAccent),
              ),
              onChanged: (value) => _calcular(),
            ),
            const SizedBox(height: 30),
            
            // Botón Morado de Calcular
            ElevatedButton(
              onPressed: _calcular,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: const Text('CALCULAR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 40),

            // Cuadro de Resultados Pesos
            Card(
              color: const Color(0xFF16213E),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.purple, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('PESOS COLOMBIANOS', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('\$ ${_resultadoPesos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('Tasa: $tasaPesos', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cuadro de Resultados Bolívares
            Card(
              color: const Color(0xFF16213E),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.purple, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('BOLÍVARES (BS)', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('Bs. ${_resultadoBolivares.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('Tasa: $tasaBolivares', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
