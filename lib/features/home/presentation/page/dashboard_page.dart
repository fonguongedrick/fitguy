import 'package:fitguy1/features/home/presentation/page/community_screen.dart';
import 'package:fitguy1/features/home/presentation/page/home_screen.dart';
import 'package:fitguy1/features/home/presentation/page/meal_plan_screen.dart';
import 'package:fitguy1/features/home/presentation/page/progress_screen.dart';
import 'package:fitguy1/features/home/presentation/page/work_out_screen.dart';
import 'package:flutter/material.dart';



class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages =  [
    HomeScreen(),
    WorkoutsScreen(),
    MealPlansScreen(),
    ProgressScreen(),
    CommunityScreen()

  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onTabTapped,
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
            icon: Icon(Icons.restaurant_menu,),
            activeIcon: Icon(Icons.person),
            label: 'Meals',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Community',
          ),
        ],
      ),
    );
  }
}
