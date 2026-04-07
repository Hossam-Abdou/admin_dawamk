import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/attendance_record.dart';
import '../models/employee_model.dart';

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:async';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitial());

  StreamSubscription? _attendanceSubscription;

  @override
  Future<void> close() {
    _attendanceSubscription?.cancel();
    return super.close();
  }

  static AdminCubit get(context) => BlocProvider.of(context);

  Future<void> registerEmployee({
    required String name,
    required String email,
    required String password,
    required String employeeId,
    required String department,
    required String phone,
    required String role,
  }) async {
    emit(RegisterLoading());
    try {
      // Create a temporary Firebase app to avoid logging out the current admin
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'TemporaryRegisterApp',
        options: Firebase.app().options,
      );

      UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;
      await userCredential.user!.updateDisplayName(name.trim());

      // Save user data in Firestore
      await fireStore.collection('users').doc(uid).set({
        "uid": uid,
        "name": name.trim(),
        "email": email.trim(),
        "employee_id": employeeId,
        "department": department,
        "phone": phone.trim(),
        "role": role.trim(),
        "type": "emp",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Cleanup
      await tempApp.delete();

      emit(RegisterSuccess());
      // Refresh the employee list
      calculateDailySummary();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(RegisterError("Email is already registered"));
      } else if (e.code == 'weak-password') {
        emit(RegisterError("Password is too weak"));
      } else {
        emit(RegisterError(e.message ?? "Registration error"));
      }
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }



  final fireStore = FirebaseFirestore.instance;

// Add this list to your AdminCubit class
  List<AttendanceRecord> realAttendanceRecords = [];
  List<AttendanceRecord> userHistoryRecords = [];

  Future<void> getUserAttendanceHistory(Employee employee) async {
    emit(GetUserHistoryLoadingState());
    userHistoryRecords = [];

    try {
      var snapshot = await fireStore.collectionGroup('days').get();
      
      for (var doc in snapshot.docs) {
        if (doc.reference.parent.parent?.id != employee.id) continue;

        var data = doc.data();
        
        AttendanceStatus status = AttendanceStatus.onTime;
        if (data['status'] == 'late') status = AttendanceStatus.late;
        else if (data['status'] == 'absent') status = AttendanceStatus.absent;
        else if (data['status'] == 'breakTime') status = AttendanceStatus.breakTime; // just in case

        String? timeStr;
        String? checkOutStr;
        if (data['checkIn'] is Timestamp) {
            timeStr = DateFormat('hh:mm a').format((data['checkIn'] as Timestamp).toDate());
        } else if (data['checkIn'] is String) {
            timeStr = data['checkIn'];
        }

        if (data['checkOut'] is Timestamp) {
            checkOutStr = DateFormat('hh:mm a').format((data['checkOut'] as Timestamp).toDate());
        } else if (data['checkOut'] is String) {
            checkOutStr = data['checkOut'];
        }

        String checkDate = data['date'] ?? "";
        
        userHistoryRecords.add(
          AttendanceRecord(
            employee: employee,
            name: checkDate,      // Hack 'name' to show the date in the item UI!
            role: employee.role,
            time: timeStr,
            checkOutTime: checkOutStr,
            status: status,
            imageUrl: employee.imageUrl,
          )
        );
      }
      // sort by date descending
      userHistoryRecords.sort((a, b) => b.name.compareTo(a.name));

      emit(GetUserHistorySuccessState());
    } catch (e) {
      emit(GetUserHistoryErrorState(e.toString()));
    }
  }

  Future<void> calculateDailySummary({DateTime? selectedDate}) async {
    // If it's today, we use the stream listener instead
    DateTime now = DateTime.now();
    DateTime dateToQuery = selectedDate ?? now;
    bool isToday = dateToQuery.year == now.year && dateToQuery.month == now.month && dateToQuery.day == now.day;

    if (isToday) {
      listenToTodayAttendance();
      return;
    }

    // For historical dates, we keep the manual fetch (one-time)
    _attendanceSubscription?.cancel();
    emit(GetAttendanceLoadingState());

    onTimeCount = 0;
    lateCount = 0;
    absentCount = 0;
    realAttendanceRecords = [];

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateToQuery);

      var usersSnapshot = await fireStore.collection('users').get();
      totalEmployees = usersSnapshot.docs.length;

      var attendanceSnapshot = await fireStore.collectionGroup('days')
          .where('date', isEqualTo: formattedDate)
          .get();

      Map<String, dynamic> attendanceMap = {
        for (var doc in attendanceSnapshot.docs) doc.reference.parent.parent!.id: doc.data()
      };

      for (var userDoc in usersSnapshot.docs) {
        String uid = userDoc.id;
        Map<String, dynamic> userData = userDoc.data();
        Map<String, dynamic>? attendanceData = attendanceMap[uid];

        AttendanceStatus status;
        String? timeStr;
        String? checkOutStr;

        if (attendanceData != null) {
          String statusStr = attendanceData['status'] ?? 'onTime';
          if (statusStr == 'late') {
            lateCount++;
            status = AttendanceStatus.late;
          } else {
            onTimeCount++;
            status = AttendanceStatus.onTime;
          }

          if (attendanceData['checkIn'] is Timestamp) {
            timeStr = DateFormat('hh:mm a').format((attendanceData['checkIn'] as Timestamp).toDate());
          }
          if (attendanceData['checkOut'] is Timestamp) {
            checkOutStr = DateFormat('hh:mm a').format((attendanceData['checkOut'] as Timestamp).toDate());
          }
        } else {
          absentCount++;
          status = AttendanceStatus.absent;
        }

        String? createdAtFormatted;
        if (userData['createdAt'] != null) {
          if (userData['createdAt'] is Timestamp) {
            createdAtFormatted = DateFormat('MMM d, yyyy').format((userData['createdAt'] as Timestamp).toDate());
          } else if (userData['createdAt'] is String) {
            createdAtFormatted = userData['createdAt'];
          }
        }

        Employee employee = Employee(
            id: uid,
            name: userData['name'] ?? "Unknown",
            role: userData['role'] ?? "Employee",
            department: userData['department'] ?? "Unknown",
            status: EmployeeStatus.clockedIn, 
            email: userData['email'],
            imageUrl: userData['profile_image'],
            phone: userData['phone'] ?? userData['phone_number'],
            createdAt: createdAtFormatted,
        );

        realAttendanceRecords.add(
          AttendanceRecord(
            employee: employee,
            name: userData['name'] ?? "Unknown",
            role: userData['role'] ?? "Employee",
            time: timeStr,
            checkOutTime: checkOutStr,
            status: status,
            imageUrl: userData['profile_image'],
          ),
        );
      }

      emit(GetAttendanceSuccessState());
    } catch (e) {
      emit(GetAttendanceErrorState(e.toString()));
    }
  }

  void listenToTodayAttendance() {
    _attendanceSubscription?.cancel();
    
    if (realAttendanceRecords.isEmpty) {
      emit(GetAttendanceLoadingState());
    }

    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _attendanceSubscription = fireStore.collectionGroup('days')
        .where('date', isEqualTo: todayStr)
        .limit(50)
        .snapshots()
        .listen((attendanceSnapshot) async {
      try {
        // Fetch users once per snapshot cycle (or better, cache them)
        // For now, let's keep it simple but ensure totalEmployees is updated
        var usersSnapshot = await fireStore.collection('users').get();
        totalEmployees = usersSnapshot.docs.length;

        onTimeCount = 0;
        lateCount = 0;
        absentCount = 0;
        List<AttendanceRecord> updatedRecords = [];

        Map<String, dynamic> attendanceMap = {
          for (var doc in attendanceSnapshot.docs) doc.reference.parent.parent!.id: doc.data()
        };

        for (var userDoc in usersSnapshot.docs) {
          String uid = userDoc.id;
          Map<String, dynamic> userData = userDoc.data();
          Map<String, dynamic>? attendanceData = attendanceMap[uid];

          AttendanceStatus status;
          String? timeStr;
          String? checkOutStr;

          if (attendanceData != null) {
            String statusStr = attendanceData['status'] ?? 'onTime';
            if (statusStr == 'late') {
              lateCount++;
              status = AttendanceStatus.late;
            } else {
              onTimeCount++;
              status = AttendanceStatus.onTime;
            }

            if (attendanceData['checkIn'] is Timestamp) {
              timeStr = DateFormat('hh:mm a').format((attendanceData['checkIn'] as Timestamp).toDate());
            }
            if (attendanceData['checkOut'] is Timestamp) {
              checkOutStr = DateFormat('hh:mm a').format((attendanceData['checkOut'] as Timestamp).toDate());
            }
          } else {
            absentCount++;
            status = AttendanceStatus.absent;
          }

          Employee employee = Employee(
            id: uid,
            name: userData['name'] ?? "Unknown",
            role: userData['role'] ?? "Employee",
            department: userData['department'] ?? "Unknown",
            status: EmployeeStatus.clockedIn,
            email: userData['email'],
            imageUrl: userData['profile_image'],
            phone: userData['phone'] ?? userData['phone_number'],
          );

          updatedRecords.add(
            AttendanceRecord(
              employee: employee,
              name: userData['name'] ?? "Unknown",
              role: userData['role'] ?? "Employee",
              time: timeStr,
              checkOutTime: checkOutStr,
              status: status,
              imageUrl: userData['profile_image'],
            ),
          );
        }

        realAttendanceRecords = updatedRecords;
        todayOnTimeCount = onTimeCount;
        todayLateCount = lateCount;
        todayAbsentCount = absentCount;

        emit(GetAttendanceSuccessState());
      } catch (e) {
        emit(GetAttendanceErrorState(e.toString()));
      }
    });
  }
  List<int> weeklyOffDays = [5, 6]; // Initial values (Fri, Sat)
  List<Map<String, dynamic>> holidays = [];
  double officeLatitude = 24.7136;
  double officeLongitude = 46.6753;
  double officeRadius = 50.0;

  DocumentReference<Map<String, dynamic>> adminSettings = FirebaseFirestore.instance.collection('settings').doc('admin_settings');


  Future<void> getSettings() async {
    emit(AdminLoading()); // This triggers your loading spinner
    try {
      var doc = await fireStore.collection('settings').doc('admin_settings').get();
      if (doc.exists && doc.data() != null) {
        // Update the local list with Firebase data
        List<dynamic> data = doc.data()!['weeklyOffDays'] ?? [];
        weeklyOffDays = data.cast<int>();
        
        officeLatitude = (doc.data()!['officeLatitude'] ?? 24.7136).toDouble();
        officeLongitude = (doc.data()!['officeLongitude'] ?? 46.6753).toDouble();
        officeRadius = (doc.data()!['officeRadius'] ?? 50.0).toDouble();
      }
      emit(AdminInitial()); // Stop loading and show the screen
    } catch (e) {
      emit(UpdateSettingsError(e.toString()));
    }
  }

  Future<void> updateOfficeLocation(double lat, double lng, double radius) async {
    officeLatitude = lat;
    officeLongitude = lng;
    officeRadius = radius;
    emit(LocationUpdatedSuccessfully());
    try {
      await adminSettings.set({
        'officeLatitude': lat,
        'officeLongitude': lng,
        'officeRadius': radius,
      }, SetOptions(merge: true));
    } catch (e) {
      emit(UpdateSettingsError(e.toString()));
    }
  }

  Future<void> saveGracePeriod() async {
    await adminSettings.set({
      'gracePeriodMinutes': gracePeriod,
    }, SetOptions(merge: true));
  }

  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  void toggleWeeklyOffDay(int index) {
    // Create a new list instance
    List<int> updatedDays = List.from(weeklyOffDays);

    if (updatedDays.contains(index)) {
      updatedDays.remove(index);
    } else {
      updatedDays.add(index);
    }

    // Update local variable
    weeklyOffDays = updatedDays;

    // Emit a state that DOES NOT trigger the loading spinner
    emit(WeeklyOffDaysUpdated(weeklyOffDays));

    // Update Firebase SILENTLY (don't emit Loading state here)
    fireStore.collection('settings').doc('admin_settings').update({
      'weeklyOffDays': weeklyOffDays,
    }).catchError((error) {
      emit(UpdateSettingsError(error.toString()));
    });
  }

