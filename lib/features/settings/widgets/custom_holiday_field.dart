import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomHolidayTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller; // إضافة اختيارية للتحكم في النص

  const CustomHolidayTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        // حقل الإدخال
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB), // رمادي فاتح جداً زي اللي في الصورة
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // الحدود في الحالة العادية
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            // الحدود عند الضغط (Focus)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9B51E0), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}