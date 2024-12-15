import 'package:http/http.dart' as http;
import 'dart:convert';

class EventosProvider {
  final String apiURL = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> getEventos() async {
    var uri = Uri.parse('$apiURL/eventos');
    var respuesta = await http.get(uri);
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      return [];
    }
  }

  Future<List<dynamic>> getTiposEvento() async {
    var uri = Uri.parse('$apiURL/tipos-eventos');
    var respuesta = await http.get(uri);
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> crearEvento(
      Map<String, dynamic> eventoData) async {
    var uri = Uri.parse('$apiURL/eventos');

    try {
      var respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(eventoData),
      );

      if (respuesta.statusCode == 201) {
        return json.decode(respuesta.body);
      } else {
        return {
          'error': true,
          'message': 'Error al crear el evento: ${respuesta.body}',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Error al conectarse con el servidor: $e',
      };
    }
  }

  Future<Map<String, dynamic>> actualizarEvento(
      int id, Map<String, dynamic> eventoData) async {
    var uri = Uri.parse('$apiURL/eventos/$id');
    print('Datos enviados al servidor: $eventoData');

    try {
      var respuesta = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(eventoData),
      );

      print('Respuesta completa del servidor: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        return json.decode(respuesta.body);
      } else {
        return {
          'error': true,
          'message': 'Error al actualizar el evento: ${respuesta.body}',
        };
      }
    } catch (e) {
      print('Error de conexión: $e');
      return {
        'error': true,
        'message': 'Error al conectarse con el servidor: $e',
      };
    }
  }
}
