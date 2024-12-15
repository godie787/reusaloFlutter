import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/eventos_provider.dart';
import 'package:flutter_reusalo/screens/tabs/eventos/crear_eventos_screen.dart';

class TabEventosScreen extends StatefulWidget {
  const TabEventosScreen({super.key});

  @override
  _TabEventosScreenState createState() => _TabEventosScreenState();
}

class _TabEventosScreenState extends State<TabEventosScreen> {
  List<Map<String, dynamic>> _eventos = []; // Lista para almacenar eventos
  bool _isLoading = true; // Bandera para mostrar el indicador de carga

  @override
  void initState() {
    super.initState();
    _obtenerEventos(); // Llamar al método para obtener los eventos al iniciar
  }

  Future<void> _obtenerEventos() async {
    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      EventosProvider eventosProvider = EventosProvider();
      List<dynamic> eventos = await eventosProvider.getEventos();

      setState(() {
        // Filtrar eventos con id_usuario = 3
        _eventos = eventos
            .cast<Map<String, dynamic>>()
            .where((evento) => evento['id_usuario'] == 3)
            .toList();
        _isLoading = false; // Ocultar indicador de carga
      });
    } catch (e) {
      print('Error al obtener eventos: $e');
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _obtenerEventos, // Permitir recargar los eventos deslizando
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget para Crear un Evento
            _CrearEventoWidget(onCrearEvento: _obtenerEventos),
            const SizedBox(height: 20),
            // Mostrar indicador de carga o los eventos
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEstados(), // Agregar leyenda
                      const SizedBox(height: 20),

                      _VerMisEventosWidget(eventos: _eventos),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstados() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLegendItem(Colors.yellow, "Pendiente"),
          _buildLegendItem(Colors.red, "Cancelado"),
          _buildLegendItem(Colors.green, "Activo"),
          _buildLegendItem(Colors.blue, "Finalizado"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: color,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}

class _CrearEventoWidget extends StatelessWidget {
  final VoidCallback onCrearEvento;

  _CrearEventoWidget({super.key, required this.onCrearEvento});

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
            'Crear un Evento',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'FredokaOne',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Organiza un nuevo evento para compartir con la comunidad.',
            style: TextStyle(
                fontSize: 14, color: Colors.grey, fontFamily: 'FiraCode'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrearEventoScreen(),
                ),
              );
              // Actualizar eventos después de crear uno
              onCrearEvento();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff638B2E),
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
                  fontFamily: 'FiraCode'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerMisEventosWidget extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;

  _VerMisEventosWidget({super.key, required this.eventos});

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
            'Mis Eventos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'FredokaOne',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Revisa y gestiona los eventos que has creado.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          eventos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No has creado eventos aún',
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
                    return _buildEventoItem(evento);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEventoItem(Map<String, dynamic> evento) {
    Color estadoColor;
    String estado = evento['estado'] ?? 'Desconocido';

    // Determinar color según estado
    switch (estado.toLowerCase()) {
      case 'pendiente':
        estadoColor = Colors.yellow;
        break;
      case 'cancelado':
        estadoColor = Colors.red;
        break;
      case 'activo':
        estadoColor = Colors.green;
        break;
      case 'finalizado':
        estadoColor = Colors.blue;
        break;
      default:
        estadoColor = Colors.grey; // Por defecto para estado desconocido
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(
        radius: 10,
        backgroundColor: estadoColor,
      ),
      title: Text(
        evento['nombre'] ?? 'Sin título',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${evento['fecha_inicio'] ?? 'Sin fecha'} - $estado',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      /*
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () {
          print('Editar evento: ${evento['nombre']}');
        },
      ),*/
    );
  }
}
