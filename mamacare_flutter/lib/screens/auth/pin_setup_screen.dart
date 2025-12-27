import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/auth_service.dart';
import '../../widgets/pin_input_widget.dart';
import 'biometric_setup_screen.dart';

class PinSetupScreen extends StatefulWidget {
  final String phoneNumber;

  const PinSetupScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final AuthService _authService = AuthService();
  bool _isFirstEntry = true;
  String _firstPin = '';
  bool _isLoading = false;
  String _errorMessage = '';

  void _onPinCompleted(String pin) async {
    if (_isFirstEntry) {
      setState(() {
        _firstPin = pin;
        _isFirstEntry = false;
        _errorMessage = '';
      });
    } else {
      if (pin == _firstPin) {
        setState(() => _isLoading = true);

        final success = await _authService.setupPin(widget.phoneNumber, pin);

        if (!mounted) return;

        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BiometricSetupScreen(),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to setup PIN. Please try again.';
            _isFirstEntry = true;
            _firstPin = '';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'PINs do not match. Please try again.';
          _isFirstEntry = true;
          _firstPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PIN'),
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
                _isFirstEntry ? 'Create your PIN' : 'Confirm your PIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _isFirstEntry
                    ? 'Enter a 4-digit PIN to secure your account'
                    : 'Enter your PIN again to confirm',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40.h),
              PinInputWidget(
                key: ValueKey(_isFirstEntry),
                onCompleted: _onPinCompleted,
                enabled: !_isLoading,
              ),
              SizedBox(height: 16.h),
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
              const Spacer(),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Text(
                      widget.phoneNumber,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}