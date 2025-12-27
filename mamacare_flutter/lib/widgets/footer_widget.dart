import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Footer extends StatelessWidget {
  const Footer({super.key, this.hasPartners = true});
  final bool hasPartners;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.h),

        Divider(color: Colors.grey[300]),

        SizedBox(height: 16.h),

        Text(
          '© 2026. All Rights Reserved. Version: 1.0.0',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.sp,
          ),
        ),

        if (hasPartners) ...[
          SizedBox(height: 16.h),
          Image.asset(
            'assets/images/logo.png',
            height: 50.h,
            fit: BoxFit.contain,
          ),
        ],

        SizedBox(height: 16.h),
      ],
    );
  }
}