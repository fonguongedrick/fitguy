import 'package:flutter/material.dart';

BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.deepPurple,
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    backgroundColor: Colors.white,
    elevation: 10,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.fitness_center_outlined),
        activeIcon: Icon(Icons.fitness_center),
        label: 'Workouts',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu_outlined),
        activeIcon: Icon(Icons.restaurant_menu),
        label: 'Meals',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Progress',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Community',
      ),
    ],
    onTap: (index) {
      if (index == 0) {
        Navigator.pushNamed(context, '/');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/workouts');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/meal-plans');
      } else if (index == 3) {
        Navigator.pushNamed(context, '/progress');
      } else if (index == 4) {
        Navigator.pushNamed(context, '/community');
      }
    },
  );
}
