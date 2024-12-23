import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Importez `dart:html` uniquement si l'application s'exécute sur le Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui; // Utilisé pour enregistrer l'iframe sur Flutter Web

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;
  final String movieTitle;
  final String trailerUrl;

  MovieDetailsScreen({
    required this.movieId,
    required this.movieTitle,
    required this.trailerUrl,
  });

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Enregistrer un élément HTML pour Flutter Web (iframe pour YouTube)
      final videoId = widget.trailerUrl.split("v=").last;
      // Identifier l'iframe
      ui.platformViewRegistry.registerViewFactory(
        'youtube-iframe',
        (int viewId) => html.IFrameElement()
          ..width = '100%'
          ..height = '315'
          ..src = 'https://www.youtube.com/embed/$videoId'
          ..style.border = 'none',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movieTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              "ID du film : ${widget.movieId}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              "Description du film...",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            if (kIsWeb)
              SizedBox(
                height: 315,
                child: HtmlElementView(viewType: 'youtube-iframe'),
              )
            else
              Center(
                child: Text(
                  "La lecture de vidéos intégrées est uniquement disponible sur Flutter Web.",
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

