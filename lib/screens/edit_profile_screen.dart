import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _favoriteGenreController = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = doc.data();
      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        _favoriteGenreController.text = userData['favoriteGenre'] ?? '';
        _photoUrlController.text = userData['photoUrl'] ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'favoriteGenre': _favoriteGenreController.text,
          'photoUrl': _photoUrlController.text,
        }, SetOptions(merge: true));

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context); // Retour à l'écran de profil après sauvegarde
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Éditer le Profil"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Nom"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre nom";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _favoriteGenreController,
                      decoration: InputDecoration(labelText: "Genre préféré"),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _photoUrlController,
                      decoration: InputDecoration(labelText: "URL de la photo de profil"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez fournir un lien d'image valide";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text("Sauvegarder"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
