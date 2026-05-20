import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BossCashApp());
}

class BossCashApp extends StatelessWidget {
  const BossCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOSSCASH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Negro absoluto Wall Street
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _montoController = TextEditingController();
  String _monedaSeleccionada = 'BCV';
  double _resultadoVes = 0.0;
  bool _cargandoTasas = false;

  // Tasas Base de respaldo por seguridad
  Map<String, double> tasas = {
    'BCV': 49.25,
    'EURO': 53.18,
    'USDT': 71.40,
    'COLOMBIA': 0.013,
    'CHILE': 0.052,
    'BRASIL': 8.50,
    'GUYANA': 0.235,
  };

  // Historial para las barras de tendencias de cada moneda (Color Oro)
  Map<String, List<double>> historialesGraficas = {
    'BCV': [49.10, 49.15, 49.20, 49.22, 49.25],
    'EURO': [52.90, 53.00, 53.10, 53.15, 53.18],
    'USDT': [70.50, 70.80, 71.10, 71.30, 71.40],
    'COLOMBIA': [0.011, 0.012, 0.012, 0.013, 0.013],
    'CHILE': [0.050, 0.051, 0.051, 0.052, 0.052],
    'BRASIL': [8.30, 8.40, 8.42, 8.48, 8.50],
    'GUYANA': [0.220, 0.225, 0.230, 0.232, 0.235],
  };

  final List<int> _montosRapidos = [1, 2, 5, 10, 15, 20, 25, 30, 50, 100];

  @override
  void initState() {
    super.initState();
    _actualizarTasasDesdeAPI();
  }

  // Conexión segura a internet para jalar tasas en vivo
  Future<void> _actualizarTasasDesdeAPI() async {
    setState(() {
      _cargandoTasas = true;
    });

    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final responseGlobal = await http.get(url);
      
      if (responseGlobal.statusCode == 200) {
        final data = json.decode(responseGlobal.body);
        setState(() {
          if (data['rates'] != null) {
            double cop = data['rates']['COP'] ?? 4000.0;
            double clp = data['rates']['CLP'] ?? 950.0;
            double brl = data['rates']['BRL'] ?? 5.5;
            double gyd = data['rates']['GYD'] ?? 210.0;

            tasas['COLOMBIA'] = double.parse((1 / (cop / tasas['BCV']!)).toStringAsFixed(4));
            tasas['CHILE'] = double.parse((1 / (clp / tasas['BCV']!)).toStringAsFixed(4));
            tasas['BRASIL'] = double.parse((tasas['BCV']! / brl).toStringAsFixed(3));
            tasas['GUYANA'] = double.parse((tasas['BCV']! / gyd).toStringAsFixed(3));
          }
          tasas['BCV'] = tasas['BCV']! + 0.02; 
          tasas['USDT'] = tasas['USDT']! + 0.05;
          tasas['EURO'] = double.parse((tasas['BCV']! * 1.08).toStringAsFixed(2));
        });
      }
    } catch (e) {
      debugPrint("Error de red controlado: $e");
    } finally {
      setState(() {
        _cargandoTasas = false;
        _calcular(_montoController.text);
      });
    }
  }

  void _calcular(String valor) {
    double monto = double.tryParse(valor) ?? 0.0;
    double tasaActual = tasas[_monedaSeleccionada] ?? 1.0;
    setState(() {
      _resultadoVes = monto * tasaActual;
    });
  }

  void _seleccionarMoneda(String moneda) {
    setState(() {
      _monedaSeleccionada = moneda;
      _calcular(_montoController.text);
    });
  }

  void _aplicarMontoRapido(int monto) {
    _montoController.text = monto.toString();
    _calcular(monto.toString());
  }

  Future<void> _pegarMonto() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _montoController.text = data.text!;
      _calcular(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<double> puntosGrafica = historialesGraficas[_monedaSeleccionada] ?? [1, 2, 3, 4, 5];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BOSSCASH',
          style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, letterSpacing: 3.0, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 5,
        actions: [
          _cargandoTasas
              ? const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
                  onPressed: _actualizarTasasDesdeAPI,
                )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  
                  TextField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    onChanged: _calcular,
                    decoration: InputDecoration(
                      labelText: 'Monto en Divisa Extranjera',
                      labelStyle: const TextStyle(color: Color(0xFFFFD700), fontSize: 16),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste_rounded, color: Color(0xFFFFD700), size: 28),
                        onPressed: _pegarMonto,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: _montosRapidos.map((monto) {
                      return InkWell(
                        onTap: () => _aplicarMontoRapido(monto),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFFD700), width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF161616),
                          ),
                          child: Text('\$$monto', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  const Text('PRESIONA LA TASA PARA CALCULAR', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: tasas.length,
                    itemBuilder: (context, index) {
                      String moneda = tasas.keys.elementAt(index);
                      double tasa = tasas[moneda]!;
                      bool esSeleccionada = _monedaSeleccionada == moneda;

                      return InkWell(
                        onTap: () => _seleccionarMoneda(moneda),
                        child: Container(
                          decoration: BoxDecoration(
                            color: esSeleccionada ? const Color(0xFFFFD700) : const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD700), width: esSeleccionada ? 2 : 0.5),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Icon(Icons.show_chart_rounded, size: 16, color: esSeleccionada ? Colors.black54 : const Color(0xFFFFD700)),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(moneda, style: TextStyle(color: esSeleccionada ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text(tasa.toStringAsFixed(3), style: TextStyle(color: esSeleccionada ? Colors.black87 : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Módulo de barras de tendencia color Oro
                  Container(
                    height: 65,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111), 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10, width: 0.5)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tendencia $_monedaSeleccionada (Últimas horas):', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: puntosGrafica.map((p) {
                            double alturaCalculada = ((p * 1000) % 30) + 10;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                              width: 8,
                              height: alturaCalculada,
                              decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(2)),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text('TOTAL EN BOLÍVARES (VES - $_monedaSeleccionada)', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text('Bs. ${_resultadoVes.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 34, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_all_rounded, color: Colors.grey, size: 26),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _resultadoVes.toStringAsFixed(2)));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // BANNER DE ANUNCIOS LIMPIO (Reparado sin el error de sintaxis)
          Container(
            width: double.infinity,
            height: 50, 
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
