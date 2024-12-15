import 'package:http/http.dart' as http;
import 'dart:convert';

class VentasProvider {
  final String apiURL = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> getVentas() async {
    var uri = Uri.parse('$apiURL/ventas');
    var respuesta = await http.get(uri);
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> crearVenta(
      Map<String, dynamic> ventaData) async {
    var uri = Uri.parse('$apiURL/ventas');

    try {
      var respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(ventaData),
      );

      if (respuesta.statusCode == 201) {
        return json.decode(respuesta.body);
      } else {
        return {
          'error': true,
          'message': 'Error al crear el la venta: ${respuesta.body}',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Error al conectarse con el servidor: $e',
      };
    }
  }

  
}
