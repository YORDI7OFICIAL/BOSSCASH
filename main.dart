import 'package:flutter/material.dart';

void main() => runApp(const BossCashApp());

class BossCashApp extends StatelessWidget {
  const BossCashApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BOSS CASH',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16), // Negro mate premium
        primaryColor: const Color(0xFF00E676), // Verde Neón de billete pesado
      ),
      home: const PantallaBossCash(),
    );
  }
}

class PantallaBossCash extends StatefulWidget {
  const PantallaBossCash({Key? key}) : super(key: key);

  @override
  _PantallaBossCashState createState() => _PantallaBossCashState();
}

class _PantallaBossCashState extends State<PantallaBossCash> {
  // TASAS EN VIVO PARA EL MERCADO ACTUAL 2026
  double bcvDolar = 51.85;
  double bcvEuro = 56.30;
  double paraleloDolar = 70.50;
  double usdtBinance = 70.12;
  double pesoColombiano = 0.0129; 
  double realBrasileno = 10.15;
  double titiTrinitario = 7.62;
  double dolarGuyanes = 0.24;
  double solPeruano = 13.95;
  double pesoChileno = 0.055;
  double ecuadorDolar = 51.85;

  bool actualizando = false;

  void ejecutarActualizacionBoss() {
    setState(() {
      actualizando = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        actualizando = false;
        // Simulación de cambio vivo en el USDT al actualizar
        usdtBinance = usdtBinance + (DateTime.now().second % 2 == 0 ? 0.15 : -0.10);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF00E676),
          content: Text('⚡ BOSS CASH: Tasas actualizadas en tiempo récord.', 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    });
  }

  void abrirCalculadoraBoss(String moneda, double tasa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A26),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        double resultadoVES = 0.0;
        TextEditingController inputController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 25, left: 25, right: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate, color: Color(0xFF00E676)),
                      const SizedBox(width: 10),
                      Text('BOSS CALC: $moneda', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.black)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: inputController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Monto a convertir',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676), width: 2)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        double cantidad = double.tryParse(value) ?? 0.0;
                        resultadoVES = cantidad * tasa;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090D16),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('Efectivo Estimado en Bolívares (VES)', 
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(
                          '${resultadoVES.toStringAsFixed(2)} Bs',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.black, color: Color(0xFF00E676)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> listaDivisas = [
      {"name": "Dólar BCV", "price": bcvDolar, "flag": "🏛️", "info": "Oficial BCV", "time": "4:00 PM"},
      {"name": "Dólar Paralelo", "price": paraleloDolar, "flag": "🚀", "info": "Promedio Calle", "time": "Hace 10 min"},
      {"name": "USDT (Binance P2P)", "price": usdtBinance, "flag": "🪙", "info": "Crypto Vivo", "time": "Hora a hora"},
      {"name": "Euro Oficial", "price": bcvEuro, "flag": "🇪🇺", "info": "Oficial BCV", "time": "4:00 PM"},
      {"name": "Peso Colombiano", "price": pesoColombiano, "flag": "🇨🇴", "info": "Táchira / Zulia", "time": "Tiempo récord", "lowValue": true},
      {"name": "Real Brasileño", "price": realBrasileno, "flag": "🇧🇷", "info": "Frontera Bolívar", "time": "Tiempo récord"},
      {"name": "Dólar Trinidad (Titi)", "price": titiTrinitario, "flag": "🇹🇹", "info": "Zona Caribe", "time": "Diario"},
      {"name": "Dólar Guyanés", "price": dolarGuyanes, "flag": "🇬🇾", "info": "Frontera Oriente", "time": "Diario", "lowValue": true},
      {"name": "Sol Peruano", "price": solPeruano, "flag": "🇵🇪", "info": "Remesas Express", "time": "En línea"},
      {"name": "Peso Chileno", "price": pesoChileno, "flag": "🇨🇱", "info": "Remesas Express", "time": "En línea", "lowValue": true},
      {"name": "Ecuador (Dólar)", "price": ecuadorDolar, "flag": "🇪🇨", "info": "Conversión Fija", "time": "Instantáneo"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BOSS CASH', 
          style: TextStyle(fontWeight: FontWeight.black, letterSpacing: 1.5, fontSize: 22, color: Color(0xFF00E676))),
        backgroundColor: const Color(0xFF131A26),
        elevation: 4,
        actions: [
          IconButton(
            icon: actualizando 
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E676))) 
              : const Icon(Icons.flash_on, color: Color(0xFF00E676)),
            onPressed: actualizando ? null : ejecutarActualizacionBoss,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF00E676).withOpacity(0.1),
            child: const Center(
              child: Text(
                '💰 CONTROL TOTAL DEL DINERO EN LA FRONTERA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00E676), letterSpacing: 1),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listaDivisas.length,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemBuilder: (context, index) {
                final divisa = listaDivisas[index];
                double precio = divisa['price'];
                bool esTasaBaja = divisa['lowValue'] ?? false;

                return Card(
                  color: const Color(0xFF131A26),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Text(divisa['flag'], style: const TextStyle(fontSize: 32)),
                    title: Text(divisa['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${divisa['info']} • ${divisa['time']}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    trailing: Text(
                      esTasaBaja ? "${precio.toStringAsFixed(4)} Bs" : "${precio.toStringAsFixed(2)} Bs",
                      style: const TextStyle(fontSize: 1