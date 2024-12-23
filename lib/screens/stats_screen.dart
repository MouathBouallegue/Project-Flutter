import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Statistiques de la Collection"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('movies')
            .where('userId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Aucune donnée disponible."));
          }

          // Utiliser un Set pour éviter les doublons
          final uniqueMovies = <String>{};
          final filteredMovies = snapshot.data!.docs.where((movie) {
            final data = movie.data() as Map<String, dynamic>;
            final uniqueIdentifier = '${data['title']}_${data['description']}';

            // Ajoutez au Set uniquement si l'identifiant est unique
            if (uniqueMovies.contains(uniqueIdentifier)) {
              return false;
            } else {
              uniqueMovies.add(uniqueIdentifier);
              return true;
            }
          }).toList();

          int totalMovies = filteredMovies.length;
          print("Nombre de films chargés depuis Firestore pour cet utilisateur (unique) : $totalMovies");

          int totalDuration = filteredMovies.fold(0, (sum, movie) {
            final data = movie.data() as Map<String, dynamic>;
            return sum + (data.containsKey('duration') ? (data['duration'] as int) : 0);
          });

          int watchedCount = filteredMovies.where((movie) {
            final data = movie.data() as Map<String, dynamic>;
            return data['status'] == 'Visionné';
          }).length;

          int toWatchCount = filteredMovies.where((movie) {
            final data = movie.data() as Map<String, dynamic>;
            return data['status'] == 'À voir';
          }).length;

          // Répartition des genres
          Map<String, int> genreCount = {};
          for (var movie in filteredMovies) {
            final data = movie.data() as Map<String, dynamic>;
            String genre = data['genre'] ?? 'Inconnu';
            genreCount[genre] = (genreCount[genre] ?? 0) + 1;
          }

          List<ChartData> genreChartData = genreCount.entries
              .map((entry) => ChartData(entry.key, entry.value.toDouble()))
              .toList();

          List<ChartData> statusChartData = [
            ChartData('Visionné', watchedCount.toDouble()),
            ChartData('À voir', toWatchCount.toDouble()),
          ];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Statistiques de la Collection",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text("Films ajoutés : $totalMovies"),
                  Text("Films visionnés : $watchedCount"),
                  Text("Films à voir : $toWatchCount"),
                  Text("Durée totale de visionnage : $totalDuration minutes"),
                  SizedBox(height: 24),

                  Text(
                    "Répartition par genre :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  SfCircularChart(
                    legend: Legend(isVisible: true, position: LegendPosition.right),
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        dataSource: genreChartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  Text(
                    "Répartition des films Visionnés et À voir :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  SfCircularChart(
                    legend: Legend(isVisible: true, position: LegendPosition.right),
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        dataSource: statusChartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Classe pour les données du graphique
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
