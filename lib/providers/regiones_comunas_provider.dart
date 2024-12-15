import 'dart:convert';
import 'package:http/http.dart' as http;

class RegionesComunasProvider {
  final String apiURL = 'https://apis.digital.gob.cl/dpa';

  Future<List<dynamic>> getRegiones() async {
    final url = Uri.parse('$apiURL/regiones');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener las regiones');
    }
  }

  Future<List<dynamic>> getComunas(String codigoRegion) async {
    final url = Uri.parse('$apiURL/regiones/$codigoRegion/comunas');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener las comunas');
    }
  }
}
