import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/auth_service.dart';
import '../home/home_screen.dart';
// filename: biomertic_setup_screen
class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final AuthService _authService = AuthService();
  bool _canUseBiometric = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final canUse = await _authService.canUseBiometric();
    setState(() {
      _canUseBiometric = canUse;
      _isLoading = false;
    });
  }

  Future<void> _enableBiometric() async {
    setState(() => _isLoading = true);

    final success = await _authService.enableBiometric();

    if (!mounted) return;

    if (success) {
      _showSuccessMessage();
    } else {
      _showErrorMessage();
    }

    setState(() => _isLoading = false);
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Biometric authentication enabled!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _navigateToHome();
    });
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not enable biometric. You can enable it later in settings.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _navigateToHome();
    });
  }
  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Complete'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              Icon(
                Icons.fingerprint,
                size: 100.sp,
                color: Theme.of(context).primaryColor,
              ),

              SizedBox(height: 32.h),

              Text(
                'Enable Biometric Login?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                _canUseBiometric
                    ? 'Use your fingerprint or face to login quickly and securely'
                    : 'Biometric authentication is not available on this device',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 100.h),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_canUseBiometric) ...[
                ElevatedButton.icon(
                  onPressed: _enableBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Enable Biometric'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              OutlinedButton(
                onPressed: _navigateToHome,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(_canUseBiometric ? 'Skip for Now' : 'Continue'),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}