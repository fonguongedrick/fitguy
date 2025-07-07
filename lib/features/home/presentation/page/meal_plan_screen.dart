import 'package:flutter/material.dart';

class MealPlansScreen extends StatelessWidget {
  const MealPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Meal Plans',
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
              _buildNutritionCard(),
              const SizedBox(height: 24),
              const Text(
                'Meal Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMealCategories(),
              const SizedBox(height: 24),
              const Text(
                'Popular Plans',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildPopularPlans(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }

  Widget _buildNutritionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.food_bank, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Nutrition',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNutritionProgress('Calories', 1850, 2200, Colors.orange),
                const SizedBox(height: 4),
                _buildNutritionProgress('Protein', 120, 150, Colors.blue),
                const SizedBox(height: 4),
                _buildNutritionProgress('Carbs', 210, 300, Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionProgress(String label, int current, int target, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            Text(
              '$current / $target',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: current / target,
          backgroundColor: Colors.white.withOpacity(0.3),
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildMealCategories() {
    final categories = [
      {'icon': Icons.breakfast_dining, 'name': 'Breakfast'},
      {'icon': Icons.lunch_dining, 'name': 'Lunch'},
      {'icon': Icons.dinner_dining, 'name': 'Dinner'},
      {'icon': Icons.local_cafe, 'name': 'Snacks'},
      {'icon': Icons.local_drink, 'name': 'Drinks'},
      {'icon': Icons.add, 'name': 'More'},
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
        return Container(
          decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categories[index]['icon'] as IconData,
                size: 30,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                categories[index]['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularPlans() {
    final plans = [
      {
        'name': 'Keto Diet',
        'meals': '5 meals/day',
        'calories': '1800 kcal',
        'icon': Icons.local_fire_department,
        'color': Colors.purple,
      },
      {
        'name': 'High Protein',
        'meals': '6 meals/day',
        'calories': '2200 kcal',
        'icon': Icons.fitness_center,
        'color': Colors.blue,
      },
      {
        'name': 'Vegetarian',
        'meals': '4 meals/day',
        'calories': '2000 kcal',
        'icon': Icons.eco,
        'color': Colors.green,
      },
    ];

    return Column(
      children: plans.map((plan) {
        return Container(
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
                  color: (plan['color'] as Color).withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    plan['icon'] as IconData,
                    size: 50,
                    color: plan['color'] as Color,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPlanInfo(Icons.restaurant, plan['meals'] as String),
                        const SizedBox(width: 16),
                        _buildPlanInfo(
                          Icons.local_fire_department,
                          plan['calories'] as String,
                        ),
                        const Spacer(),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        const Text(
                          '4.7',
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
        );
      }).toList(),
    );
  }

  Widget _buildPlanInfo(IconData icon, String text) {
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
        } else if (index == 1) {
          Navigator.pushNamed(context, '/workouts');
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
