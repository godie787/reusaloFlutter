import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';
import 'package:flutter_reusalo/widgets_personalizados/productos_grid.dart';
import 'package:flutter_reusalo/widgets_personalizados/search_bar_with_filter.dart'; // Importa el widget

class RopaAccesoriosCatScreen extends StatefulWidget {
  const RopaAccesoriosCatScreen({super.key});

  @override
  State<RopaAccesoriosCatScreen> createState() =>
      _RopaAccesoriosCatScreenState();
}

class _RopaAccesoriosCatScreenState extends State<RopaAccesoriosCatScreen> {
  List<dynamic>? listaProductosRopaAccesorio; // Cambiado de Map a List
  final ProductosProvider productosProvider = ProductosProvider();
  List<dynamic> productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _obtenerProductosRopaAccesorios();
  }

  Future<void> _obtenerProductosRopaAccesorios() async {
    try {
      final productos = await productosProvider.getProductos();
      setState(() {
        listaProductosRopaAccesorio = productos
            .where((producto) => producto['id_categoria'] == 8)
            .toList();
        productosFiltrados = List.from(listaProductosRopaAccesorio!);
      });
    } catch (error) {
      // Manejo de errores
      print('Error al obtener productos: $error');
    }
  }

  void _aplicarFiltros(String searchQuery, RangeValues priceRange) {
    if (listaProductosRopaAccesorio == null) return;

    setState(() {
      productosFiltrados = listaProductosRopaAccesorio!.where((producto) {
        final nombreProducto = producto['nombre'].toString().toLowerCase();
        final precio = producto['precio'] ?? 0;

        return nombreProducto.contains(searchQuery.toLowerCase()) &&
            precio >= priceRange.start &&
            precio <= priceRange.end;
      }).toList();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ropa y accesorios',
          style: TextStyle(fontFamily: 'FiraCode', fontSize: 15),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Navega hacia atrás
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
              if (listaProductosRopaAccesorio != null &&
                  listaProductosRopaAccesorio!.isNotEmpty)
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
