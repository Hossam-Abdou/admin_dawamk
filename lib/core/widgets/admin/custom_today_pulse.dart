import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class CustomTodayPulse extends StatelessWidget {
  final String title;
  final String subTitle;

  const CustomTodayPulse({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.25,
      padding: EdgeInsetsGeometry.all(8),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xfff8fafc),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 2,
            color: Colors.grey.shade200,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xffDCFCE7),
            child: Icon(Icons.check, color: Color(0xff16A34A)),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColors.unSelectedText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subTitle,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.unSelectedText,
            ),
          ),
        ],
      ),
    );
  }
}
