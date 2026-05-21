import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

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
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
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

  // Lista de anuncios que rotan en la barra inferior (¡Edita estos textos cuando quieras!)
  final List<String> _anuncios = [
    "🔥 ¡BIENVENIDO A BOSSCASH! LA MEJOR TASA DEL MERCADO EN VIVO. 🔥",
    "⚡ COMPRA Y VENTA DE USDT, REALEZ, PESOS Y EUROS AL INSTANTE. ⚡",
    "📈 TASAS ACTUALIZADAS EN TIEMPO REAL CON EL DÓLAR PARALELO Y BCV. 📈",
    "💎 SEGURIDAD, RAPIDEZ Y EL MEJOR SOPORTE PARA TUS CAMBIOS. 💎"
  ];
  int _anuncioActual = 0;
  late Timer _timerAnuncios;

  Map<String, double> tasas = {
    'BCV': 52.09,
    'USDT': 57.55,
    'EURO': 604.15,
    'COLOMBIA': 0.135,
    'CHILE': 0.548,
    'BRASIL': 104.45,
    'GUYANA': 2.48,
  };

  Map<String, List<double>> historialesGraficas = {
    'BCV': [51.50, 51.70, 51.93, 52.00, 52.09],
    'USDT': [56.10, 56.80, 57.10, 57.30, 57.55],
    'EURO': [60.20, 60.45, 61.10, 61.90, 62.15],
    'COLOMBIA': [0.131, 0.132, 0.133, 0.135, 0.135],
    'CHILE': [0.540, 0.542, 0.545, 0.547, 0.548],
    'BRASIL': [101.10, 102.60, 103.00, 104.00, 104.45],
    'GUYANA': [2.41, 2.43, 2.45, 2.46, 2.48],
  };

  final List<int> _montosRapidos = [1, 5, 10, 20, 50, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _actualizarTasasDesdeAPI();
    // Motor de la barra de anuncios rotativa (Cambia cada 4 segundos)
    _timerAnuncios = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _anuncioActual = (_anuncioActual + 1) % _anuncios.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerAnuncios.cancel();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _actualizarTasasDesdeAPI() async {
    setState(() { _cargandoTasas = true; });
    try {
      final cliente = HttpClient();
      
      final solicitudVzla = await cliente.getUrl(Uri.parse('https://ve.dolarapi.com/v1/dolares'));
      final respuestaVzla = await solicitudVzla.close();
      
      if (respuestaVzla.statusCode == 200) {
        final datosCadenaVzla = await respuestaVzla.transform(utf8.decoder).join();
        List<dynamic> listaData = json.decode(datosCadenaVzla);
        
        setState(() {
          for (var item in listaData) {
            if (item['fuente'] == 'oficial') {
              tasas['BCV'] = (item['promedio'] ?? tasas['BCV']!).toDouble();
            } else if (item['fuente'] == 'enparalelovzla') {
              tasas['USDT'] = (item['promedio'] ?? tasas['USDT']!).toDouble();
            }
          }
        });
      }

      final solicitudGlobal = await cliente.getUrl(Uri.parse('https://open.er-api.com/v6/latest/USD'));
      final respuestaGlobal = await solicitudGlobal.close();
      
      if (respuestaGlobal.statusCode == 200) {
        final datosCadenaGlobal = await respuestaGlobal.transform(utf8.decoder).join();
        final dataG = json.decode(datosCadenaGlobal);
        
        setState(() {
          if (dataG['rates'] != null) {
            double euroGlobal = (dataG['rates']['EUR'] ?? 0.92).toDouble();
            double copGlobal = (dataG['rates']['COP'] ?? 4000.0).toDouble();
            double clpGlobal = (dataG['rates']['CLP'] ?? 940.0).toDouble();
            double brlGlobal = (dataG['rates']['BRL'] ?? 5.50).toDouble();
            
            tasas['EURO'] = double.parse((tasas['BCV']! * (1 / euroGlobal)).toStringAsFixed(2));
            tasas['COLOMBIA'] = double.parse((tasas['USDT']! / (copGlobal / 1000)).toStringAsFixed(3));
            tasas['CHILE'] = double.parse((tasas['USDT']! / (clpGlobal / 1000)).toStringAsFixed(3));
            tasas['BRASIL'] = double.parse((tasas['USDT']! / brlGlobal).toStringAsFixed(2)); 
          }
          
          tasas.forEach((key, value) {
            if (historialesGraficas[key] != null) {
              historialesGraficas[key]!.removeAt(0);
              historialesGraficas[key]!.add(value);
            }
          });
        });
      }
      cliente.close();
    } catch (e) {
      debugPrint("Error de red controlado.");
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
                  // BANNER CORPORATIVO INTEGRADO CON TU DISEÑO OFICIAL
                  Container(
                    height: 140,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(Icons.monetization_on_rounded, size: 100, color: const Color(0xFFFFD700).withOpacity(0.05)),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('\$', style: TextStyle(color: Color(0xFF00C853), fontSize: 52, fontWeight: FontWeight.bold)),
                                const Text('BOSSCASH', style: TextStyle(color: Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3)),
                                const SizedBox(height: 2),
                                Text('PLATAFORMA DE CAMBIO DE MONEDAS', style: TextStyle(color: Colors.grey[400], fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  const Text('SELECCIONA TASA / TOCA 📈 PARA VER GRÁFICA', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: tasas.length,
                    itemBuilder: (context, index) {
                      String moneda = tasas.keys.elementAt(index);
                      double t = tasas[moneda]!;
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
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.show_chart_rounded, size: 20, color: esSeleccionada ? Colors.black87 : const Color(0xFFFFD700)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GraficaPantalla(
                                          moneda: moneda, 
                                          puntos: historialesGraficas[moneda] ?? [1,2,3,4,5],
                                          precioActual: t,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(moneda, style: TextStyle(color: esSeleccionada ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Text(t.toStringAsFixed(2), style: TextStyle(color: esSeleccionada ? Colors.black87 : Colors.grey[400], fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
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
          // CUADRO DE ANUNCIOS ORIGINAL RECUPERADO Y DINÁMICO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.5)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                _anuncios[_anuncioActual],
                key: ValueKey<int>(_anuncioActual),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GraficaPantalla extends StatelessWidget {
  final String moneda;
  final List<double> puntos;
  final double precioActual;

  const GraficaPantalla({super.key, required this.moneda, required this.puntos, required this.precioActual});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('HISTORIAL $moneda', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text('Precio en Vivo Actual ($moneda):', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 5),
            Text('Bs. ${precioActual.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const Text('COMPORTAMIENTO DEL MERCADO (ÚLTIMAS HORAS)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10, width: 0.5)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: puntos.map((p) {
                    double alturaCalculada = ((p * 100) % 150) + 50;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(p.toStringAsFixed(2), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        const SizedBox(height: 8),
                        Container(
                          width: 32,
                          height: alturaCalculada,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))
                            ]
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '* Las tasas se sincronizan automáticamente con servidores globales cada 60 minutos.', 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
