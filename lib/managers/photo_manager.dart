import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:quid_faciam_hodie/constants/apis.dart';

class PhotoManager {
  static const MAX_PHOTOS_PER_PAGE = 80;

  // Searches for photos based on `query` and returns a random one.
  static Future<String> getRandomPhoto(final String query) async {
    final url =
        'https://api.pexels.com/v1/search?query=$query&per_page=$MAX_PHOTOS_PER_PAGE&orientation=portait';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': PEXELS_API_KEY,
      },
    );
    final data = jsonDecode(response.body);
    final photoIndex = Random().nextInt(data['per_page']);

    return data['photos'][photoIndex]['src']['portrait'];
  }
}
