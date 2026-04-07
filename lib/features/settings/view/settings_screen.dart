import 'dart:ui';

import 'package:admin_attendance/view_model/admin_cubit.dart';
import 'package:animated_conditional_builder/animated_conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_theme.dart';

import '../../../models/settings_model.dart';
import '../../../view_model/theme_cubit.dart';
import '../widgets/custom_holiday_section.dart';
import '../widgets/custom_time_range.dart';
import '../widgets/custom_weekly_off_days.dart';
import '../widgets/office_location_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
    AdminCubit.get(context).getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is LocationUpdatedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Office location updated successfully')),
          );
        } else if (state is UpdateSettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        var cubit = AdminCubit.get(context);
        return AnimatedConditionalBuilder(
          condition: state is! AdminLoading,
          fallback: (context) => Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
          builder: (context) {
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Settings',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).cardColor,
                          ),
                          child: BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, themeMode) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Dark Mode',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: themeMode == ThemeMode.dark,
                                    onChanged: (value) {
                                      ThemeCubit.get(context).toggleTheme();
                                    },
                                    activeColor: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Shift Configuration',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 16),

                        Container(
                          padding: EdgeInsetsGeometry.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Column(
                            children: [
                              CustomTimeRange(
                                onTap: (range) {
                                  if (range != null) {
                                    cubit.updateShift(range);
                                    // print(cubit.firstTime);print(cubit.lastTime,);
                                  }
                                },
                                firstTime: cubit.firstTime,
                                lastTime:  cubit.lastTime,
                              ),
                              Text(
                                "Shift starts at: ${cubit.firstTime.format(context)}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Late after: ${cubit.getFormattedLateLimit()}",
                                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Grace Period'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                       '${ cubit.gracePeriod}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Slider(
                              //   value: sliderValue,z
                              //   divisions: 12,
                              //   activeColor: AppColors.primaryColor,
                              //   onChanged: (value) {
                              //     setState(() {
                              //       sliderValue = value;
                              //     });
                              //   },
                              //   max: 60,
                              //   label: sliderValue.round().toString(),
                              // ),
                              Slider(
                                // value: settingsModel.gracePeriodMinutes.toDouble(),
                                value: cubit.gracePeriod,
                                min: 0,
                                max: 60,
                                divisions: 12,
                                activeColor: Theme.of(context).colorScheme.primary,
                                inactiveColor: Theme.of(context).dividerColor.withOpacity(0.1),
                                onChanged: (value) {
                                  setState(() {
                                    // settingsModel = settingsModel.copyWith(
                                    //   gracePeriodMinutes: value.round(),
                                    // );
                                    cubit.gracePeriod=value;
                                  cubit.saveGracePeriod();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),
                        CustomWeeklyOffDays(
                          onTap: (index) {
                            cubit.toggleWeeklyOffDay(index);

                            // cubit.updateWeeklyOffDays(cubit.weeklyOffDays);
                          },
                          selectedDays: cubit.weeklyOffDays,
                        ),

                        SizedBox(height: 16),
                        HolidaySection(),
                        SizedBox(height: 16),

                        OfficeLocationSection(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
