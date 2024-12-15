import 'package:flutter/material.dart';
import 'package:flutter_reusalo/providers/eventos_provider.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  EventosProvider eventosProvider = EventosProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Próximas ferias y eventos',
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
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder(
                  future: eventosProvider.getEventos(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Filtrar eventos con estado 'activo'
                    final eventosActivos = snapshot.data
                        .where((evento) =>
                            evento['estado']?.toLowerCase() == 'activo')
                        .toList();

                    if (eventosActivos.isEmpty) {
                      return const Center(
                        child: Text('No hay eventos activos disponibles.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: eventosActivos.length,
                      itemBuilder: (context, index) {
                        final evento = eventosActivos[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Bordes redondeados
                          ),
                          elevation: 3, // Elevación para una sombra suave
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            leading: const Icon(
                              Icons.event, // Ícono específico de eventos
                              color: Colors.blueAccent, // Color del ícono
                              size: 30, // Tamaño del ícono
                            ),
                            title: Text(
                              evento['nombre'] ?? 'Evento sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, // Texto en negrita
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              evento['fecha_inicio'] ?? 'Fecha no disponible',
                              style: TextStyle(
                                color:
                                    Colors.grey[600], // Color sutil para el subtítulo
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  evento['ubicacion'] ?? 'Ubicación no definida',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            onTap: () {
                              print("Presionando evento: ${evento['nombre']}");
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
