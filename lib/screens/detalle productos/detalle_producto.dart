import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetalleProducto extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetalleProducto({Key? key, required this.producto}) : super(key: key);

  @override
  State<DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends State<DetalleProducto> {
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
        'imagenes': producto['imagenes'], // Incluimos la imagen
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
    final imagenes = widget.producto['imagenes'] ?? [];
    final nombre = widget.producto['nombre'] ?? 'Producto sin nombre';
    final precio = widget.producto['precio'] ?? '0.00';
    final descripcion =
        widget.producto['descripcion'] ?? 'Sin descripción disponible';
    final estado = widget.producto['estado'] ?? 'Estado desconocido';

    // Definir colores para los estados
    Color obtenerColorEstado(String estado) {
      switch (estado.toLowerCase()) {
        case 'disponible':
          return Colors.green;
        case 'agotado':
          return Colors.red;
        case 'pendiente':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombre,
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 20.0,
          ),
        ),
        backgroundColor: const Color(0xff638B2E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: imagenes.isNotEmpty ? imagenes.length : 1,
                itemBuilder: (context, index) {
                  final String imagen = imagenes.isNotEmpty
                      ? imagenes[index]
                      : 'assets/images/imagen_no_disponible.jpg';

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: imagen.startsWith('http')
                        ? Image.network(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Muestra una imagen local de respaldo si la imagen remota falla
                              return Image.asset(
                                'assets/images/imagen_no_disponible.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            imagen,
                            fit: BoxFit.cover,
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            // Nombre del producto y estado en una fila
            Row(
              children: [
                // Nombre del producto
                Text(
                  nombre,
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 30.0),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: obtenerColorEstado(estado),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    estado,
                    style: const TextStyle(
                      fontFamily: 'FiraCode',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Precio del producto
            Text(
              '\$$precio',
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 20.0,
                color: Color(0xff638B2E),
              ),
            ),
            const SizedBox(height: 16.0),
            // Descripción del producto
            Text(
              descripcion,
              style: const TextStyle(
                fontFamily: 'FiraCode',
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32.0), // Separación antes de los botones
            // Botón de "Agregar al carrito" o "Comprar"
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50, // Altura fija para los botones
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await agregarProductoAlCarrito(
                            context, widget.producto);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff638B2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart,
                          color: Colors.white),
                      label: const Text(
                        'Agregar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FiraCode',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0), // Espaciado entre botones
                Expanded(
                  child: SizedBox(
                    height: 50, // Altura fija para los botones
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await agregarProductoAlCarrito(
                            context, widget.producto);
                        Navigator.pushReplacementNamed(context, '/carrito');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_bag, color: Colors.white),
                      label: const Text(
                        'Comprar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FiraCode',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
