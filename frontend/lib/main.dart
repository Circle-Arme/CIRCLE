import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/presentation/blocs/alert/alert_event.dart';
import 'package:frontend/presentation/blocs/language/language_state.dart';
import 'package:frontend/presentation/blocs/theme/theme_state.dart';
import 'package:frontend/presentation/blocs/auth/auth_bloc.dart';
import 'package:frontend/presentation/blocs/thread/thread_bloc.dart';
import 'package:frontend/presentation/blocs/alert/alert_bloc.dart'; // استيراد AlertBloc
import 'package:frontend/presentation/blocs/language/language_bloc.dart';
import 'package:frontend/presentation/blocs/language/language_event.dart';
import 'package:frontend/presentation/blocs/theme/theme_bloc.dart';
import 'package:frontend/presentation/blocs/theme/theme_event.dart';
import 'package:frontend/core/utils/shared_prefs.dart';

// الصفحات:
import 'package:frontend/presentation/screens/auth/login_page.dart';
import 'package:frontend/presentation/screens/home/fields_page.dart';
import 'package:frontend/presentation/screens/admin/admin_dashboard_page.dart';
import 'package:frontend/presentation/screens/Welcome/welcome_page.dart';
import 'package:frontend/presentation/screens/auth/regstraion_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LanguageBloc()..add(LoadLanguageEvent()),
        ),
        BlocProvider(
          create: (context) => ThemeBloc()..add(LoadThemeEvent()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => ThreadBloc(),
        ),
        BlocProvider(
          create: (context) => AlertBloc(), // إضافة AlertBloc
        ),
        BlocProvider(create: (_) => AlertBloc()..add(const FetchAlerts())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(411, 819),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, languageState) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    locale: languageState.locale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en'),
                      Locale('ar'),
                    ],
                    localeResolutionCallback: (locale, supportedLocales) {
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode == locale?.languageCode) {
                          return supportedLocale;
                        }
                      }
                      return supportedLocales.first;
                    },
                    theme: ThemeData(
                      brightness: Brightness.light,
                      scaffoldBackgroundColor: Colors.white,
                      primaryColor: const Color(0xFF2A6776),
                      fontFamily: 'Roboto',
                    ),
                    darkTheme: ThemeData(
                      brightness: Brightness.dark,
                      scaffoldBackgroundColor: const Color(0xFF121212),
                      primaryColor: Colors.tealAccent[200],
                      elevatedButtonTheme: ElevatedButtonThemeData(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent[200],
                        ),
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Colors.grey[800],
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                    themeMode: themeState.themeMode,

                    // البداية من صفحة الترحيب
                    initialRoute: '/welcome',

                    // المسارات
                    routes: {
                      '/welcome': (context) => const WelcomePage(),
                      '/login': (context) => const LoginPage(),
                      '/fields': (context) => const FieldsPage(),
                      '/admin': (context) => const AdminDashboardPage(),
                      '/signup': (context) => const CreateAccountPage(),
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}