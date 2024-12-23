import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMovieScreen extends StatefulWidget {
  final Function(String, String, String, int, String, String) onAddMovie;

  AddMovieScreen({required this.onAddMovie});

  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _trailerUrl = '';
  int _duration = 0;
  String _genre = '';
  String _status = 'À voir';
  bool _isLoading = false;

  Future<void> _submitMovie() async {
    if (_formKey.currentState!.validate()) {
      // Disable button immediately
      if (_isLoading) return;
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Generate a unique document ID for each movie based on userId and title
      final docId = '${currentUser.uid}_${_title.trim().toLowerCase()}';
      final movieRef = FirebaseFirestore.instance.collection('movies').doc(docId);

      try {
        final movieSnapshot = await movieRef.get();

        if (movieSnapshot.exists) {
          print("Duplicate movie detected. Skipping addition.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ce film existe déjà dans votre collection.")),
          );
        } else {
          // Set the document with a unique ID to prevent duplicates
          await movieRef.set({
            'title': _title,
            'description': _description,
            'trailerUrl': _trailerUrl,
            'duration': _duration,
            'genre': _genre,
            'status': _status,
            'userId': currentUser.uid,
          });

          widget.onAddMovie(_title, _description, _trailerUrl, _duration, _genre, _status);
          print("Movie added successfully to Firestore.");
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout du film : $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Film")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                onChanged: (value) => _title = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
                onChanged: (value) => _description = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'URL Bande-Annonce'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'URL de la bande-annonce';
                  }
                  return null;
                },
                onChanged: (value) => _trailerUrl = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Durée (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la durée';
                  }
                  return null;
                },
                onChanged: (value) => _duration = int.tryParse(value) ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Genre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le genre';
                  }
                  return null;
                },
                onChanged: (value) => _genre = value,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Visionné', 'À voir']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value ?? 'À voir';
                  });
                },
                decoration: InputDecoration(labelText: 'Statut'),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitMovie,
                      child: Text("Ajouter le Film"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
