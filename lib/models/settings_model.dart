import 'package:flutter/material.dart';

class SettingsModel {

  // Shift Configuration
  TimeOfDay? shiftStartTime;
  TimeOfDay? shiftEndTime;
  int gracePeriodMinutes; // 0-60 minutes

  // Calendar
  List<int> weeklyOffDays; // 0=Sunday, 1=Monday, ..., 6=Saturday
  List<Holiday> holidays;

  // Office Location
  double latitude;
  double longitude;
  int geofenceRadiusMeters; // 10-200 meters

  SettingsModel({
    this.shiftStartTime,
    this.shiftEndTime,
    this.gracePeriodMinutes = 15,
    this.weeklyOffDays = const [5, 6], // Friday and Saturday by default
    this.holidays = const [],
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.geofenceRadiusMeters = 50,
  });

  SettingsModel copyWith({
    TimeOfDay? shiftStartTime,
    TimeOfDay? shiftEndTime,
    int? gracePeriodMinutes,
    List<int>? weeklyOffDays,
    List<Holiday>? holidays,
    double? latitude,
    double? longitude,
    int? geofenceRadiusMeters,
  }) {
    return SettingsModel(
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      shiftEndTime: shiftEndTime ?? this.shiftEndTime,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      weeklyOffDays: weeklyOffDays ?? this.weeklyOffDays,
      holidays: holidays ?? this.holidays,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
    );
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'shiftStartTime': shiftStartTime != null
          ? '${shiftStartTime!.hour.toString().padLeft(2, '0')}:${shiftStartTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'shiftEndTime': shiftEndTime != null
          ? '${shiftEndTime!.hour.toString().padLeft(2, '0')}:${shiftEndTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'gracePeriodMinutes': gracePeriodMinutes,
      'weeklyOffDays': weeklyOffDays,
      'holidays': holidays.map((h) => {
        'id': h.id,
        'name': h.name,
        'startDate': h.startDate.toIso8601String(),
        'endDate': h.endDate.toIso8601String(),
        'icon': h.icon,
      }).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'geofenceRadiusMeters': geofenceRadiusMeters,
    };
  }

  // Create from Map (from Firebase)
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return SettingsModel(
      shiftStartTime: parseTime(map['shiftStartTime']),
      shiftEndTime: parseTime(map['shiftEndTime']),
      gracePeriodMinutes: map['gracePeriodMinutes'] ?? 15,
      weeklyOffDays: List<int>.from(map['weeklyOffDays'] ?? [5, 6]),
      holidays: (map['holidays'] as List<dynamic>?)
          ?.map((h) => Holiday(
                id: h['id'],
                name: h['name'],
                startDate: DateTime.parse(h['startDate']),
                endDate: DateTime.parse(h['endDate']),
                icon: h['icon'] ?? 'celebration',
              ))
          .toList() ?? [],
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      geofenceRadiusMeters: map['geofenceRadiusMeters'] ?? 50,
    );
  }
}

class Holiday {
  final String? id;
  final String? name;
  final DateTime startDate;
  final DateTime endDate;
  final String? icon; // Icon identifier

  Holiday({
     this.id,
     this.name,
     required this.startDate,
     required this.endDate,
    this.icon = 'celebration',
  });

  bool get isSingleDay => startDate.isAtSameMomentAs(endDate);

  String get dateRange {
    if (isSingleDay) {
      return _formatDate(startDate);
    } else {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}



