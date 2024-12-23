import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieApiService {
  static const String apiKey = 'YOUR_TMDB_API_KEY';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  Future<Map<String, dynamic>?> fetchMovieDetails(String movieId) async {
    final url = '$baseUrl/movie/$movieId?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Erreur lors de la récupération des informations sur le film.');
      return null;
    }
  }
}
