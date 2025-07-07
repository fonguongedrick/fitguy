import 'package:fitguy1/features/home/presentation/page/work_out_category_screen.dart';
import 'package:fitguy1/features/home/presentation/page/work_out_detail_screen.dart';
import 'package:flutter/material.dart';


class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Workouts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(),
              const SizedBox(height: 24),
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryGrid(),
              const SizedBox(height: 24),
              const Text(
                'Popular Workouts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildPopularWorkouts(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: Colors.white,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                const Text(
                  '3 of 5 workouts completed',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'icon': Icons.fitness_center, 'name': 'Strength', 'color': Colors.orange},
      {'icon': Icons.directions_run, 'name': 'Cardio', 'color': Colors.blue},
      {'icon': Icons.self_improvement, 'name': 'Yoga', 'color': Colors.green},
      {'icon': Icons.water, 'name': 'Swimming', 'color': Colors.teal},
      {'icon': Icons.pedal_bike, 'name': 'Cycling', 'color': Colors.red},
      {'icon': Icons.add, 'name': 'More', 'color': Colors.grey},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutCategoryScreen(
                  categoryName: categories[index]['name'] as String,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: (categories[index]['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: (categories[index]['color'] as Color).withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  categories[index]['icon'] as IconData,
                  size: 30,
                  color: categories[index]['color'] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: categories[index]['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularWorkouts(BuildContext context) {
    final workouts = [
      {
        'name': 'Full Body HIIT',
        'duration': '30 min',
        'calories': '250 kcal',
        'icon': Icons.bolt,
        'color': Colors.orange,
        'videos': [
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        ],
      },
      {
        'name': 'Upper Body Strength',
        'duration': '45 min',
        'calories': '320 kcal',
        'icon': Icons.fitness_center,
        'color': Colors.blue,
        'videos': [
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        ],
      },
      {
        'name': 'Yoga Flow',
        'duration': '40 min',
        'calories': '180 kcal',
        'icon': Icons.self_improvement,
        'color': Colors.green,
        'videos': [
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        ],
      },
    ];

    return Column(
      children: workouts.map((workout) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutDetailScreen(
                  workoutName: workout['name'] as String,
                  duration: workout['duration'] as String,
                  calories: workout['calories'] as String,
                  videos: (workout['videos'] as List<String>),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: (workout['color'] as Color).withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      workout['icon'] as IconData,
                      size: 50,
                      color: workout['color'] as Color,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildWorkoutInfo(
                              Icons.timer, workout['duration'] as String),
                          const SizedBox(width: 16),
                          _buildWorkoutInfo(
                            Icons.local_fire_department,
                            workout['calories'] as String,
                          ),
                          const Spacer(),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkoutInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 10,
      items: [
        _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
        _buildNavItem(Icons.fitness_center_outlined, Icons.fitness_center, 'Workouts'),
        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Meals'),
        _buildNavItem(Icons.analytics_outlined, Icons.analytics, 'Progress'),
        _buildNavItem(Icons.people_outline, Icons.people, 'Community'),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/');
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

  BottomNavigationBarItem _buildNavItem(
      IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}
