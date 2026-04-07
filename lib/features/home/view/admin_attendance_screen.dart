
import 'package:admin_attendance/models/attendance_record.dart';
import 'package:admin_attendance/view_model/admin_cubit.dart';
import 'package:admin_attendance/view_model/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/attendance_item.dart';
import '../widgets/new_admin_home_att.dart';
import 'admin_home_screen.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminCubit.get(context).changeFilter(DateTime.now());
    });
  }

  // final List<String> filters = ["All", "On Time", "Late", "Absent"];

  // final List<AttendanceRecord> attendanceRecords = [
  //   AttendanceRecord(
  //     name: "Sarah Johnson",
  //     role: "Product Designer",
  //     time: "08:45 AM",
  //     status: AttendanceStatus.onTime,
  //   ),
  //   AttendanceRecord(
  //     name: "Michael Chen",
  //     role: "Senior Developer",
  //     time: "09:12 AM",
  //     status: AttendanceStatus.late,
  //   ),
  //   AttendanceRecord(
  //     name: "Emily Davis",
  //     role: "Marketing Lead",
  //     time: "12:30 PM",
  //     status: AttendanceStatus.breakTime,
  //   ),
  //   AttendanceRecord(
  //     name: "James Wilson",
  //     role: "Sales Rep",
  //     status: AttendanceStatus.absent,
  //   ),
  //   AttendanceRecord(
  //     name: "Linda Taylor",
  //     role: "HR Manager",
  //     time: "08:55 AM",
  //     status: AttendanceStatus.onTime,
  //   ),
  //   AttendanceRecord(
  //     name: "Robert Fox",
  //     role: "Operations",
  //     time: "08:59 AM",
  //     status: AttendanceStatus.onTime,
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCubit, AdminState>(
  listener: (context, state) {
  },
  builder: (context, state) {
    var cubit = AdminCubit.get(context);
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Daily Attendance",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        cubit.dateController.text,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                       Text(
                        cubit.dayName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  // Container(
                  //   padding: const EdgeInsets.all(8),
                  //   decoration: BoxDecoration(
                  //     color: Color(0xFF9333EA).withOpacity(0.12),
                  //     borderRadius: BorderRadius.circular(12),
                  //
                  //   ),
                  //   child:  Icon(
                  //     Icons.calendar_today,
                  //     color: Color(0xFF9333EA),
                  //   ),
                  // ),
                  IconButton.filledTonal(
                    onPressed: () async{

                      DateTime? datePicked =await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      );
                      if (datePicked != null) {
                        // setState(() {
                        //   String formattedDate = DateFormat('MMM, d, yyyy').format(datePicked);
                        //  cubit.dateController.text = formattedDate;
                        // });
                        cubit.changeFilter(datePicked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  // ActionChip(
                  //   avatar: Icon(Icons.calendar_today, color: Color(0xFF9333EA)),
                  //   label: Text("Select Date"),
                  //   backgroundColor: Color(0xFF9333EA).withOpacity(0.12),
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //   onPressed: () {},
                  // )
                ],
              ),
              const SizedBox(height: 25),
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     AttendanceSummaryCard(
              //       label: "Total",
              //       count: "42",
              //       countColor: Colors.black,
              //     ),
              //     AttendanceSummaryCard(
              //       label: "Present",
              //       count: "38",
              //       countColor: Color(0xFF10B981),
              //     ),
              //     AttendanceSummaryCard(
              //       label: "Late",
              //       count: "2",
              //       countColor: Color(0xFFc2410c),
              //     ),
              //     AttendanceSummaryCard(
              //       label: "Absent",
              //       count: "4",
              //       countColor: Color(0xFFb91c1c),
              //     ),
              //   ],
              // ),
              Row(
                spacing:MediaQuery.sizeOf(context).width * 0.05,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  AttendanceStatsCard(
                    title: cubit.onTimeCount.toString(),
                    subTitle: 'On Time',
                    cardColor: AppColors.statusGreen,
                  ),

                  AttendanceStatsCard(
                    title: cubit.lateCount.toString(),
                    subTitle: 'Late',
                    cardColor: AppColors.statusOrange,

                  ),
                  AttendanceStatsCard(
                    title: cubit.absentCount.toString(),
                    subTitle: 'Absent',
                    cardColor: AppColors.unSelectedText,

                  ),
                ],
              ),

              const SizedBox(height: 25),
              // SizedBox(
              //   height: 40,
              //   child: ListView.separated(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: filters.length,
              //     separatorBuilder: (context, index) => const SizedBox(width: 10),
              //     itemBuilder: (context, index) {
              //       final isSelected = selectedFilterIndex == index;
              //       return GestureDetector(
              //         onTap: () {
              //           setState(() {
              //             selectedFilterIndex = index;
              //           });
              //         },
              //         child: Container(
              //           padding: const EdgeInsets.symmetric(horizontal: 20),
              //           decoration: BoxDecoration(
              //             gradient: LinearGradient(colors: isSelected ? [const Color(0xFF6366F1), const Color(0xFFA78BFA)] : [Colors.white, Colors.white]),
              //             borderRadius: BorderRadius.circular(20),
              //             border: Border.all(
              //               color: isSelected ? Colors.transparent : Colors.grey.shade200,
              //             ),
              //           ),
              //           alignment: Alignment.center,
              //           child: Text(
              //             filters[index],
              //             style: TextStyle(
              //               color: isSelected ? Colors.white : Colors.black54,
              //               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              const SizedBox(height: 20),
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   itemCount: attendanceRecords.length,
              //   itemBuilder: (context, index) {
              //     return AdminAttendanceItem(record: attendanceRecords[index]);
              //   },
              // ),
              // Inside your BlocBuilder in AdminAttendanceScreen.dart
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Use the cubit list instead of the static one
                itemCount: cubit.realAttendanceRecords.length,
                itemBuilder: (context, index) {
                  return AdminAttendanceItem(record: cubit.realAttendanceRecords[index]);
                },
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),

    );
  },
);
  }
}




