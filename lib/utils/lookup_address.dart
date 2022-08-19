import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> lookupAddress({
  required final double latitude,
  required final double longitude,
}) async {
  final url = 'https://geocode.maps.co/reverse?lat=$latitude&lon=$longitude';
  final uri = Uri.parse(url);

  final response = await http.get(uri);

  return jsonDecode(response.body)['display_name'];
}
