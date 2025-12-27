import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'screens/auth/phone_input_screen.dart';
import 'screens/auth/pin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'MamaCare Butler',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.pink,
            primaryColor: const Color(0xFFE91E63),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE91E63),
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final isLoggedIn = await _authService.isLoggedIn();
    final hasBiometric = StorageService().getBiometricEnabled();

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PinLoginScreen(showBiometric: hasBiometric),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE91E63),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 250.h,
              width: 250.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'MamaCare',
              style: TextStyle(
                fontSize: 36.sp,
                color: Colors.white,
                letterSpacing: 1.2,
                  fontFamily: GoogleFonts.ibmPlexSans().fontFamily

              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Companion',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 3.0,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 50.h),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 26.h),
            Text(
              'AI-Powered Maternal Health',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
                  fontFamily: GoogleFonts.ibmPlexSans().fontFamily
            ),
            ),
          ],
        ),
      ),
    );
  }
}