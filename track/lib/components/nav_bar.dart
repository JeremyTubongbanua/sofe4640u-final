import 'package:flutter/material.dart';
import 'package:track/pages/workouts_page.dart';
import 'package:track/pages/define_exercises_page.dart';
import 'package:track/pages/define_muscles_page.dart';
import 'package:track/pages/home_page.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: HomePage.appBarTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: DefineMusclesPage.appBarTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: DefineExercisesPage.appBarTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: WorkoutsPage.appBarTitle,
        ),
      ],
    );
  }
}
