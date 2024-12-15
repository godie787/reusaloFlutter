import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductosProvider {
  final String apiURL = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> getProductos() async {
    var uri = Uri.parse('$apiURL/productos');
    var respuesta = await http.get(uri);
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> crearProducto(
      Map<String, dynamic> productData) async {
    var uri = Uri.parse('$apiURL/productos');

    try {
      var respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(productData),
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

  Future<Map<String, dynamic>> editarProducto(
      Map<String, dynamic> productData, int idProducto) async {
    var uri = Uri.parse('$apiURL/productos/$idProducto');

    try {
      var respuesta = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(productData),
      );

      if (respuesta.statusCode == 200) {
        return json.decode(respuesta.body);
      } else {
        return {
          'error': true,
          'message': 'Error al editar el producto: ${respuesta.body}',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Error al conectarse con el servidor: $e',
      };
    }
  }

  Future<Map<String, dynamic>> eliminarProducto(int idProducto) async {
    final response = await http.delete(
      Uri.parse('$apiURL/productos/$idProducto'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al eliminar el producto');
    }
  }
}
