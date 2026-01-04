// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI ayarları (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.mainBackgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Sadece portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MovieLandApp());
  });
}

class MovieLandApp extends StatelessWidget {
  const MovieLandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLand',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.mainBackgroundColor,
        primaryColor: AppColors.logInButtonColor,
        colorScheme: ColorScheme.dark(
          primary: AppColors.logInButtonColor,
          secondary: AppColors.accentColor,
          surface: AppColors.mainBackgroundColor,
          background: AppColors.mainBackgroundColor,
        ),
        useMaterial3: true,

        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppColors.titleColor,
            letterSpacing: -1.5,
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.titleColor,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.subtitleColor,
          ),
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.mainBackgroundColor,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textColor),
          titleTextStyle: TextStyle(
            color: AppColors.titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.logInButtonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.textFieldFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.textFieldBorderColor.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.textFieldBorderColor.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.logInButtonColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),


        // Bottom Sheet Theme
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.mainBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
        ),

        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textFieldFillColor,
          contentTextStyle: const TextStyle(color: AppColors.textColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),

      home: const SplashScreen(),

      // Routes tanımlaması (gelecekte kullanılabilir)
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/home': (context) => const HomeScreen(),
      //   '/search': (context) => const SearchScreen(),
      // },
    );
  }
}