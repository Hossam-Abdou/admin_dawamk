import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class PendingRequestsBox extends StatelessWidget {
  const PendingRequestsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff8B5CF6), Color(0xffC084FC)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Action Required',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '5 Request',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xffb087f9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '3 Leave Approvals',
                          style: GoogleFonts.poppins(color: Colors.white,
                            fontWeight: FontWeight.w400,fontSize: 14,),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16,),
                  Container(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xffb087f9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '3 Leave Approvals',
                          style: GoogleFonts.poppins(color: Colors.white,
                            fontWeight: FontWeight.w400,fontSize: 14,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.arrow_forward_outlined, color: AppColors.primaryColor,size: 36,))
            ],
          ),

        ],
      ),
    );
  }
}