// ... existing variables ...


  int selectedFilterIndex = 0;
  final TextEditingController dateController = TextEditingController();
  String dayName = DateFormat('EEEE').format(DateTime.now());

  changeFilter(DateTime datePicked) {
    dateController.text = DateFormat('MMM, d, yyyy').format(datePicked);
    dayName = DateFormat('EEEE').format(datePicked); // Update day name (e.g., "Monday")
    calculateDailySummary(selectedDate: datePicked);
    emit(ChangeFilterState());
  }

  // changeFilter(datePicked) {
  //   String formattedDate = DateFormat('MMM, d, yyyy').format(datePicked);
  //   dateController.text = formattedDate;
  //   getTodayAttendanceSummary(selectedDate: datePicked);
  //   emit(ChangeFilterState());
  // }








// Time Range
double gracePeriod =10.0;

 int lateCount =0;
 int onTimeCount =0;
 int absentCount =0;
 
 int todayLateCount =0;
 int todayOnTimeCount =0;
 int todayAbsentCount =0;
  int totalEmployees = 0;

  TimeOfDay firstTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay lastTime = const TimeOfDay(hour: 18, minute: 0);

  Future<void> getTodayAttendanceSummary({DateTime? selectedDate}) async {
    emit(GetAttendanceLoadingState());

    onTimeCount = 0;
    lateCount = 0;
    absentCount = 0;

    try {
      var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      totalEmployees = usersSnapshot.docs.length;

      DateTime dateToQuery = selectedDate ?? DateTime.now();
      // Format must match the value stored INSIDE the document field
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateToQuery);

      // 1. Query the 'days' sub-collections using a field, not the ID
      var attendanceSnapshot = await FirebaseFirestore.instance
          .collectionGroup('days')
          .where('date', isEqualTo: formattedDate) // Use a field named 'date'
          .get();

      onTimeCount = attendanceSnapshot.docs.length;
      absentCount = totalEmployees - onTimeCount;

      DateTime now = DateTime.now();
      if (dateToQuery.year == now.year && dateToQuery.month == now.month && dateToQuery.day == now.day) {
        todayOnTimeCount = onTimeCount;
        todayLateCount = lateCount;
        todayAbsentCount = absentCount;
      }

      emit(GetAttendanceSuccessState());
      print(onTimeCount);
        print(lateCount);
        print(absentCount);
    } catch (error) {
      print("Error details: $error");
      emit(GetAttendanceErrorState(error.toString()));
    }
  }
  // Future<void> calculateDailySummary() async {
  //   emit(GetAttendanceLoadingState());
  //   try {
  //     // 1. Format date correctly: 2026-2-26 becomes 2026-02-26
  //     DateTime now = DateTime.now();
  //     String month = now.month.toString().padLeft(2, '0');
  //     String day = now.day.toString().padLeft(2, '0');
  //     String formattedDate = "${now.year}-$month-$day";
  //
  //     // 2. Fetch Settings
  //     var settingsDoc = await adminSettings.get();
  //     String startStr = settingsDoc.data()?['shiftStartTime'] ?? "09:00";
  //     int grace = (settingsDoc.data()?['gracePeriodMinutes'] ?? 0).toInt();
  //
  //     int startH = int.parse(startStr.split(':')[0]);
  //     int startM = int.parse(startStr.split(':')[1]);
  //     int threshold = (startH * 60) + startM + grace;
  //
  //     // 3. Query using the formatted string
  //     var attendanceSnapshot = await fireStore.collectionGroup('days')
  //         .where('date', isEqualTo: formattedDate)
  //         .get();
  //
  //     // 4. Calculate Counts
  //     onTimeCount = 0;
  //     lateCount = 0;
  //
  //     for (var doc in attendanceSnapshot.docs) {
  //       String arrivalStr = doc.data()['checkIn'] ?? "00:00";
  //       int arrivalH = int.parse(arrivalStr.split(':')[0]);
  //       int arrivalM = int.parse(arrivalStr.split(':')[1]);
  //       int arrivalTotal = (arrivalH * 60) + arrivalM;
  //
  //       if (arrivalTotal <= threshold) {
  //         onTimeCount++;
  //       } else {
  //         lateCount++;
  //       }
  //     }
  //
  //     var usersSnapshot = await fireStore.collection('users').get();
  //     absentCount = usersSnapshot.docs.length - attendanceSnapshot.docs.length;
  //
  //     emit(GetAttendanceSuccessState());
  //   } catch (e) {
  //     print(e.toString());
  //     emit(GetAttendanceErrorState(e.toString()));
  //   }
  // }



