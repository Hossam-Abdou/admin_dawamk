import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../config/routes_manager/routes.dart';
import '../../../models/employee_model.dart';

class EmployeeProfile extends StatelessWidget {
  final Employee employee;

  const EmployeeProfile({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
             ProfileHeader(employee: employee,),
            const SizedBox(height: 20),

            // قسم معلومات التواصل
            InfoCard(
              title: "Contact Information",
              children: [
                InfoTile(
                  icon: Icons.email_outlined,
                  label: "EMAIL ADDRESS",
                  value: employee.email ?? "Not provided",
                ),
                 InfoTile(
                  icon: Icons.phone_android_outlined,
                  label: "PHONE NUMBER",
                  value: employee.phone ?? "Not provided",
                ),
              ],
            ),

            // قسم تفاصيل الوظيفة
            InfoCard(
              title: "Job Details",
              children: [
                InfoTile(
                  icon: Icons.groups_outlined,
                  label: "DEPARTMENT",
                  value: employee.department,  // Use dynamic department here
                ),
                 InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: "JOIN DATE",
                  value: employee.createdAt ?? "Unknown",
                ),
              ],
            ),

            const SizedBox(height: 30),

            // زر عرض سجل الحضور
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.attendanceHistoryScreen, arguments: employee);
                },
                icon: const Icon(Icons.history, color: Colors.white),
                label: const Text("View Attendance History"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            // const SizedBox(height: 16),
            //
            // // زر تغيير الثيم
            // TextButton.icon(
            //   onPressed: () {},
            //   icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            //   label:  Text("Toggle Theme", style: GoogleFonts.poppins(color: Colors.grey)),
            //   style: TextButton.styleFrom(
            //     backgroundColor: Colors.grey.shade200,
            //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //     shape: StadiumBorder(),
            //   ),
            // ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// --- الهيدر العلوي ---
class ProfileHeader extends StatelessWidget {
final Employee employee;

ProfileHeader({required this.employee});

@override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // الخلفية البنفسجية
        Container(
          height: MediaQuery.sizeOf(context).height * 0.25,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors:AppGradients.checkIn,
              // [Color(0xFF9155FD), Color(0xFFB084FF)]
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 BackButton(color: Colors.white,),
                // IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back, color: Colors.white)),

              ],
            ),
          ),
        ),
        // الكارد الأبيض والصورة
        Padding(
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
          child: Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
               children: [
                 Text(employee.name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                 Text(employee.role, style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // _buildStatusBadge(employee.status),
                    // const SizedBox(width: 10),
                    _buildBadge("Full Time", Colors.purple.shade50, Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ),
        // صورة البروفايل الدائرية
        Positioned(
          top: 50,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(employee.imageUrl ?? 'https://i.pravatar.cc/300'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.clockedIn:
        return _buildBadge("CLOCKED IN", Colors.green.shade100, Colors.green);
      case EmployeeStatus.onBreak:
        return _buildBadge("ON BREAK", Colors.orange.shade100, Colors.orange);
      case EmployeeStatus.offDuty:
        return _buildBadge("OFF DUTY", Colors.grey.shade200, Colors.grey.shade700);
    }
  }

  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: GoogleFonts.poppins(color: textCol, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

// --- كارد المعلومات ---
class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const InfoCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style:  GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// --- سطر المعلومة الواحدة ---
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoTile({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}