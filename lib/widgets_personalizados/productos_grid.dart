import 'package:flutter/material.dart';
import 'package:flutter_reusalo/screens/detalle%20productos/detalle_producto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para manejar JSON

class ProductosGrid extends StatelessWidget {
  final List<dynamic> listaProductos;

  const ProductosGrid({Key? key, required this.listaProductos})
      : super(key: key);

  Future<void> agregarProductoAlCarrito(
      BuildContext context, Map<String, dynamic> producto) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener el carrito actual
      final String? carritoString = prefs.getString('carrito');
      List<dynamic> carrito =
          carritoString != null ? json.decode(carritoString) : [];

      // Verificar si el producto ya existe en el carrito
      final productoExistente = carrito.firstWhere(
        (p) => p['id_producto'] == producto['id_producto'],
        orElse: () => null,
      );

      if (productoExistente != null) {
        // Mostrar un mensaje indicando que ya está en el carrito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'El producto "${producto['nombre']}" ya está en el carrito.',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Extraer la información esencial del producto
      final productoEssencial = {
        'id_producto': producto['id_producto'],
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'id_categoria': producto['id_categoria'],
        'estado': producto['estado'],
      };

      // Agregar el producto al carrito
      carrito.add(productoEssencial);

      // Guardar el carrito actualizado en SharedPreferences
      await prefs.setString('carrito', json.encode(carrito));

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Producto "${producto['nombre']}" agregado al carrito.',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Manejar errores y mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar el producto: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleProducto(producto: producto),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen con tamaño fijo
                Stack(
                  children: [
                    Container(
                      height: 150, // Altura fija para la imagen
                      width: double.infinity, // Anchura completa de la tarjeta
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16.0),
                        ),
                        child: Image.network(
                          imagen,
                          fit: BoxFit.cover, // Ajusta la imagen al contenedor
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/imagen_no_disponible.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
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
                            agregarProductoAlCarrito(context, producto);
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    producto['nombre'] ?? 'Producto sin nombre',
                    style: const TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
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
    );
  }
}
