import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/auth_service.dart';
import '../../widgets/pin_input_widget.dart';
import '../home/home_screen.dart';
import 'phone_input_screen.dart';

class PinLoginScreen extends StatefulWidget {
  final bool showBiometric;

  const PinLoginScreen({
    super.key,
    this.showBiometric = false,
  });

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.showBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loginWithBiometric();
      });
    }
  }

  Future<void> _loginWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await _authService.loginWithBiometric();

    if (!mounted) return;

    if (success) {
      _navigateToHome();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Biometric authentication failed';
      });
    }
  }

  Future<void> _loginWithPin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await _authService.loginWithPin(pin);

    if (!mounted) return;

    if (success) {
      _navigateToHome();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const PhoneInputScreen()),
                    (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              Icon(
                Icons.lock_outline,
                size: 80.sp,
                color: Theme.of(context).primaryColor,
              ),

              SizedBox(height: 32.h),

              Text(
                'Enter your PIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Enter your 4-digit PIN to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 40.h),

              // PIN Input
              PinInputWidget(
                onCompleted: _loginWithPin,
                enabled: !_isLoading,
              ),

              SizedBox(height: 16.h),

              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 32.h),

              // Biometric button
              if (widget.showBiometric)
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loginWithBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use Biometric'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),

              const Spacer(),

              // Forgot PIN
              TextButton(
                onPressed: _logout,
                child: Text(
                  'Forgot PIN? Logout and create new account',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}