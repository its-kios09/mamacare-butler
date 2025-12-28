import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamacare_flutter/screens/auth/pin_login_screen.dart';
import 'package:mamacare_flutter/screens/auth/pin_setup_screen.dart';

import '../../constants/constant.dart';
import '../../main.dart';
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
  String? _errorMessage;

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
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final formattedPhone = _formatPhoneNumber(_phoneController.text);

    try {
      final userExists = await client.v1Auth.userExists(formattedPhone);
      if (!mounted) return;

      if (userExists) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PinLoginScreen(
              showBiometric: false,
              phoneNumber: formattedPhone,
            ),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PinSetupScreen(phoneNumber: formattedPhone),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection error: ${e.toString()}';
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: kSystemPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight),
                Text(
                  'Login',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Digital Maternal Health Services (DMHS)',
                  style: GoogleFonts.openSans(
                    fontSize: ScreenUtil().setSp(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Provide the required details to log in',
                  style: TextStyle(color: kTextGrey),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Phone number',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style:TextStyle(fontSize: ScreenUtil().setSp(13)),
                  decoration: InputDecoration(
                    labelText: "Enter your phone number here...",
                    labelStyle: TextStyle(
                      color: kTextGrey,
                      fontSize: ScreenUtil().setSp(15),
                    ),
                    prefixText: '+254 ',
                    hintText: '0700000000',
                    hintStyle: TextStyle(fontSize: ScreenUtil().setSp(13)),
                    prefixIcon: Icon(Icons.phone, size: ScreenUtil().setSp(18)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: kTextGrey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: kTextGrey),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: _validatePhone,
                ),
                const SizedBox(height: 10),

                // Error message display
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      backgroundColor: _isLoading
                          ? Colors.grey
                          : kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Checking...',
                          style: TextStyle(
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 130),
                const Center(
                  child: Text(
                    'Built with',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ImportantLinksWidget(
                      title: 'Flutter',
                      assetLink: 'assets/images/flutter.png',
                    ),
                    ImportantLinksWidget(
                      title: 'Gemini AI',
                      assetLink: 'assets/images/gemini.png',
                    ),
                    ImportantLinksWidget(
                      title: 'ServerPod',
                      assetLink: 'assets/images/serverpod.png',
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Footer(
                  hasPartners: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}