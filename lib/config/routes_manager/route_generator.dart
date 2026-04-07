import 'package:admin_attendance/config/routes_manager/routes.dart';
import 'package:admin_attendance/features/bottom_nav_bar/view/admin_bottom_nav_bar_screen.dart';
import 'package:admin_attendance/features/employees/view/employees_screen.dart';
import 'package:admin_attendance/features/employees/view/add_employee_screen.dart';
import 'package:admin_attendance/features/home/view/admin_attendance_screen.dart';
import 'package:admin_attendance/features/home/view/notification_screen.dart';
import 'package:admin_attendance/features/home/view/requests_screen.dart';
import 'package:admin_attendance/features/profile/profile_screen.dart';
import 'package:admin_attendance/features/profile/attendance_history_screen.dart';
import 'package:admin_attendance/features/reports/view/reports_screen.dart';
import 'package:admin_attendance/features/settings/view/settings_screen.dart';
import 'package:admin_attendance/models/employee_model.dart';

import 'package:flutter/material.dart';


class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {


    //Admin


      case Routes.adminHome:
        return _buildPageRoute(const AdminBottomNavBarScreen());

      case Routes.attendance:
        return _buildPageRoute(const AdminAttendanceScreen());

      case Routes.employees:
        return _buildPageRoute(const EmployeesScreen());
      
      case Routes.addEmployee:
        return _buildPageRoute(const AddEmployeeScreen());

      case Routes.settings:
        return _buildPageRoute(SettingsScreen());

      case Routes.adminNotificationsScreen:
        return _buildPageRoute(const AdminNotificationsScreen());


      case Routes.requestScreen:
        return _buildPageRoute(const RequestsScreen());

      case Routes.reports:
        return _buildPageRoute(const ReportsScreen());

      case Routes.employeeProfile:
          final Employee employee = settings.arguments as Employee;
        return _buildPageRoute(EmployeeProfile(employee: employee));

        case Routes.attendanceHistoryScreen:
          final Employee historyEmployee = settings.arguments as Employee;
        return _buildPageRoute(AttendanceHistoryScreen(employee: historyEmployee));

      default:
        return unDefinedRoute();
    }
  }

  // Beautiful Slide and Fade Transition
  static PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from right
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('No Route Found'),
        ),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}
