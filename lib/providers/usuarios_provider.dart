import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuariosProvider {
  final String apiURL = 'http://10.0.2.2:8000/api';

  Future<Map<String, dynamic>> crearUsuario(Map<String, dynamic> data) async {
    var uri = Uri.parse('$apiURL/usuarios');
    try {
      var respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (respuesta.statusCode == 201) {
        return json.decode(respuesta.body);
      } else {
        return {
          'error': true,
          'message': 'Error al crear usuario: ${respuesta.body}',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
