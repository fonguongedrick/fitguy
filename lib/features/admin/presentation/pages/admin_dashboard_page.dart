import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitguy1/core/constants/app_constants.dart';
import 'package:fitguy1/core/theme/app_theme.dart';
import 'package:fitguy1/features/admin/presentation/widget/admin_stat_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              // Stats cards
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                children: const [
                  AdminStatCard(
                    title: 'Total Users',
                    value: '1,254',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  AdminStatCard(
                    title: 'Active Users',
                    value: '856',
                    icon: Icons.people_alt,
                    color: Colors.green,
                  ),
                  AdminStatCard(
                    title: 'Workouts',
                    value: '142',
                    icon: Icons.fitness_center,
                    color: Colors.orange,
                  ),
                  AdminStatCard(
                    title: 'Meal Plans',
                    value: '68',
                    icon: Icons.restaurant,
                    color: Colors.purple,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // User activity chart
              Container(
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
                    Text(
                      'User Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
  height: 250.h,
  child: SfCartesianChart(
    primaryXAxis: CategoryAxis(),
    series: <CartesianSeries<ChartData, String>>[
      ColumnSeries<ChartData, String>(
        dataSource: [
          ChartData('Mon', 120),
          ChartData('Tue', 150),
          ChartData('Wed', 180),
          ChartData('Thu', 200),
          ChartData('Fri', 240),
          ChartData('Sat', 180),
          ChartData('Sun', 160),
        ],
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        color: theme.primaryColor,
      )
    ],
  ),
)
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Quick actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                children: [
                  _buildQuickAction(
                    icon: Icons.add,
                    label: 'Add Workout',
                    onTap: () {},
                    color: Colors.blue,
                  ),
                  _buildQuickAction(
                    icon: Icons.add,
                    label: 'Add Meal',
                    onTap: () {},
                    color: Colors.green,
                  ),
                  _buildQuickAction(
                    icon: Icons.message,
                    label: 'Send Message',
                    onTap: () {},
                    color: Colors.orange,
                  ),
                  _buildQuickAction(
                    icon: Icons.people,
                    label: 'Manage Users',
                    onTap: () {},
                    color: Colors.purple,
                  ),
                  _buildQuickAction(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    onTap: () {},
                    color: Colors.red,
                  ),
                  _buildQuickAction(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {},
                    color: Colors.teal,
                  ),
                ],
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30.h,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}