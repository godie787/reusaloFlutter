import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/ventas_provider.dart';

class TabComprasScreen extends StatefulWidget {
  const TabComprasScreen({super.key});

  @override
  State<TabComprasScreen> createState() => _TabComprasScreenState();
}

class _TabComprasScreenState extends State<TabComprasScreen> {
  List<dynamic> compras = [];
  bool isLoading = false;

  Future<void> _obtenerCompras() async {
    setState(() {
      isLoading = true;
    });
    try {
      VentasProvider ventasProvider = VentasProvider();
      final ventas = await ventasProvider.getVentas();

      // Filtrar compras solo del usuario con id_usuario = 3
      compras = ventas.where((venta) => venta['id_usuario'] == 3).toList();

      // Imprimir las compras en consola
      print('Compras del usuario: $compras');
    } catch (e) {
      print('Error al obtener las compras: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _obtenerCompras,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff638B2E),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Cargar Compras',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'FiraCode',
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
