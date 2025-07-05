import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitguy1/core/constants/app_constants.dart';
import 'package:fitguy1/core/theme/app_theme.dart';
import 'package:fitguy1/features/workouts/presentation/widgets/workout_category_card.dart';
import 'package:fitguy1/features/workouts/presentation/widgets/workout_filter_chip.dart';
import 'package:fitguy1/features/workouts/presentation/widgets/workout_item_card.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutsPage extends ConsumerStatefulWidget {
  const WorkoutsPage({super.key});

  @override
  ConsumerState<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends ConsumerState<WorkoutsPage> {
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'Beginner';
  String _selectedGoal = 'Weight Loss';

  final List<String> categories = [
    'All',
    'Cardio',
    'Strength',
    'Yoga',
    'Local',
    'No Equipment',
  ];

  final List<String> difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<String> goals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workouts',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              // Categories horizontal list
              SizedBox(
                height: 100.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return WorkoutCategoryCard(
                      category: categories[index],
                      isSelected: _selectedCategory == categories[index],
                      onTap: () {
                        setState(() {
                          _selectedCategory = categories[index];
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    WorkoutFilterChip(
                      label: 'Difficulty',
                      options: difficulties,
                      selectedOption: _selectedDifficulty,
                      onSelected: (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    WorkoutFilterChip(
                      label: 'Goal',
                      options: goals,
                      selectedOption: _selectedGoal,
                      onSelected: (value) {
                        setState(() {
                          _selectedGoal = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Workout list
              Text(
                'Recommended Workouts',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  return WorkoutItemCard(
                    title: 'Full Body Workout',
                    duration: '30 min',
                    difficulty: 'Beginner',
                    calories: '250 kcal',
                    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
                    onTap: () {
                      Navigator.pushNamed(context, '/workout-detail');
                    },
                  );
                },
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}