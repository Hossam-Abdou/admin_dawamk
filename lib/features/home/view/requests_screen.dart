import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _selectedTabIndex = 0; // 0: Leave, 1: Complaints, 2: Feedback

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Requests',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.11),

              child: Text(
                textAlign: TextAlign.center,
                _selectedTabIndex == 0
                    ? '5 '
                    : '8 ',
                  style: GoogleFonts.poppins(color: AppColors.primaryColor),

              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
            child: Row(
              children: [
                _buildTabItem(0, 'Leave'),
                _buildTabItem(1, 'Complaints'),
                // _buildTabItem(2, 'Feedback'),
              ],
            ),
          ),
SizedBox(height: 16,),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _selectedTabIndex == 0
                    ? const LeaveRequestCard(
                        name: 'Sarah Smith',
                        role: 'Product Designer',
                        type: 'Sick Leave • 2 Days',
                        description:
                            'Feeling unwell with high fever. Need rest to recover...',
                        dateRange: 'Dates: Oct 24 - Oct 25',
                      )
                    : LeaveRequestCard(
                        name: 'John Doe',
                        role: 'Senior Developer',
                        type: 'Annual Vacation • 5 Days',
                        description:
                            'Planning a family trip. Projects are handed over to Mike.',
                        dateRange: 'Dates: Nov 10 - Nov 15',
                        borderColor: Color(0xffEF4444).withOpacity(0.6),
                      ),
                // if (_selectedTabIndex == 0) ...[
                //   const LeaveRequestCard(
                //     name: 'Sarah Smith',
                //     role: 'Product Designer',
                //     type: 'Sick Leave • 2 Days',
                //     description: 'Feeling unwell with high fever. Need rest to recover...',
                //     dateRange: 'Dates: Oct 24 - Oct 25',
                //   ),
                //   const LeaveRequestCard(
                //     name: 'John Doe',
                //     role: 'Senior Developer',
                //     type: 'Annual Vacation • 5 Days',
                //     description: 'Planning a family trip. Projects are handed over to Mike.',
                //     dateRange: 'Dates: Nov 10 - Nov 15',
                //   ),
                // ]
                // else ...[
                //   const FeedbackCard(
                //     name: 'Sarah Smith',
                //     role: 'Product Designer',
                //     feedback: 'The new project management tool is great, but the notification system is a bit overwhelming.',
                //   ),
                // ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ?  (_selectedTabIndex==0?Theme.of(context).colorScheme.primary:Theme.of(context).colorScheme.secondary) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Sub-Widget for Leave Request
class LeaveRequestCard extends StatelessWidget {
  final String name, role, type, description, dateRange;
  final Color borderColor;

  const LeaveRequestCard({
    super.key,
    required this.name,
    required this.role,
    required this.type,
    required this.description,
    required this.dateRange,
    this.borderColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 3),

      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.grey, radius: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      role,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Today, 9:41 AM',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   children: [
                  //     const Icon(Icons.sick, size: 16, color: Color(0xFF7C3AED)),
                  //     const SizedBox(width: 8),
                  //     Text(type, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                  //   ],
                  // ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  // Text(dateRange, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12,), side: BorderSide(color: Theme.of(context).colorScheme.primary)),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    child:  Text('Reject',style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.bold),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-Widget for Feedback
// class FeedbackCard extends StatelessWidget {
//   final String name, role, feedback;
//   const FeedbackCard({super.key, required this.name, required this.role, required this.feedback});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const CircleAvatar(backgroundColor: Colors.grey, radius: 20),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//                   Text(role, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: const Color(0xffF8FAFC), borderRadius: BorderRadius.circular(16)),
//             child: Text(feedback, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.check_circle_outline, size: 18),
//               label: const Text('Acknowledge'),
//               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
