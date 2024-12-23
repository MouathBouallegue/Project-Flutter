import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> _movies = [];

  List<Movie> get movies => _movies;

  Future<void> fetchMovies() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('movies').get();
    _movies = snapshot.docs.map((doc) => Movie.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
    notifyListeners();
  }

  Future<void> addMovie(Movie movie) async {
    await FirebaseFirestore.instance.collection('movies').add(movie.toFirestore());
    _movies.add(movie);
    notifyListeners();
  }

  Future<void> markAsWatched(String movieId) async {
    final movie = _movies.firstWhere((movie) => movie.id == movieId);
    movie.watched = true;
    await FirebaseFirestore.instance.collection('movies').doc(movieId).update({'watched': true});
    notifyListeners();
  }
}
