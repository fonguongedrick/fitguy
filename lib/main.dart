import 'package:fitguy1/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:fitguy1/features/auth/presentation/pages/auth_page.dart';
import 'package:fitguy1/features/home/presentation/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitguy1/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fitguy1/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // ← Use your base design size (iPhone X by default)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            
            '/auth': (context) => const AuthPage(), // <-- Define the /auth route
            '/home': (context) => const HomePage(), // <-- Define the /home route=>
            '/admin':(context) => const AdminDashboardPage(), // <-- Define the /admin route
          },
          home: child,
        );
      },
      child: const OnboardingPage(),
    );
  }
}
