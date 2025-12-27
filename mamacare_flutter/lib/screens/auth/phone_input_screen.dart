//filename: phone_input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mamacare_flutter/screens/auth/pin_setup_screen.dart';

import '../../widgets/footer_widget.dart';
import '../../widgets/important_links_widget.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('0')) {
      digits = '254${digits.substring(1)}';
    }

    if (!digits.startsWith('254')) {
      digits = '254$digits';
    }

    if (digits.length == 12) {
      return '+$digits';
    }

    return phone;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 9) {
      return 'Phone number is too short';
    }

    if (digits.length > 12) {
      return 'Phone number is too long';
    }

    return null;
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final formattedPhone = _formatPhoneNumber(_phoneController.text);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(phoneNumber: formattedPhone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to MamaCare'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),

                  Icon(
                    Icons.phone_android,
                    size: 80.sp,
                    color: Theme.of(context).primaryColor,
                  ),

                  SizedBox(height: 32.h),

                  Text(
                    'Enter your phone number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'We\'ll use this to secure your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    style: TextStyle(fontSize: 18.sp),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '0791660287',
                      prefixText: '+254 ',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: _validatePhone,
                  ),

                  SizedBox(height: 32.h),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 34.h),
                            const Footer(
                    hasPartners: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}