// Importing necessary packages
import 'package:flutter/material.dart';
//TODO Reinitialize this project with firebase and add the corresponding firebase_options.dart file
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'welcome_screen.dart';

// Entry point of the application
void main() async {
  // Ensure that widget binding is initialized before any other operation
  WidgetsFlutterBinding.ensureInitialized();

  // // Initialize Firebase with the default options for the current platform
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Run the main application widget
  runApp(const MyApp());
}

// The main application widget
class MyApp extends StatelessWidget {
  // Constructor with optional key parameter passed to the superclass
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBD - To be Diagnosed',  // Title for the application
      theme: ThemeData(
        // Define a custom color scheme based on a seed color
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2A3C93)),
        useMaterial3: true,  // Use Material 3 (M3) design system
      ),
      // Set the WelcomeScreen as the initial screen of the application
      home: WelcomeScreen(),
    );
  }
}