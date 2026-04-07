enum EmployeeStatus {
  clockedIn,
  onBreak,
  offDuty,
}

class Employee {
  final String id;
  final String name;
  final String role;
  final String department;
  final EmployeeStatus status;
  final String? clockInTime;
  final String? breakTimeRemaining;
  final String? imageUrl;
  final String? email;
  final String? phone;
  final String? createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.status,
    this.clockInTime,
    this.breakTimeRemaining,
    this.imageUrl,
    this.email,
    this.phone,
    this.createdAt,
  });
}



