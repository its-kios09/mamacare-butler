import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
// pin_input_widget.dart
class PinInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final bool enabled;

  const PinInputWidget({
    super.key,
    required this.onCompleted,
    this.enabled = true,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 4,
      controller: _pinController,
      enabled: widget.enabled,
      obscureText: true,
      obscuringCharacter: '●',
      blinkWhenObscuring: true,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12.r),
        fieldHeight: 60.h,
        fieldWidth: 60.w,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.grey[100],
        selectedFillColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey[300]!,
        selectedColor: Theme.of(context).primaryColor,
      ),
      cursorColor: Theme.of(context).primaryColor,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      keyboardType: TextInputType.number,
      onCompleted: widget.onCompleted,
      onChanged: (_) {},
    );
  }
}