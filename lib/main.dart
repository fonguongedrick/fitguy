import 'package:fitguy1/features/home/presentation/page/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pages
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/page/home_screen.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp();

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("🔥 Firebase init failed: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Determines the correct screen to launch at startup
  Future<Widget> _getStartScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboardingDone') ?? false;
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!onboardingDone) return const OnboardingPage();
      if (!isLoggedIn) return  AuthPage();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return  AuthPage(); // Redundant safety check

      final doc = await FirebaseFirestore.instance
          .collection('users_fitguy')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'user';

      return role == 'admin'
          ? const AdminDashboardScreen()
          : const DashboardPage();
    } catch (e) {
      debugPrint("🚨 Error in _getStartScreen: $e");
      return  OnboardingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CameroonFit',
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
        home: FutureBuilder<Widget>(
          future: _getStartScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('❗ Something went wrong'),
                      Text(snapshot.error.toString()),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => (context as Element).markNeedsBuild(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return snapshot.data ??  AuthPage();
          },
        ),
      ),
    );
  }
}
