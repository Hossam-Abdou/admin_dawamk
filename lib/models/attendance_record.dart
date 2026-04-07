import 'employee_model.dart';
enum AttendanceStatus { onTime, late, breakTime, absent }

class AttendanceRecord {
  final Employee employee;
  final String name;
  final String role;
  final String? time;
  final String? checkOutTime;
  final AttendanceStatus status;
  final String? imageUrl;

  AttendanceRecord({
    required this.employee,
    required this.name,
    required this.role,
    this.time,
    this.checkOutTime,
    required this.status,
    this.imageUrl,
  });
}




