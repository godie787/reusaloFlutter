import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';
import 'package:flutter_reusalo/widgets_personalizados/productos_grid.dart';
import 'package:flutter_reusalo/widgets_personalizados/search_bar_with_filter.dart';

class HerramientasEquiposCatScreen extends StatefulWidget {
  const HerramientasEquiposCatScreen({super.key});

  @override
  State<HerramientasEquiposCatScreen> createState() =>
      _HerramientasEquiposCatScreenState();
}

class _HerramientasEquiposCatScreenState
    extends State<HerramientasEquiposCatScreen> {
  List<dynamic>? listaProductosHerramientasEquipos;
  List<dynamic> productosFiltrados = [];

  final ProductosProvider productosProvider = ProductosProvider();

  @override
  void initState() {
    super.initState();
    _obtenerProductosHerramientasEquipos();
  }

  Future<void> _obtenerProductosHerramientasEquipos() async {
    try {
      final productos = await productosProvider.getProductos();
      setState(() {
        listaProductosHerramientasEquipos = productos
            .where((producto) => producto['id_categoria'] == 12)
            .toList();
        productosFiltrados = List.from(listaProductosHerramientasEquipos!);
      });
    } catch (error) {
      // Manejo de errores
      print('Error al obtener productos: $error');
    }
  }

  void _aplicarFiltros(String searchQuery, RangeValues priceRange) {
    if (listaProductosHerramientasEquipos == null) return;

    setState(() {
      productosFiltrados = listaProductosHerramientasEquipos!.where((producto) {
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
          'Herramientas y equipo',
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
              if (listaProductosHerramientasEquipos != null &&
                  listaProductosHerramientasEquipos!.isNotEmpty)
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

  Widget _buildProductsSection(List<dynamic> listaProductos) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos columnas
          crossAxisSpacing: 16.0, // Espacio horizontal entre tarjetas
          mainAxisSpacing: 24.0, // Espacio vertical entre tarjetas
          childAspectRatio: 0.73, // Relación de aspecto ajustada
        ),
        itemCount: listaProductos.length,
        itemBuilder: (context, index) {
          final producto = listaProductos[index];
          final imagenes = producto['imagenes'];
          final String imagen =
              (imagenes != null && imagenes is List && imagenes.isNotEmpty)
                  ? imagenes[0]
                  : 'assets/images/imagen_no_disponible.jpg';

          return GestureDetector(
            onTap: () {
              print('presionando card');
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              )),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del producto con ícono de favorito
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16.0),
                        ),
                        child: Image.network(
                          imagen,
                          fit: BoxFit.cover,
                          height: 120,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/imagen_no_disponible.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 8,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Acción del botón de favorito
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            iconSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // Nombre del producto
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      producto['nombre'] ?? 'Producto sin nombre',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  // Precio y colores
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '\$${producto['precio'] ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
