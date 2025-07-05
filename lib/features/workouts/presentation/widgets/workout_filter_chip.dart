import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutFilterChip extends StatefulWidget {
  final String label;
  final List<String> options;
  final String selectedOption;
  final Function(String) onSelected;

  const WorkoutFilterChip({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  State<WorkoutFilterChip> createState() => _WorkoutFilterChipState();
}

class _WorkoutFilterChipState extends State<WorkoutFilterChip> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.options.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final option = widget.options[index];
              return ChoiceChip(
                label: Text(
                  option,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: widget.selectedOption == option
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
                selected: widget.selectedOption == option,
                onSelected: (selected) {
                  widget.onSelected(option);
                },
                selectedColor: theme.primaryColor,
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}