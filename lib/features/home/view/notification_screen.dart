import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
SizedBox(height: MediaQuery.sizeOf(context).height*0.04,),
          // Notifications List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                NotificationCard(
                  title: 'Inventory Low: Coffee Beans',
                  subtitle: 'HIGH PRIORITY • OPERATIONS',
                  description: 'Stock is below 15%. Reorder recommended immediately to...',
                  time: '10m ago',
                  iconColor: Colors.orange,
                  isUnread: true,
                ),
                NotificationCard(
                  title: 'Sarah J. clocked in',
                  subtitle: 'ATTENDANCE',
                  description: 'Shift started on time at 09:00 AM at Downtown Branch.',
                  time: '25m ago',
                  iconColor: Colors.green,
                  isUnread: false,
                ),
                NotificationCard(
                  title: 'Unscheduled Overtime',
                  subtitle: 'ALERT • MIKE T.',
                  description: 'Employee has exceeded 8 hours without manager approval.',
                  time: '45m ago',
                  iconColor: Colors.orange,
                  isUnread: true,
                ),
                NotificationCard(
                  title: 'Weekly Report Generated',
                  subtitle: 'SYSTEM',
                  description: 'Your weekly performance summary is ready to view. Revenue up by...',
                  time: '1h ago',
                  iconColor: Colors.purple,
                  isUnread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class NotificationCard extends StatelessWidget {
  final String title, subtitle, description, time;
  final Color iconColor;
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.time,
    required this.iconColor,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isUnread)
                      const CircleAvatar(radius: 4, backgroundColor: Color(0xFF7C3AED)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}