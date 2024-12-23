class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final bool watched;

  Movie({required this.id, required this.title, required this.description, required this.posterUrl, this.watched = false});

  // Méthodes pour la sérialisation/désérialisation avec Firestore.
  factory Movie.fromFirestore(Map<String, dynamic> data) {
    return Movie(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      watched: data['watched'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'watched': watched,
    };
  }
}