// 2. Use the saved time to check attendance

  Future<void> getShiftSettings() async {
    emit(GetAttendanceLoadingState());
    try {
      var doc = await FirebaseFirestore.instance.collection('settings').doc('admin_settings').get();

      if (doc.exists) {
        // 1. Fetch Grace Period
        gracePeriod = (doc.data()?['gracePeriodMinutes'] ?? 15.0).toDouble();

        // 2. Fetch Shift Times
        String startStr = doc.data()?['shiftStartTime'] ?? "10:30";
        String endStr = doc.data()?['shiftEndTime'] ?? "13:00";

        firstTime = TimeOfDay(
          hour: int.parse(startStr.split(':')[0]),
          minute: int.parse(startStr.split(':')[1]),
        );
        lastTime = TimeOfDay(
          hour: int.parse(endStr.split(':')[0]),
          minute: int.parse(endStr.split(':')[1]),
        );
      }
      emit(GetAttendanceSuccessState());
    } catch (e) {
      emit(GetAttendanceErrorState(e.toString()));
    }
  }

  String getFormattedLateLimit() {
    final now = DateTime.now();

    // 1. Convert TimeOfDay to DateTime
    DateTime startTime = DateTime(
        now.year, now.month, now.day,
        firstTime.hour, firstTime.minute
    );

    // 2. Add the grace period
    DateTime limit = startTime.add(Duration(minutes: gracePeriod.toInt()));

    // 3. Return formatted string (e.g., 10:45 AM)
    return DateFormat('hh:mm a').format(limit);
  }
  // Future<void> getShiftSettings() async {
  //   emit(GetAttendanceLoadingState());
  //   try {
  //     var doc = await FirebaseFirestore.instance.collection('settings').doc('admin_settings').get();
  //
  //     if (doc.exists) {
  //       String startStr = doc.data()?['shiftStartTime'] ?? "09:00";
  //       String endStr = doc.data()?['shiftEndTime'] ?? "18:00";
  //
  //       // Convert "HH:mm" String -> TimeOfDay
  //       firstTime = TimeOfDay(
  //         hour: int.parse(startStr.split(':')[0]),
  //         minute: int.parse(startStr.split(':')[1]),
  //       );
  //       lastTime = TimeOfDay(
  //         hour: int.parse(endStr.split(':')[0]),
  //         minute: int.parse(endStr.split(':')[1]),
  //       );
  //     }
  //     emit(GetAttendanceSuccessState());
  //   } catch (e) {
  //     emit(GetAttendanceErrorState(e.toString()));
  //   }
  // }

  Future<void> updateShift(TimeRangeResult range) async {
    String start = "${range.start.hour.toString().padLeft(2, '0')}:${range.start.minute.toString().padLeft(2, '0')}";
    String end = "${range.end.hour.toString().padLeft(2, '0')}:${range.end.minute.toString().padLeft(2, '0')}";

    await adminSettings.set({
      'shiftStartTime': start,
      'shiftEndTime': end,
    }, SetOptions(merge: true));
    getShiftSettings();
  }



