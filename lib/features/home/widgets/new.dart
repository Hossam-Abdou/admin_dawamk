// ============================================================
// VARIATION 2 — White card + left accent border
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttCardV2 extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color cardColor;
  final IconData icon;

  const AttCardV2({
    super.key,
    required this.title,
    required this.subTitle,
    required this.cardColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        border: Border(
          left: BorderSide(color: cardColor, width: 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subTitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodySmall?.color ??
                  const Color(0xff9CA3AF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: cardColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Icon(icon, size: 14, color: cardColor.withOpacity(0.5)),
        ],
      ),
    );
  }
}

// Usage V2:
// Row(
//   children: [
//     Expanded(child: AttCardV2(title: cubit.onTimeCount.toString(), subTitle: 'On Time', cardColor: AppColors.statusGreen, icon: FontAwesomeIcons.check)),
//     SizedBox(width: 10),
//     Expanded(child: AttCardV2(title: cubit.absentCount.toString(), subTitle: 'Absent', cardColor: AppColors.statusRed, icon: FontAwesomeIcons.xmark)),
//   ],
// )


// ============================================================
// VARIATION 3 — Icon + number side by side (horizontal)
// ============================================================

class AttCardV3 extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color cardColor;
  final IconData icon;

  const AttCardV3({
    super.key,
    required this.title,
    required this.subTitle,
    required this.cardColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon chip
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: cardColor),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color ??
                        const Color(0xff9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                    height: 1.1,
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

// Usage V3:
// GridView.count(
//   crossAxisCount: 2,
//   crossAxisSpacing: 10,
//   mainAxisSpacing: 10,
//   shrinkWrap: true,
//   childAspectRatio: 1.6,
//   physics: NeverScrollableScrollPhysics(),
//   children: [
//     AttCardV3(title: cubit.totalCount.toString(),   subTitle: 'Total',   cardColor: AppColors.statusBlue,   icon: FontAwesomeIcons.users),
//     AttCardV3(title: cubit.onTimeCount.toString(),  subTitle: 'On Time', cardColor: AppColors.statusGreen,  icon: FontAwesomeIcons.check),
//     AttCardV3(title: cubit.lateCount.toString(),    subTitle: 'Late',    cardColor: AppColors.statusAmber,  icon: FontAwesomeIcons.clock),
//     AttCardV3(title: cubit.absentCount.toString(),  subTitle: 'Absent',  cardColor: AppColors.statusRed,    icon: FontAwesomeIcons.xmark),
//   ],
// )


// ============================================================
// BONUS — Tinted background card (clean, no border tricks)
// ============================================================

class AttCardBonus extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color cardColor;
  final IconData icon;

  const AttCardBonus({
    super.key,
    required this.title,
    required this.subTitle,
    required this.cardColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardColor.withOpacity(0.25), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subTitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cardColor.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                  height: 1,
                ),
              ),
              const Spacer(),
              Icon(icon, size: 18, color: cardColor.withOpacity(0.4)),
            ],
          ),
        ],
      ),
    );
  }
}

// Usage Bonus — same GridView pattern as V3, swap widget name:
// AttCardBonus(title: '3', subTitle: 'Total', cardColor: AppColors.statusBlue, icon: FontAwesomeIcons.users)


// ============================================================
// SHARED 2x2 GRID WRAPPER — drop any card variant inside
// ============================================================

class AttStatsGrid extends StatelessWidget {
  final List<Widget> cards; // pass exactly 4 cards

  const AttStatsGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      childAspectRatio: 1.55,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }
}

// Full usage example with V3:
// AttStatsGrid(
//   cards: [
//     AttCardV3(title: cubit.totalCount.toString(),  subTitle: 'Total',   cardColor: AppColors.statusBlue,  icon: FontAwesomeIcons.users),
//     AttCardV3(title: cubit.onTimeCount.toString(), subTitle: 'On Time', cardColor: AppColors.statusGreen, icon: FontAwesomeIcons.check),
//     AttCardV3(title: cubit.lateCount.toString(),   subTitle: 'Late',    cardColor: AppColors.statusAmber, icon: FontAwesomeIcons.clock),
//     AttCardV3(title: cubit.absentCount.toString(), subTitle: 'Absent',  cardColor: AppColors.statusRed,   icon: FontAwesomeIcons.xmark),
//   ],
// )