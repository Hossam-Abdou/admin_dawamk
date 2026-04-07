part of 'admin_cubit.dart';

@immutable
abstract class AdminState {}

class AdminInitial extends AdminState {}


class AdminLoading extends AdminState {}
class ChangeFilterState extends AdminState {}

class RegisterLoading extends AdminState {}
class RegisterSuccess extends AdminState {}
class RegisterError extends AdminState {
  final String error;
  RegisterError(this.error);
}

class HolidayUpdatedSuccessfully extends AdminState {}
class HolidayDeletedSuccessfully extends AdminState {}
class LocationUpdatedSuccessfully extends AdminState {}

class UpdateShiftSettingsLoadingState extends AdminState {}
class UpdateShiftSettingsSuccessState extends AdminState {}
class UpdateShiftSettingsErrorState extends AdminState {
  final String error;

  UpdateShiftSettingsErrorState(this.error);
}

class GetAttendanceLoadingState extends AdminState {}
class GetAttendanceSuccessState extends AdminState {}
class GetAttendanceErrorState extends AdminState {
  String error;

  GetAttendanceErrorState(this.error);
}

class GetUserHistoryLoadingState extends AdminState {}
class GetUserHistorySuccessState extends AdminState {}
class GetUserHistoryErrorState extends AdminState {
  final String error;
  GetUserHistoryErrorState(this.error);
}

class GetHolidaysLoading extends AdminState {}
class GetHolidaysSuccess extends AdminState {}
class GetHolidaysError extends AdminState {
  final String error;

  GetHolidaysError(this.error);
}

class HolidayAddedSuccessfully extends AdminState {}
class HolidayErrorState extends AdminState {
  final String error;

  HolidayErrorState(this.error);
}

class UpdateSettingsLoading extends AdminState {}
class UpdateSettingsSuccess extends AdminState {}
class UpdateSettingsError extends AdminState {
  final String error;

  UpdateSettingsError(this.error);
}

class GetSettingsLoading extends AdminState {}
class GetSettingsSuccess extends AdminState {}
class GetSettingsError extends AdminState {
  final String error;

  GetSettingsError(this.error);
}


class AdminLoaded extends AdminState {
  final List<int> weeklyOffDays;
  AdminLoaded(this.weeklyOffDays);
}

class WeeklyOffDaysUpdated extends AdminState {
  final List<int> weeklyOffDays;
  WeeklyOffDaysUpdated(this.weeklyOffDays);
}

// Reports States
class GetReportsLoadingState extends AdminState {}
class GetReportsSuccessState extends AdminState {}
class GetReportsErrorState extends AdminState {
  final String error;
  GetReportsErrorState(this.error);
}

class ExportLoadingState extends AdminState {}
class ExportSuccessState extends AdminState {
  final String filePath;
  ExportSuccessState(this.filePath);
}
class ExportErrorState extends AdminState {
  final String error;
  ExportErrorState(this.error);
}