import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:fitguy1/features/onboarding/presentation/pages/onboarding_page.dart';
 

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;
  final bool isLastPage;
  final VoidCallback onGetStarted;

  const OnboardingContent({
    super.key,
    required this.item,
    required this.isLastPage,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          SizedBox(
            height: 300.h,
            child: Animate(
  effects: [
    FadeEffect(duration: 500.ms),
    ScaleEffect(duration: 300.ms, delay: 200.ms),
  ],
  child: Lottie.asset(
    item.lottieAsset,
    fit: BoxFit.contain,
  ),
)

          ),
          SizedBox(height: 32.h),
          // Title
          Text(
            item.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .then(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: 16.h),
          // Description
          Text(
            item.description,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .then(delay: 300.ms)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: 32.h),
          // Get started button (only on last page)
          if (isLastPage)
            ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 12.h,
                ),
                elevation: 4,
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  color: item.backgroundColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .then(delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}