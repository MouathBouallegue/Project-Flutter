import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// Définissez les options Firebase en utilisant `FirebaseOptions`
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyA3NI4X1Fc0y_LnoPWTF9EaaRj3gWY3Msg",
  authDomain: "moviemate-13d1c.firebaseapp.com",
  projectId: "moviemate-13d1c",
  storageBucket: "moviemate-13d1c.appspot.com",
  messagingSenderId: "1089333517394",
  appId: "1:1089333517394:web:644f01f6be617dd670938b",
  measurementId: "G-PT9BZB2CE2",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptions, // Spécifiez les options ici pour le Web
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Collection de Films',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Désactive le label DEBUG

      initialRoute: '/', // Route par défaut
      routes: {
        '/': (context) => LoginScreen(), // Écran de connexion par défaut
        '/home': (context) => HomeScreen(), // Route vers HomeScreen
        '/login': (context) => LoginScreen(), // Login screen route

      },
    );
  }
}
