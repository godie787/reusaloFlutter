import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';
import 'package:flutter_reusalo/widgets_personalizados/productos_grid.dart';
import 'package:flutter_reusalo/widgets_personalizados/search_bar_with_filter.dart';

class ElectronicaGadgetsCatScreen extends StatefulWidget {
  const ElectronicaGadgetsCatScreen({super.key});

  @override
  State<ElectronicaGadgetsCatScreen> createState() =>
      _ElectronicaGadgetsCatScreenState();
}

class _ElectronicaGadgetsCatScreenState
    extends State<ElectronicaGadgetsCatScreen> {
  List<dynamic>? listaProductosElectronicaGadgets;
  List<dynamic> productosFiltrados = [];
  final ProductosProvider productosProvider = ProductosProvider();
  @override
  void initState() {
    super.initState();
    _obtenerProductosElectronicaGadgets();
  }

  Future<void> _obtenerProductosElectronicaGadgets() async {
    try {
      final productos = await productosProvider.getProductos();
      setState(() {
        listaProductosElectronicaGadgets = productos
            .where((producto) => producto['id_categoria'] == 12)
            .toList();
        productosFiltrados = List.from(listaProductosElectronicaGadgets!);
      });
    } catch (error) {
      // Manejo de errores
      print('Error al obtener productos: $error');
    }
  }

  void _aplicarFiltros(String searchQuery, RangeValues priceRange) {
    if (listaProductosElectronicaGadgets == null) return;

    setState(() {
      productosFiltrados = listaProductosElectronicaGadgets!.where((producto) {
        final nombreProducto = producto['nombre'].toString().toLowerCase();
        final precio = producto['precio'] ?? 0;

        return nombreProducto.contains(searchQuery.toLowerCase()) &&
            precio >= priceRange.start &&
            precio <= priceRange.end;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Electrónica y gadgets',
          style: TextStyle(fontFamily: 'FiraCode', fontSize: 15),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navega hacia atrás
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Cierra el teclado
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBarWithFilter(onFilterChanged: _aplicarFiltros),
              const SizedBox(height: 10),
              // Verificar si la lista de productos no es nula ni vacía
              if (listaProductosElectronicaGadgets != null &&
                  listaProductosElectronicaGadgets!.isNotEmpty)
                Expanded(
                  child: ProductosGrid(
                      listaProductos: productosFiltrados),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '¡Categoría sin productos!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'FredokaOne',
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Texto descriptivo
                        const Text(
                          'No se han agregado productos aún.\n'
                          'Explora nuestra app y sorpréndete.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'FiraCode',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
