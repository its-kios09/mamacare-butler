import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamacare_client/mamacare_client.dart';
import 'package:mamacare_flutter/screens/health/health_trends_screen.dart';
import 'package:mamacare_flutter/screens/onboarding/maternal_profile_screen.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'screens/auth/phone_input_screen.dart';
import 'screens/auth/pin_login_screen.dart';

late final Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService().init();

  client = Client('http://192.168.1.70:8083/');
  if (kDebugMode) {
    print('🔥 Serverpod client initialized: http://192.168.1.70:8083/');
  }
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
          routes: {
            '/health-trends': (context) => const HealthTrendsScreen(),
          },
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

    if (isLoggedIn) {
      final userId = StorageService().getUserId();

      if (userId == null) {
        // No user ID, logout and start over
        await _authService.logout();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
        );
        return;
      }

      // User is logged in, check if they have a profile
      try {
        final profile = await client.v1MaternalProfile.getProfile(userId);

        if (!mounted) return;

        if (profile == null) {
          // No profile → Onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MaternalProfileScreen(userId: userId),
            ),
          );
        } else {
          // Has profile → PIN Login
          final hasBiometric = StorageService().getBiometricEnabled();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PinLoginScreen(showBiometric: hasBiometric),
            ),
          );
        }
      } catch (e) {
        // On error, show PIN login
        final hasBiometric = StorageService().getBiometricEnabled();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PinLoginScreen(showBiometric: hasBiometric),
          ),
        );
      }
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
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220.w,
                    height: 220.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2.w,
                      ),
                    ),
                  ),

                  Container(
                    width: 180.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5.w,
                      ),
                    ),
                  ),
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 180.h,
                    width: 180.w,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'mama',
                      style: GoogleFonts.openSans(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.pink.shade900.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Care',
                      style: GoogleFonts.openSans(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.pink.shade900.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: const Color(0xFFE91E63),
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                Text(
                  'Maternal Health Companion',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil().setSp(12),
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 40.h),

            Column(
              children: [
                SizedBox(
                  height: 30.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(1, (index) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      );
                    }),
                  ),
                ),

                SizedBox(height: 40.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'AI-Powered Maternal Health Assistant',
                        style: GoogleFonts.openSans(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}