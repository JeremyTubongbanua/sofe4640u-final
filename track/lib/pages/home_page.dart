import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'define_muscles_page.dart';
import 'define_exercises_page.dart';
import '../components/nav_bar.dart';

class HomePage extends StatefulWidget {
  static const String appBarTitle = 'Home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Bonjour')),
    );
  }
}
