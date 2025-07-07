import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl:
                'https://images.unsplash.com/photo-1490645935967-10de6ba17061',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Healthy Avocado Toast',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMealInfo(Icons.timer, '10 min'),
                const SizedBox(width: 16),
                _buildMealInfo(Icons.local_fire_department, '320 kcal'),
                const SizedBox(width: 16),
                _buildMealInfo(Icons.star, '4.8'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildIngredient('Whole grain bread', '2 slices'),
            _buildIngredient('Avocado', '1 medium'),
            _buildIngredient('Cherry tomatoes', '5-6 pieces'),
            _buildIngredient('Eggs', '2'),
            _buildIngredient('Salt & pepper', 'To taste'),
            const SizedBox(height: 16),
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInstructionStep(1, 'Toast the bread until golden brown'),
            _buildInstructionStep(2, 'Mash the avocado and spread on toast'),
            _buildInstructionStep(3, 'Slice cherry tomatoes and add on top'),
            _buildInstructionStep(4, 'Poach or fry the eggs and place on top'),
            _buildInstructionStep(5, 'Season with salt and pepper to taste'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  'Add to Meal Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _buildIngredient(String name, String quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(name),
          const Spacer(),
          Text(
            quantity,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