// Holiday Section


  Future<void> getHolidays() async {
    emit(GetHolidaysLoading());
    try {
      var doc = await fireStore.collection('settings').doc('admin_settings').get();
      if (doc.exists && doc.data()!['holidays'] != null) {
        holidays = List<Map<String, dynamic>>.from(doc.data()!['holidays']);
      }
      emit(GetHolidaysSuccess());
    } catch (e) {
      emit(GetHolidaysError(e.toString()));
    }
  }

  Future<void> editHoliday(int index, String newName, String newDate) async {
    // Update local list
    holidays[index]['name'] = newName;
    holidays[index]['date'] = newDate;

    emit(HolidayUpdatedSuccessfully()); // Trigger UI refresh

    try {
      // Sync the entire updated list to Firebase
      await fireStore.collection('settings').doc('admin_settings').update({
        'holidays': holidays,
      });
    } catch (e) {
      emit(HolidayErrorState(e.toString()));
    }
  }
  Future<void> addHoliday(String name, String date) async {
    // 1. Create the object
    final newHoliday = {
      'name': name,
      'date': date,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // 2. Add to local list first for immediate UI feedback
    holidays.add(newHoliday);
    emit(HolidayAddedSuccessfully());

    try {
      // 3. Use FieldValue.arrayUnion to prevent overwriting the whole list
      // This is SAFER than updating the whole array and prevents empty loops
      await fireStore.collection('settings').doc('admin_settings').update({
        'holidays': FieldValue.arrayUnion([newHoliday]),
      });
    } catch (e) {
      // If it fails, remove it locally and emit error
      holidays.remove(newHoliday);
      emit(HolidayErrorState(e.toString()));
    }
  }

  Future<void> deleteHoliday(int index) async {
    // 1. Remove it from the local list so the UI updates immediately
    holidays.removeAt(index);

    // 2. Tell the UI to rebuild
    emit(HolidayDeletedSuccessfully());

    try {
      // 3. Sync the change to Firebase
      // We send the whole 'holidays' list again after removing the item
      await fireStore.collection('settings').doc('admin_settings').update({
        'holidays': holidays,
      });
    } catch (e) {
      // If Firebase fails, you might want to handle the error here
      emit(HolidayErrorState(e.toString()));
    }
  }

// comment
  Future<void> updateWeeklyOffDaysSilent(List<int> offDays) async {
    try {
      await fireStore.collection('settings').doc('admin_settings').update({
        'weeklyOffDays': offDays,
      });
    } catch (e) {
      emit(UpdateSettingsError(e.toString()));
    }
  }

  List<AttendanceRecord> reportRecords = [];

  Map<String, List<AttendanceRecord>> get groupedReportRecords {
    Map<String, List<AttendanceRecord>> grouped = {};
    for (var record in reportRecords) {
      String date = record.name; // contains yyyy-MM-dd
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(record);
    }
    return grouped;
  }


  Future<void> getReports({required DateTime startDate, required DateTime endDate}) async {
    emit(GetReportsLoadingState());
    reportRecords = [];
    try {
      String startStr = DateFormat('yyyy-MM-dd').format(startDate);
      String endStr = DateFormat('yyyy-MM-dd').format(endDate);

      var snapshot = await fireStore.collectionGroup('days')
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr)
          .get();

      // We need to fetch user data for these records to build AttendanceRecord
      var usersSnapshot = await fireStore.collection('users').get();
      Map<String, dynamic> userMap = {
        for (var doc in usersSnapshot.docs) doc.id: doc.data()
      };

      for (var doc in snapshot.docs) {
        String uid = doc.reference.parent.parent!.id;
        var userData = userMap[uid];
        if (userData == null) continue;

        var data = doc.data();
        AttendanceStatus status = AttendanceStatus.onTime;
        if (data['status'] == 'late') status = AttendanceStatus.late;
        else if (data['status'] == 'absent') status = AttendanceStatus.absent;

        String? timeStr;
        String? checkOutStr;
        if (data['checkIn'] is Timestamp) {
          timeStr = DateFormat('hh:mm a').format((data['checkIn'] as Timestamp).toDate());
        } else if (data['checkIn'] is String) {
          timeStr = data['checkIn'];
        }

        if (data['checkOut'] is Timestamp) {
          checkOutStr = DateFormat('hh:mm a').format((data['checkOut'] as Timestamp).toDate());
        } else if (data['checkOut'] is String) {
          checkOutStr = data['checkOut'];
        }

        Employee employee = Employee(
          id: uid,
          name: userData['name'] ?? "Unknown",
          role: userData['role'] ?? "Employee",
          department: userData['department'] ?? "Unknown",
          status: EmployeeStatus.clockedIn,
          email: userData['email'],
          imageUrl: userData['profile_image'],
          phone: userData['phone'],
        );

        reportRecords.add(
          AttendanceRecord(
            employee: employee,
            name: data['date'] ?? userData['name'], // Use date as name for grouping in UI if needed
            role: employee.role,
            time: timeStr,
            checkOutTime: checkOutStr,
            status: status,
            imageUrl: employee.imageUrl,
          ),
        );
      }

      // Sort by date
      reportRecords.sort((a, b) => b.name.compareTo(a.name));
      emit(GetReportsSuccessState());
    } catch (e) {
      emit(GetReportsErrorState(e.toString()));
    }
  }

  Future<void> exportToPDF() async {
    emit(ExportLoadingState());
    try {
      final pdf = pw.Document();
      final grouped = groupedReportRecords;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            List<pw.Widget> widgets = [];
            widgets.add(pw.Header(level: 0, child: pw.Text("Attendance Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))));
            widgets.add(pw.SizedBox(height: 20));

            grouped.forEach((date, records) {
              widgets.add(pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(5),
                color: PdfColors.grey300,
                child: pw.Text("Date: $date", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ));
              
              widgets.add(pw.TableHelper.fromTextArray(
                context: context,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  <String>['Name', 'Check In', 'Check Out', 'Status'],
                  ...records.map((r) => [
                    r.employee.name,
                    r.time ?? "-",
                    r.checkOutTime ?? "-",
                    r.status.name,
                  ])
                ],
              ));
              widgets.add(pw.SizedBox(height: 15));
            });

            return widgets;
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());
      
      await Share.shareXFiles([XFile(file.path)], text: 'Attendance Report PDF');
      emit(ExportSuccessState(file.path));
    } catch (e) {
      emit(ExportErrorState(e.toString()));
    }
  }

  Future<void> exportToExcel() async {
    emit(ExportLoadingState());
    try {
      var excel = Excel.createExcel();
      String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      excel.rename(defaultSheet, 'Attendance Report');
      Sheet sheetObject = excel['Attendance Report'];

      final grouped = groupedReportRecords;
      int currentRow = 1; // 0-indexed row for Excel package? Actually it's 0-indexed

      // Define Styles

      CellStyle dateHeaderStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromInt(0xFFDBEAFE),
        bold: true,
        fontColorHex: ExcelColor.fromInt(0xFF1E40AF),
      );

      CellStyle columnHeaderStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromInt(0xFFF1F5F9),
        bold: true,
        fontColorHex: ExcelColor.fromInt(0xFF475569),
      );

      CellStyle footerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromInt(0xFFF8FAFC),
        fontColorHex: ExcelColor.fromInt(0xFF94A3B8),
        horizontalAlign: HorizontalAlign.Center,
      );
      // Add one empty row at the top as per image
      currentRow++;

      grouped.forEach((date, records) {
        // 1. Date Header Row (Merged)
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          TextCellValue('  📅 $date'), 
          cellStyle: dateHeaderStyle,
        );
        
        // Merge A to E for the date header
        sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow),
        );
        currentRow++;

        // 2. Column Headers
        List<String> headers = [ 'Name', 'Check In', 'Check Out', 'Status'];
        for (int i = 0; i < headers.length; i++) {
          var cell = CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow);
          sheetObject.updateCell(
            cell, 
            TextCellValue(headers[i]),
            cellStyle: columnHeaderStyle,
          );
        }
        currentRow++;

        // 3. Data Rows
        for (var r in records) {
          // sheetObject.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow), TextCellValue('A${DateTime.now().year}'));
          sheetObject.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow), TextCellValue(r.employee.name));
          sheetObject.updateCell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow), TextCellValue(r.time ?? "-"));
          sheetObject.updateCell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow), TextCellValue(r.checkOutTime ?? "-"));
          sheetObject.updateCell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow), TextCellValue(r.status.name));
          currentRow++;
        }
        // Small gap between groups
        currentRow++;
      });

      // 4. Footer Row
      sheetObject.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        TextCellValue('Showing ${reportRecords.length} records'),
        cellStyle: footerStyle,
      );
      sheetObject.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
      );

      // Auto-fit columns (best effort)
      for (int i = 0; i < 5; i++) {
        sheetObject.setColumnAutoFit(i);
      }

      final output = await getTemporaryDirectory();
      final filePath = "${output.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final file = File(filePath);
      
      var bytes = excel.save();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Attendance Report Excel');
        emit(ExportSuccessState(file.path));
      } else {
        emit(ExportErrorState("Failed to save excel file"));
      }
    } catch (e) {
      emit(ExportErrorState(e.toString()));
    }
  }
}
