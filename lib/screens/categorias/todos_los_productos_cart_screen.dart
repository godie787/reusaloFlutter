import 'package:flutter/material.dart';
import 'package:flutter_reusalo/widgets_personalizados/productos_grid.dart';
import 'package:flutter_reusalo/widgets_personalizados/search_bar_with_filter.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';

class TodosLosProductosCartScreen extends StatefulWidget {
  const TodosLosProductosCartScreen({super.key});

  @override
  State<TodosLosProductosCartScreen> createState() =>
      _TodosLosProductosCartScreenState();
}

class _TodosLosProductosCartScreenState
    extends State<TodosLosProductosCartScreen> {
  List<dynamic>? listaProductos; // Cambiado de Map a List
  final ProductosProvider productosProvider = ProductosProvider();
  List<dynamic> productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _obtenerProductos();
  }

  // Función para obtener los productos de manera asíncrona
  Future<void> _obtenerProductos() async {
    final productos = await productosProvider.getProductos();
    setState(() {
      listaProductos = productos;
      productosFiltrados = List.from(listaProductos!);
    });
  }

  void _aplicarFiltros(String searchQuery, RangeValues priceRange) {
    if (listaProductos == null) return;

    setState(() {
      productosFiltrados = listaProductos!.where((producto) {
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
          'Todos los productos',
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
              if (listaProductos != null && listaProductos!.isNotEmpty)
                Expanded(
                  child: ProductosGrid(listaProductos: productosFiltrados),
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
