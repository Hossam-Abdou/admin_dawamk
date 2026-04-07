import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassAttendanceCard extends StatelessWidget {
  final String title;
  // final String value;
  final IconData icon;
  final Color? cardColor;
  final Function()? onTap;

  const GlassAttendanceCard({
    super.key,
    required this.title,
    // required this.value,
    this.icon = Icons.people,
    this.onTap,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {


    return InkWell(
      onTap:onTap ,
      child: Container(
        padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12, right: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: cardColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: cardColor,
                size: 20,
              ),
            ),

SizedBox(width: 12,),
            // Title
            Text(
              title,
              style:
              GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              )

            ),

            // const SizedBox(height: 4),

            // Value
            // Text(
            //   value,
            //   style: const TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black87,
            //   ),
            // ),

            // const SizedBox(height: 8),

            // Optional Status Indicator
            // Row(
            //   children: [
            //     Container(
            //       width: 8,
            //       height: 8,
            //       decoration: BoxDecoration(
            //         color: Colors.green,
            //         shape: BoxShape.circle,
            //       ),
            //     ),
            //     const SizedBox(width: 6),
            //     Text(
            //       'Active',
            //       style: TextStyle(
            //         fontSize: 12,
            //         color: Colors.grey[600],
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

