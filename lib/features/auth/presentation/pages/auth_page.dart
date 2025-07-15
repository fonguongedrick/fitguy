import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitguy1/core/theme/app_theme.dart';
import 'package:fitguy1/features/auth/presentation/widgets/auth_switch_button.dart';
import 'package:fitguy1/features/auth/presentation/widgets/login_form.dart';
import 'package:fitguy1/features/auth/presentation/widgets/signup_form.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPage extends ConsumerStatefulWidget {
 

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool isLogin = true;

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),
                // App logo and title
                Hero(
                  tag: 'app-logo',
                  child: Container(
                    height: 100.h,
                    width: 100.h,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 50.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Fit Guy',
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isLogin ? 'Welcome back!' : 'Create your account',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 32.h),
                // Auth forms
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLogin
                      ? const LoginForm(key: ValueKey('login-form'))
                      : const SignupForm(key: ValueKey('signup-form')),
                ),
                SizedBox(height: 24.h),
                // Switch between login and signup
                AuthSwitchButton(
                  isLogin: isLogin,
                  onTap: toggleAuthMode,
                ),
                SizedBox(height: 24.h),
                // Or continue with
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Or continue with',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      onPressed: () {},
                    ),
                    SizedBox(width: 16.w),
                    SocialLoginButton(
                      icon: Icons.facebook,
                      onPressed: () {},
                    ),
                    SizedBox(width: 16.w),
                    SocialLoginButton(
                      icon: Icons.apple,
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50.h,
        width: 50.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24.h,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}