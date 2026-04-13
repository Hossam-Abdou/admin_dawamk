import 'package:admin_attendance/view_model/theme_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_observer.dart';
import 'config/routes_manager/route_generator.dart';
import 'config/routes_manager/routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'view_model/admin_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AdminCubit()
            ..getSettings()
            ..getHolidays()
            ..calculateDailySummary(selectedDate: DateTime.now()),
        ),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            theme: AppColors.lightTheme,
            darkTheme: AppColors.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.adminHome,
            onGenerateRoute: RouteGenerator.getRoute,
          );
        },
      ),
    );
  }
}

