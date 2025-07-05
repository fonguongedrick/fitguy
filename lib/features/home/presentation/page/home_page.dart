import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitguy1/core/constants/app_constants.dart';
import 'package:fitguy1/core/theme/app_theme.dart';
import 'package:fitguy1/features/home/presentation/widgets/activity_card.dart';
import 'package:fitguy1/features/home/presentation/widgets/daily_goal_card.dart';
import 'package:fitguy1/features/home/presentation/widgets/greeting_card.dart';
import 'package:fitguy1/features/home/presentation/widgets/progress_chart.dart';
import 'package:fitguy1/features/home/presentation/widgets/water_intake_card.dart';
import 'package:fitguy1/features/home/presentation/widgets/workout_plan_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Fit Guy',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Text(''),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  // Greeting card
                  const GreetingCard(),
                  SizedBox(height: 16.h),
                  // Daily goal card
                  const DailyGoalCard(),
                  SizedBox(height: 16.h),
                  // Workout plan card
                  const WorkoutPlanCard(),
                  SizedBox(height: 16.h),
                  // Progress chart
                  const ProgressChart(),
                  SizedBox(height: 16.h),
                  // Activity and water intake row
                  Row(
                    children: [
                      Expanded(
                        child: const ActivityCard(),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: const WaterIntakeCard(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Motivational quote
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Motivational Quote',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'The only bad workout is the one that didn\'t happen. Keep pushing!',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}