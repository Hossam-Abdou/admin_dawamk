import 'dart:ui';

import 'package:admin_attendance/models/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/admin/custom_date_field.dart';
import '../../../view_model/admin_cubit.dart';
import 'custom_holiday_field.dart';

class HolidaySection extends StatelessWidget {


  final TextEditingController holidayDateController = TextEditingController();
  final TextEditingController holidayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cubit = AdminCubit.get(context); // Access cubit for the list

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Holidays', style: GoogleFonts.poppins(fontSize: 20, color: Theme.of(context).colorScheme.onSurface)),
            TextButton(
              child: Text('Add New', style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.primary)),
              onPressed: () => _showAddSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        cubit.holidays.isEmpty?Text('Empty'): Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).cardColor),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // Use the real data from Cubit
            itemCount: cubit.holidays.length,
            itemBuilder: (context, index) {
              final holiday = cubit.holidays[index];
              return ListTile(
                leading: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                title: Text(holiday['name'] ?? 'No Name'),
                subtitle: Text(holiday['date'] ?? ''),
                trailing: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        // This calls the Cubit function we just created
                        showDeleteConfirmation(context,index,holiday['name'] );
                      },
                    ),
                    IconButton(onPressed: () {
                      _showAddSheet(
                        context,index: index,
                        initialName: holiday['name'],
                        initialDate: holiday['date'],
                      );
                    }, icon: const Icon(Icons.edit_outlined)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, {int? index,String? initialName, String? initialDate}) {
bool isEditing = index != null;
if (isEditing) {
  holidayNameController.text = initialName ?? '';
  holidayDateController.text = initialDate ?? '';
} else {
  holidayNameController.clear();
  holidayDateController.clear();
}
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 30),
                Text(isEditing?'Edit Holiday':'Add New Holiday', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 30),
                CustomHolidayTextField(label: 'Holiday Name', hint: 'e.g. Foundation Day', controller: holidayNameController),
                const SizedBox(height: 20),
                CustomDateField(label: 'Date', hint: 'mm/dd/yy', controller: holidayDateController),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (holidayNameController.text.isNotEmpty && holidayDateController.text.isNotEmpty) {
                        // Talk directly to the Cubit inside this widget
                        if (isEditing) {
                          AdminCubit.get(context).editHoliday(
                            index,
                            holidayNameController.text,
                            holidayDateController.text,
                          );
                        } else {
                          AdminCubit.get(context).addHoliday(
                            holidayNameController.text,
                            holidayDateController.text,
                          );
                        }
                        holidayNameController.clear();
                        holidayDateController.clear();
                        Navigator.pop(context);
                      }
                    },

                    icon:  Icon(isEditing?Icons.edit_calendar_rounded:Icons.save, color: Colors.white),
                    label:  Text(isEditing ? 'Update Holiday' :'Save Holiday', style: const TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void showDeleteConfirmation(BuildContext context, int index,String title) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Holiday',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this ${title}? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          // Delete Button
          ElevatedButton(
            onPressed: () {
              // Call the delete function in your Cubit
              AdminCubit.get(context).deleteHoliday(index);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }




}


