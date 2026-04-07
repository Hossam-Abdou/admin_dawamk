import 'package:admin_attendance/core/theme/app_theme.dart';
import 'package:admin_attendance/features/home/widgets/attendance_item.dart';
import 'package:admin_attendance/features/home/widgets/new_admin_home_att.dart';
import 'package:admin_attendance/view_model/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminCubit.get(context).getReports(startDate: startDate, endDate: endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reports",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is ExportSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report exported to: ${state.filePath.split('/').last}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green.shade600,
              ),
            );
          }
          else if (state is ExportErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Export failed: ${state.error}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red.shade600,
              ),
            );
          }
        },
        builder: (context, state) {
          var cubit = AdminCubit.get(context);
          var groupedRecords = cubit.groupedReportRecords;
          var allRecords = cubit.reportRecords;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // 1. Select Date Range Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                    children: [
                          Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Select Date Range",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            initialDateRange: DateTimeRange(start: startDate, end: endDate),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked.start;
                              endDate = picked.end;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.date_range_outlined, color: Colors.blueGrey, size: 18),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  DateFormat('MMM d, yyyy').format(startDate),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward_rounded, color: Colors.blueGrey, size: 16),
                              ),
                              const Icon(Icons.date_range_outlined, color: Colors.blueGrey, size: 18),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  DateFormat('MMM d, yyyy').format(endDate),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildGradientButton(
                        onTap: () => cubit.getReports(startDate: startDate, endDate: endDate),
                        label: "Generate Attendance Report",
                        icon: Icons.bar_chart_rounded,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            Theme.of(context).colorScheme.primary,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 2. Export Preview Card
                _buildCard(
                  title: "Export Preview",
                  child: state is GetReportsLoadingState
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : allRecords.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(child: Text("No records for this period")),
                            )
                          : Column(
                              children: [
                                ...groupedRecords.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                                            const SizedBox(width: 8),
                                            Text(
                                              entry.key,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...entry.value.map((record) => _buildPreviewRow(record)),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 12),
                                Text(
                                  "Showing ${allRecords.length} records",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                ),

                const SizedBox(height: 25),

                // 3. Export Actions Card
                _buildCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Export Report",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGradientButton(
                              onTap: () => cubit.exportToExcel(),
                              label: "Excel",
                              icon: Icons.download_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGradientButton(
                              onTap: () => cubit.exportToPDF(),
                              label: "PDF",
                              icon: Icons.picture_as_pdf_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  Theme.of(context).colorScheme.primary.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child, String? title}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(AttendanceRecord record) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              record.employee.name,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record.time ?? "--:--",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record.checkOutTime ?? "--:--",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              record.status.name,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(record.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime: return Colors.green;
      case AttendanceStatus.late: return Colors.orange;
      case AttendanceStatus.absent: return Colors.red;
      case AttendanceStatus.breakTime: return Colors.blueGrey;
    }
  }

  Widget _buildGradientButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
