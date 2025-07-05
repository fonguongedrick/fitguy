import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthSwitchButton extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onTap;

  const AuthSwitchButton({
    super.key,
    required this.isLogin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontSize: 14.sp,
                ),
              ),
              TextSpan(
                text: isLogin ? 'Sign Up' : 'Login',
                style: GoogleFonts.poppins(
                  color: theme.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}