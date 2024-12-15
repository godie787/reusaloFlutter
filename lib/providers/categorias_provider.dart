import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriasProvider {
  final String apiURL = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> getCategorias() async {
    var uri = Uri.parse('$apiURL/categorias');
    var respuesta = await http.get(uri);
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      return [];
    }
  }
}
