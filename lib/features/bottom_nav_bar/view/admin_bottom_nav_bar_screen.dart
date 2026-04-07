import 'package:admin_attendance/features/home/view/notification_screen.dart';

import '../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import '../../home/view/admin_home_screen.dart';
import '../../home/view/requests_screen.dart';
import '../../reports/view/reports_screen.dart';
import '../../settings/view/settings_screen.dart';



      /// bottom bar
// PersistentTabView(
// context,
// items: [
// PersistentBottomNavBarItem(
// icon: Icon(CupertinoIcons.home),
// title: ("Home"),
// activeColorPrimary: CupertinoColors.label,
// inactiveColorPrimary: CupertinoColors.systemGrey,
//
// ),
// PersistentBottomNavBarItem(
// icon: Icon(CupertinoIcons.settings),
// title: ("Settings"),
// activeColorPrimary: CupertinoColors.activeBlue,
// inactiveColorPrimary: CupertinoColors.systemGrey,
//
// ),
// ],
// screens: [AdminScreen(), AdminScreen()],
// )



class AdminBottomNavBarScreen extends StatefulWidget {
  const AdminBottomNavBarScreen({super.key});

  @override
  State<AdminBottomNavBarScreen> createState() => _AdminBottomNavBarScreenState();
}

class _AdminBottomNavBarScreenState extends State<AdminBottomNavBarScreen> {
  int currentIndex = 0;
  List<Widget> adminLayouts = [
    const AdminHomeScreen(),
    // RequestsScreen(),
    // const ReportsScreen(),
     SettingsScreen(),
    const AdminNotificationsScreen(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
      body: adminLayouts[currentIndex],
    );
  }
}









