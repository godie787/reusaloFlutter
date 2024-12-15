import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';
import 'package:flutter_reusalo/screens/tabs/productos/crear_producto_screen.dart';
import 'package:flutter_reusalo/screens/tabs/productos/editar_producto_screen.dart';

class TabProductosScreen extends StatefulWidget {
  const TabProductosScreen({super.key});

  @override
  _TabProductosScreenState createState() => _TabProductosScreenState();
}

class _TabProductosScreenState extends State<TabProductosScreen> {
  List<Map<String, dynamic>> _productos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerProductos();
  }

  Future<void> _obtenerProductos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ProductosProvider productosProvider = ProductosProvider();
      List<dynamic> productos = await productosProvider.getProductos();

      setState(() {
        _productos = productos
            .cast<Map<String, dynamic>>()
            .where((producto) => producto['id_usuario'] == 3)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener productos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> eliminarProducto(int idProducto) async {
    try {
      ProductosProvider productosProvider = ProductosProvider();

      final respuesta = await productosProvider.eliminarProducto(idProducto);

      if (respuesta != null && respuesta['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );

        // Actualizar lista de productos
        _obtenerProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(respuesta['message'] ?? 'Error al eliminar el producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> confirmarEliminarProducto(
      BuildContext context, int idProducto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await eliminarProducto(idProducto);
      await _obtenerProductos(); // Asegurarse de refrescar la lista
      setState(() {}); // Forzar la reconstrucción de la pantalla
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _obtenerProductos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CrearProductoWidget(onCrearProducto: _obtenerProductos),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _VerMisProductosWidget(
                    eventos: _productos,
                    onEliminarProducto: (idProducto) =>
                        confirmarEliminarProducto(context, idProducto),
                  ),
          ],
        ),
      ),
    );
  }
}

class _CrearProductoWidget extends StatelessWidget {
  final VoidCallback onCrearProducto;

  _CrearProductoWidget({super.key, required this.onCrearProducto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Publica un producto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'FredokaOne',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Publica un nuevo producto para compartir con la comunidad.',
            style: TextStyle(
                fontSize: 14, color: Colors.grey, fontFamily: 'FiraCode'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrearProductoScreen(),
                ),
              );
              onCrearProducto();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff638B2E),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Publicar',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FiraCode'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerMisProductosWidget extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;
  final Function(int idProducto) onEliminarProducto;

  _VerMisProductosWidget(
      {super.key, required this.eventos, required this.onEliminarProducto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Mis Productos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'FredokaOne',
            ),
          ),
          const SizedBox(height: 10),
          eventos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No has publicado productos aún',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    final evento = eventos[index];
                    return _buildEventoItem(context, evento);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEventoItem(BuildContext context, Map<String, dynamic> producto) {
    Color estadoColor;
    String estado = producto['estado'] ?? 'Desconocido';

    switch (estado.toLowerCase()) {
      case 'pendiente':
        estadoColor = Colors.yellow;
        break;
      case 'cancelado':
        estadoColor = Colors.red;
        break;
      case 'disponible':
        estadoColor = Colors.green;
        break;
      case 'finalizado':
        estadoColor = Colors.blue;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(
        radius: 10,
        backgroundColor: estadoColor,
      ),
      title: Text(
        producto['nombre'] ?? 'Sin título',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'Estado: $estado',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarProductoScreen(
                    producto: producto,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              onEliminarProducto(producto['id_producto']);
            },
          ),
        ],
      ),
    );
  }
}
