import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:fitguy1/features/home/domain/models/goaol_model.dart';
import 'package:fitguy1/features/home/domain/models/goal_type.dart';
import '../providers/goal_provider.dart';

class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
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
                'My Goals',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, size: 24.h),
                    onPressed: () => _showGoalCreationDialog(context, ref),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, size: 24.h),
                    onPressed: () => _showGoalManagementMenu(context, ref),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          if (goals.isEmpty)
            _buildEmptyState(context)
          else
            Column(
              children: [
                ...goals.map((goal) => _buildGoalItem(context, ref, goal)),
                SizedBox(height: 16.h),
                _buildOverallProgress(context, goals),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        Icon(
          Icons.flag_outlined,
          size: 48.h,
          color: Colors.grey.shade400,
        ),
        SizedBox(height: 16.h),
        Text(
          'No goals yet',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create your first goal to get started',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showGoalCreationDialog(context, null),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: Text(
              'Create Goal',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildGoalItem(BuildContext context, WidgetRef ref, FitnessGoal goal) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () => _showGoalEditDialog(context, ref, goal),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.h,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: goal.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          goal.type.icon,
                          color: goal.color,
                          size: 20.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          '${DateFormat('MMM d').format(goal.startDate)} - ${DateFormat('MMM d').format(goal.endDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 24.h, color: goal.color),
                  onPressed: () {
                    final newValue = goal.currentValue + (goal.targetValue * 0.05);
                    ref.read(goalProvider.notifier).updateProgress(
                      goal.id,
                      newValue > goal.targetValue ? goal.targetValue : newValue,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12.h),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 8.h,
              percent: goal.progress > 1 ? 1 : goal.progress,
              progressColor: goal.color,
              backgroundColor: Colors.grey.shade200,
              barRadius: Radius.circular(4),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currentValue.toStringAsFixed(goal.unit == 'kg' ? 1 : 0)}/${goal.targetValue.toStringAsFixed(goal.unit == 'kg' ? 1 : 0)} ${goal.unit}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context, List<FitnessGoal> goals) {
    final theme = Theme.of(context);
    final totalProgress = goals.isEmpty 
        ? 0 
        : goals.map((g) => g.progress).reduce((a, b) => a + b) / goals.length;

    return Column(
      children: [
        Divider(height: 1, color: Colors.grey.shade200),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${(totalProgress * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 8.h,
          percent: totalProgress > 1 ? 1.0 : totalProgress.toDouble(),
          progressColor: theme.primaryColor,
          backgroundColor: Colors.grey.shade200,
          barRadius: Radius.circular(4),
        ),
      ],
    );
  }

  void _showGoalCreationDialog(BuildContext context, WidgetRef? ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();
    final unitController = TextEditingController();
    DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );
    GoalType selectedType = GoalType.custom;
    Color selectedColor = Colors.teal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Create New Goal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<GoalType>(
                    value: selectedType,
                    items: GoalType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, color: type.defaultColor),
                            SizedBox(width: 8.w),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (type) {
                      setState(() {
                        selectedType = type!;
                        selectedColor = type.defaultColor;
                        unitController.text = type.defaultUnit;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Goal Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Value',
                      border: OutlineInputBorder(),
                      suffixText: unitController.text,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: unitController,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  InkWell(
                    onTap: () async {
                      final newDateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        initialDateRange: dateRange,
                      );
                      if (newDateRange != null) {
                        setState(() => dateRange = newDateRange);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d').format(dateRange.start)),
                          Icon(Icons.arrow_forward),
                          Text(DateFormat('MMM d').format(dateRange.end)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text('Color:'),
                      SizedBox(width: 16.w),
                      ...[
                        Colors.red,
                        Colors.orange,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                        Colors.teal,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            width: 24.h,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color
                                  ? Border.all(width: 2, color: Colors.black)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty || 
                      targetController.text.isEmpty || 
                      unitController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }

                  final newGoal = FitnessGoal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descriptionController.text,
                    type: selectedType,
                    currentValue: 0,
                    targetValue: double.parse(targetController.text),
                    unit: unitController.text,
                    startDate: dateRange.start,
                    endDate: dateRange.end,
                    color: selectedColor,
                  );

                  if (ref != null) {
                    ref.read(goalProvider.notifier).addGoal(newGoal);
                  }
                  Navigator.pop(context);
                },
                child: Text('Create Goal'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showGoalEditDialog(BuildContext context, WidgetRef ref, FitnessGoal goal) {
    final titleController = TextEditingController(text: goal.title);
    final descriptionController = TextEditingController(text: goal.description);
    final targetController = TextEditingController(text: goal.targetValue.toString());
    final currentController = TextEditingController(text: goal.currentValue.toString());
    final unitController = TextEditingController(text: goal.unit);
    DateTimeRange dateRange = DateTimeRange(start: goal.startDate, end: goal.endDate);
    Color selectedColor = goal.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Goal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Current Value',
                      border: OutlineInputBorder(),
                      suffixText: unitController.text,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Value',
                      border: OutlineInputBorder(),
                      suffixText: unitController.text,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: unitController,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  InkWell(
                    onTap: () async {
                      final newDateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        initialDateRange: dateRange,
                      );
                      if (newDateRange != null) {
                        setState(() => dateRange = newDateRange);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d').format(dateRange.start)),
                          Icon(Icons.arrow_forward),
                          Text(DateFormat('MMM d').format(dateRange.end)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text('Color:'),
                      SizedBox(width: 16.w),
                      ...[
                        Colors.red,
                        Colors.orange,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                        Colors.teal,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            width: 24.h,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color
                                  ? Border.all(width: 2, color: Colors.black)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // final updatedGoal = goal.copyWith(
                  //   title: titleController.text,
                  //   description: descriptionController.text,
                  //   currentValue: double.parse(currentController.text),
                  //   targetValue: double.parse(targetController.text),
                  //   unit: unitController.text,
                  //   startDate: dateRange.start,
                  //   endDate: dateRange.end,
                  //   color: selectedColor,
                  // );
                  // ref.read(goalProvider.notifier).updateGoal(goal.id, updatedGoal);
                  Navigator.pop(context);
                },
                child: Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showGoalManagementMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage Goals',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.add, color: Theme.of(context).primaryColor),
              title: Text('Create New Goal'),
              onTap: () {
                Navigator.pop(context);
                _showGoalCreationDialog(context, ref);
              },
            ),
            ListTile(
              leading: Icon(Icons.sort, color: Colors.orange),
              title: Text('Sort Goals'),
              onTap: () {
                // Implement sorting logic
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.filter_alt, color: Colors.blue),
              title: Text('Filter Goals'),
              onTap: () {
                // Implement filtering logic
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}