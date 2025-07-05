import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitguy1/core/constants/app_constants.dart';
import 'package:fitguy1/core/theme/app_theme.dart';
import 'package:fitguy1/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Welcome to Fit Guy',
      description: 'Your personal fitness companion for achieving your health goals',
      lottieAsset: 'assets/animations/welcome_fitness.json',
      backgroundColor: const Color(0xFF2ECC71),
    ),
    OnboardingItem(
      title: 'Tailored Workouts',
      description: 'Customized workout plans based on your goals and fitness level',
      lottieAsset: 'assets/animations/workout_animation.json',
      backgroundColor: const Color(0xFFF39C12),
    ),
    OnboardingItem(
      title: 'Local Nutrition',
      description: 'Meal plans using Cameroon\'s local food composition',
      lottieAsset: 'assets/animations/nutrition_animation.json',
      backgroundColor: const Color(0xFF3498DB),
    ),
    OnboardingItem(
      title: 'Track Progress',
      description: 'Monitor your fitness journey with detailed analytics',
      lottieAsset: 'assets/animations/progress_animation.json',
      backgroundColor: const Color(0xFF9B59B6),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Scaffold(
      backgroundColor: onboardingItems[_currentPage].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingItems.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingContent(
                    item: onboardingItems[index],
                    isLastPage: index == onboardingItems.length - 1,
                    onGetStarted: () {
                      // Navigate to auth screen
                      Navigator.pushReplacementNamed(context, '/auth');
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 24.h,
                horizontal: 16.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (only show if not on last page)
                  if (_currentPage != onboardingItems.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          onboardingItems.length - 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingItems.length,
                    effect: WormEffect(
                      dotHeight: 8.h,
                      dotWidth: 8.w,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  // Next/Get Started button
                  if (_currentPage != onboardingItems.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: onboardingItems[_currentPage].backgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        
                        Navigator.pushReplacementNamed(context, '/homescreen');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: onboardingItems[_currentPage].backgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String lottieAsset;
  final Color backgroundColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.backgroundColor,
  });
}