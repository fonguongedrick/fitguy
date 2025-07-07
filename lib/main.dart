import 'package:fitguy1/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';

import 'features/home/presentation/page/Meal_detailed_screen.dart';
import 'features/home/presentation/page/community_screen.dart';
import 'features/home/presentation/page/home_screen.dart';
import 'features/home/presentation/page/meal_plan_screen.dart';
import 'features/home/presentation/page/progress_screen.dart';
import 'features/home/presentation/page/work_out_details_screen.dart';
import 'features/home/presentation/page/work_out_screen.dart';

void main() => runApp(const CameroonFitApp());

class CameroonFitApp extends StatelessWidget {
  const CameroonFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CameroonFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/workouts': (context) => const WorkoutsScreen(),
        '/meal-plans': (context) => const MealPlansScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/community': (context) => const CommunityScreen(),
        '/workout-detail': (context) => WorkoutDetailsScreen(),
        '/meal-detail': (context) => const MealDetailScreen(),
        "/authPage": (context) => const AuthPage(),
      },
    );
  }
}

