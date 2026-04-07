import 'package:admin_attendance/core/theme/app_theme.dart';
import 'package:admin_attendance/models/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_range/time_range.dart';

class CustomTimeRange extends StatelessWidget {
final Function(TimeRangeResult?) onTap;
final TimeOfDay? firstTime;
final TimeOfDay? lastTime;


CustomTimeRange({required this.onTap, required this.firstTime, required this.lastTime});

  @override
  Widget build(BuildContext context) {
    TimeRangeResult? timeRange;

    return Column(
      children: [
        TimeRange(
          fromTitle: Text(
            'From',
            style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          toTitle: Text(
            'To',
            style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          titlePadding: 3,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          activeTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          borderColor: Theme.of(context).dividerColor,
          backgroundColor: Colors.transparent,
          activeBackgroundColor: Theme.of(context).colorScheme.primary,
          // firstTime:
          // firstTime ??
          //     TimeOfDay(hour: 9, minute: 00),
          // lastTime:
          // lastTime ??
          //     TimeOfDay(hour: 20, minute: 00),
          // Keep these fixed so the timeline doesn't disappear
          firstTime: const TimeOfDay(hour: 9, minute: 0),
          lastTime: const TimeOfDay(hour: 23, minute: 59),
          timeStep: 30,
          timeBlock: 30,
          onRangeCompleted:onTap,
          // initialRange: TimeRangeResult(firstTime!, lastTime!),
        ),
        SizedBox(height: 8),

        if (timeRange != null)
          Text(
            '${firstTime?.format(context)} - ${lastTime?.format(context)}',
          ),
        Text(
          '${firstTime?.format(context)} - ${lastTime?.format(context)}',
        ),
      ],
    );
  }
}