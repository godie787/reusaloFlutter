import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para manejar JSON
import 'package:intl/intl.dart';
import 'package:flutter_reusalo/providers/ventas_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> carrito = [];
  String formaPago = 'a_convenir';

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    final String? carritoString = prefs.getString('carrito');
    if (carritoString != null) {
      setState(() {
        carrito = json.decode(carritoString);
      });
    }
  }

  Future<void> _guardarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carrito', json.encode(carrito));
  }

  String obtenerImagen(Map<String, dynamic> producto) {
    final imagenes = producto['imagenes'] ?? [];
    if (imagenes.isNotEmpty && imagenes is List) {
      return imagenes[0];
    }
    return 'assets/images/imagen_no_disponible.jpg';
  }

  String formatearPrecio(int precio) {
    final format = NumberFormat("#,##0", "es_CL");
    return format.format(precio);
  }

  Future<void> _eliminarProducto(BuildContext context, int index) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Eliminación"),
          content: const Text(
              "¿Estás seguro de que quieres eliminar este producto?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmacion ?? false) {
      setState(() {
        carrito.removeAt(index);
      });
      await _guardarCarrito();
    }
  }

  Future<void> confirmarPago() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Compra"),
          content:
              const Text("¿Estás seguro de que deseas completar la compra?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      await procesarPago();
    }
  }

  Future<void> procesarPago() async {
    try {
      // Total de la venta
      final totalVenta = carrito.fold(
        0,
        (total, producto) => total + (producto['precio'] as int),
      );

      final ventaData = {
        'id_usuario': 3,
        'total_venta': totalVenta,
        'forma_pago': formaPago,
        'carro': carrito,
      };

      VentasProvider ventasProvider = VentasProvider();
      final respuesta = await ventasProvider.crearVenta(ventaData);

      if (respuesta.containsKey('message') &&
        respuesta['message'] == 'Venta creada exitosamente') {
        // Venta creada con éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra realizada con éxito.'),
            backgroundColor: Colors.green,
          ),
        );

        await _actualizarProductosVendidos();

        setState(() {
          carrito.clear();
        });
        await _eliminarCarritoDeSharedPreferences();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(respuesta['message'] ?? 'Error al realizar la compra.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pago: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarCarritoDeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('carrito'); // Elimina la clave 'carrito'
  }

  Future<void> _actualizarProductosVendidos() async {
    try {
      final ProductosProvider productosProvider = ProductosProvider();

      for (final producto in carrito) {
        final productoActualizado = {
          'estado': 'vendido',
        };
        await productosProvider.editarProducto(
          productoActualizado,
          producto[
              'id_producto'], // Asegúrate de que el producto tenga este camp
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Productos actualizados a "vendido".'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los productos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Mi Carrito'),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'FiraCode',
          color: Colors.black,
        ),
      ),
      body: carrito.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/carro_vacio_evento.png',
                        fit: BoxFit.cover,
                        height: 300,
                        width: 300,
                      ),
                    ),
                  ),
                  const Text(
                    '¡Tu carrito está vacío!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'FredokaOne',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No has agregado ningún producto aún.\n'
                    'Explora nuestra tienda y agrega algo que te guste.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'FiraCode',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (context, index) {
                        final producto = carrito[index];
                        final String imagen = obtenerImagen(producto);

                        return Dismissible(
                          key: Key(producto['id_producto'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            await _eliminarProducto(context, index);
                            return false;
                          },
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imagen,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/imagen_no_disponible.jpg',
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                producto['nombre'] ?? 'Producto sin nombre',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'FiraCode',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '\$${formatearPrecio(producto['precio'] as int)}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'FiraCode',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Resumen del carrito
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'FiraCode',
                            ),
                          ),
                          Text(
                            '\$${formatearPrecio(calcularSubtotal())}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'FiraCode',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Envío',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'FiraCode',
                            ),
                          ),
                          const Text(
                            '\$6.080',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'FiraCode',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'FiraCode',
                            ),
                          ),
                          Text(
                            '\$${formatearPrecio(calcularSubtotal() + 6080)}',
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'FiraCode',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: formaPago,
                              decoration: const InputDecoration(
                                  labelText: 'Forma de pago',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          100.0), // Ajusta el valor según el diseño deseado
                                    ),
                                  )),
                              items: const [
                                DropdownMenuItem(
                                  value: 'a_convenir',
                                  child: Text('A convenir'),
                                ),
                                DropdownMenuItem(
                                  value: 'credito',
                                  child: Text('Tarjeta de Crédito'),
                                ),
                                DropdownMenuItem(
                                  value: 'debito',
                                  child: Text('Tarjeta de Débito'),
                                ),
                                DropdownMenuItem(
                                  value: 'transferencia',
                                  child: Text('Transferencia Bancaria'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  formaPago = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await confirmarPago();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff638B2E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'Pagar',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'FredokaOne',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100.0),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  int calcularSubtotal() {
    return carrito.fold(
      0,
      (total, producto) => total + (producto['precio'] as int),
    );
  }
}
