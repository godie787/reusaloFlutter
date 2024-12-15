import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/eventos_provider.dart';
import 'package:http/http.dart' as http;

class CrearEventoScreen extends StatefulWidget {
  const CrearEventoScreen({super.key});

  @override
  _CrearEventoScreenState createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaTerminoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  String? _tipoEventoSeleccionado;
  List<Map<String, dynamic>> _tiposEvento =
      []; // Lista de mapas para id_tipo y nombre_tipo

  @override
  void initState() {
    super.initState();
    _cargarTiposDeEvento();
  }

  Future<void> _cargarTiposDeEvento() async {
    try {
      EventosProvider tiposEventoProvider = EventosProvider();
      List<dynamic> tipos = await tiposEventoProvider.getTiposEvento();

      setState(() {
        _tiposEvento = tipos.map<Map<String, dynamic>>((tipo) {
          return {
            'id_tipo': tipo['id_tipo'],
            'nombre_tipo': tipo['nombre_tipo'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error al obtener tipos de evento: $e');
      setState(() {
        _tiposEvento = []; // En caso de error, lista vacía
      });
    }
  }

  void _crearEvento() async {
    if (_formKey.currentState!.validate()) {
      // Buscar el id_tipo correspondiente al nombre seleccionado
      int? idTipoSeleccionado = _tiposEvento.firstWhere(
          (tipo) => tipo['nombre_tipo'] == _tipoEventoSeleccionado)['id_tipo'];
      // Crear el mapa con los datos del formulario
      Map<String, dynamic> eventoData = {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'fecha_inicio': _fechaInicioController.text.isNotEmpty
            ? _fechaInicioController.text
            : null,
        'fecha_termino': _fechaTerminoController.text.isNotEmpty
            ? _fechaTerminoController.text
            : null,
        'ubicacion': _ubicacionController.text,
        'id_tipo': idTipoSeleccionado, // Usar el id_tipo seleccionado
        'id_usuario': 3
      };

      EventosProvider eventosProvider = EventosProvider();
      Map<String, dynamic> respuesta =
          await eventosProvider.crearEvento(eventoData);

      if (respuesta['error'] == true) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(respuesta['message']),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Mostrar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento creado con éxito'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar el formulario
        _limpiarFormulario();
      }
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset(); // Limpia el estado del formulario
    _nombreController.clear();
    _descripcionController.clear();
    _fechaInicioController.clear();
    _fechaTerminoController.clear();
    _ubicacionController.clear();

    setState(() {
      _tipoEventoSeleccionado = null; // Reinicia el dropdown
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Evento',
          style: TextStyle(fontFamily: 'FiraCode', fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nombreController,
                labelText: 'Nombre del Evento',
                hintText: 'Ingresa el nombre del evento',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del evento es obligatorio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descripcionController,
                labelText: 'Descripción',
                hintText: 'Describe brevemente el evento',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es obligatoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fechaInicioController,
                labelText: 'Fecha de Inicio',
                hintText: 'Selecciona la fecha de inicio',
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await _selectDate(context);
                  if (selectedDate != null) {
                    _fechaInicioController.text =
                        selectedDate.toLocal().toString().split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fechaTerminoController,
                labelText: 'Fecha de Término',
                hintText: 'Selecciona la fecha de término',
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await _selectDate(context);
                  if (selectedDate != null) {
                    _fechaTerminoController.text =
                        selectedDate.toLocal().toString().split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ubicacionController,
                labelText: 'Ubicación',
                hintText: 'Ingresa la ubicación del evento',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La ubicación es obligatoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _crearEvento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff638B2E),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Crear Evento',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
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

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _tipoEventoSeleccionado,
      items: _tiposEvento.map((tipo) {
        return DropdownMenuItem<String>(
          value: tipo['nombre_tipo'], // Mostrar el nombre del tipo
          child: Text(tipo['nombre_tipo']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _tipoEventoSeleccionado = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Tipo de Evento',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Elige un tipo de evento.';
        }
        return null;
      },
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }
}
