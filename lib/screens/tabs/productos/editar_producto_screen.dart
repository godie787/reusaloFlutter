import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/categorias_provider.dart';
import 'package:flutter_reusalo/providers/productos_provider.dart';

class EditarProductoScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  _EditarProductoScreenState createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _imagenesController = TextEditingController();

  String? _estadoSeleccionado = 'pendiente';
  String? _categoriaSeleccionada;
  final List<Map<String, dynamic>> _categorias = []; // Se cargará dinámicamente

  @override
  void initState() {
    super.initState();
    // Inicializar los valores del formulario
    _nombreController.text = widget.producto['nombre'] ?? '';
    _precioController.text = widget.producto['precio']?.toString() ?? '';
    _descripcionController.text = widget.producto['descripcion'] ?? '';
    _imagenesController.text = (widget.producto['imagenes'] != null &&
            widget.producto['imagenes'].isNotEmpty)
        ? widget.producto['imagenes'].first
        : '';

    _estadoSeleccionado = widget.producto['estado'] ?? 'pendiente';
    _categoriaSeleccionada = widget.producto['id_categoria']?.toString();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      // Crear instancia del provider
      CategoriasProvider categoriasProvider = CategoriasProvider();

      // Obtener las categorías desde la API
      List<dynamic> categorias = await categoriasProvider.getCategorias();

      // Actualizar el estado con las categorías obtenidas
      setState(() {
        _categorias.clear(); // Limpiar cualquier categoría previa
        _categorias.addAll(
          categorias.map((categoria) {
            return {
              'id_categoria': categoria['id_categoria'],
              'nombre': categoria['nombre'],
            };
          }).toList(),
        );
      });
    } catch (e) {
      // Manejo de errores
      print('Error al cargar las categorías: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar las categorías.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editarProducto() async {
    if (_formKey.currentState!.validate()) {
      final idCategoriaSeleccionada = _categorias.firstWhere(
        (categoria) => categoria['nombre'] == _categoriaSeleccionada,
      )['id_categoria'];

      final productoData = {
        'nombre': _nombreController.text,
        'precio': int.parse(_precioController.text),
        'descripcion': _descripcionController.text,
        'estado': _estadoSeleccionado,
        'id_categoria': idCategoriaSeleccionada,
        'imagenes': _imagenesController.text.isNotEmpty
            ? [_imagenesController.text]
            : [], // Si no hay imágenes, enviar una lista vacía
        'id_usuario':
            widget.producto['id_usuario'], // Mantener el usuario original
      };

      ProductosProvider productosProvider = ProductosProvider();
      Map<String, dynamic> respuesta = await productosProvider.editarProducto(
        productoData,
        widget.producto['id_producto'], // Enviar el ID del producto
      );

      if (respuesta['error'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(respuesta['message']),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto editado con éxito'),
            backgroundColor: Colors.green,
          ),
        );

        // Regresar con éxito
        Navigator.pop(context, true);
      }
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _nombreController.clear();
    _precioController.clear();
    _descripcionController.clear();
    _imagenesController.clear();
    setState(() {
      _categoriaSeleccionada = null;
      _estadoSeleccionado = 'pendiente';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Producto',
          style: TextStyle(fontFamily: 'FiraCode', fontSize: 15),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nombreController,
                  labelText: 'Nombre del Producto',
                  hintText: 'Ingresa el nombre del producto',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre del producto es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria['nombre'],
                      child: Text(categoria['nombre']),
                    );
                  }).toList(),
                  value: _categoriaSeleccionada,
                  labelText: 'Categoría',
                  hintText: 'Selecciona una categoría',
                  onChanged: (value) {
                    setState(() {
                      _categoriaSeleccionada = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _precioController,
                  labelText: 'Precio',
                  hintText: 'Ingresa el precio del producto',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El precio es obligatorio.';
                    }
                    if (int.tryParse(value) == null) {
                      return 'El precio debe ser un número válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descripcionController,
                  labelText: 'Descripción',
                  hintText: 'Describe brevemente el producto',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _imagenesController,
                  labelText: 'URL de Imagen',
                  hintText:
                      'Ingresa la URL de la imagen del producto (opcional)',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _editarProducto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff638B2E),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Editar Producto',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FiraCode',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required List<DropdownMenuItem<String>> items,
    required String? value,
    required String labelText,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.any((item) => item.value == value)
          ? value
          : null, // Validar si value está en items
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio.';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _imagenesController.dispose();
    super.dispose();
  }
}
