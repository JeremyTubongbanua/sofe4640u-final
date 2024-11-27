import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track/pages/workouts_page.dart';
import 'package:track/pages/login_page.dart';
import 'home_page.dart';
import 'define_muscles_page.dart';
import 'define_exercises_page.dart';
import '../components/nav_bar.dart';

// holds several pages:
// - Home
// - Define Muscles
// - Define Exercises
// - Workouts
class AppPage extends StatefulWidget {
  static const String routeName = '/app';

  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int _currentIndex = 0;

  static const List<String> _appBarTitles = [
    HomePage.appBarTitle,
    DefineMusclesPage.appBarTitle,
    DefineExercisesPage.appBarTitle,
    WorkoutsPage.appBarTitle,
  ];

  static const List<Widget> _pages = [
    HomePage(),
    DefineMusclesPage(),
    DefineExercisesPage(),
    WorkoutsPage(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');

    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginPage.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/logo.png',
                height: 24, // Adjust as needed
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(_appBarTitles[_currentIndex]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
