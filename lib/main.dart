import 'package:flutter/material.dart';
import 'package:rdp_todo_list/screens/my_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rdp_todo_list/firebase_options.dart';

void main() async {
  //Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Firebase with the Current Platform's Default Options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RDP To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
