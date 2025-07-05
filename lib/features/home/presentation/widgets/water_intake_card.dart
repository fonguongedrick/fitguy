import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class WaterIntakeCard extends StatelessWidget {
  const WaterIntakeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Intake',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Icon(
                Icons.water_drop,
                color: Colors.blue.shade400,
                size: 20.h,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: CircularPercentIndicator(
              radius: 40.h,
              lineWidth: 8.w,
              percent: 0.6,
              center: Text(
                '1.8L',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              progressColor: Colors.blue.shade400,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              '6/10 glasses',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWaterCup(0.2, '250ml'),
              _buildWaterCup(0.4, '500ml'),
              _buildWaterCup(0.6, '750ml'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCup(double percent, String size) {
    return Column(
      children: [
        Container(
          height: 30.h,
          width: 30.h,
          decoration: BoxDecoration(
            color: percent <= 0.6 ? Colors.blue.shade100 : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.water_drop,
              color: percent <= 0.6 ? Colors.blue.shade400 : Colors.grey.shade400,
              size: 16.h,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          size,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}